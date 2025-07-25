const log = (msg: string) => {
  console.error(msg);
  console.error();
};

type Layout = "splits" | "stack";

interface SplitData {
  id: number;
  bias: number;
  horizontal: boolean;
}

interface SplitPair {
  bias: number;
  horizontal: boolean;
  one: number | SplitPair;
  two: number | SplitPair;
}

interface SplitState {
  pairs: SplitPair;
}

interface FgProcess {
  cmdline: string[];
  cwd: string;
  pid: number;
}

interface Window {
  id: number;
  is_active: boolean;
  is_focused: boolean;
  at_prompt: boolean;
  cmdline: string[];
  cwd: string;
  env: { [key: string]: string };
  foreground_processes: FgProcess[];
  title: string;
}

interface Group {
  id: number;
  windows: number[];
}

interface Tab {
  id: number;
  is_active: boolean;
  layout: Layout;
  layout_state: SplitState;
  windows: Window[];
  groups: Group[];
}

interface OsWindow {
  id: number;
  is_active: boolean;
  tabs: Tab[];
  wm_name: string;
}

const dfs = (
  pair: SplitPair | number,
  splitMap: Map<number, SplitData>,
  ancestorList: number[],
  ancestorMap: Map<number, number[]>,
  groupMap: Map<number, number>,
) => {
  if (pair) {
    log(`[dfs] processingPair: pair=${JSON.stringify(pair)}`);
    if (typeof pair === "number") {
      const groupId = groupMap.get(pair) || -1;
      ancestorMap.set(
        groupId,
        [...ancestorList].sort((a, b) => b - a),
      );

      log(
        `[dfs] foundNumberPair: groupId=${groupId} ancestorList=${ancestorMap.get(groupId)}`,
      );
      return;
    }

    const id: number = splitMap.size;
    const data: SplitData = {
      id,
      bias: pair.bias,
      horizontal: pair.horizontal,
    };
    log(`[dfs] processingPairNode: id=${id} data=${JSON.stringify(data)}`);
    ancestorList.push(id);
    splitMap.set(id, data);

    dfs(pair.one, splitMap, [...ancestorList], ancestorMap, groupMap);
    dfs(pair.two, splitMap, [...ancestorList], ancestorMap, groupMap);
  }
};

const commonAncestor = (a: number[], b: number[]): number => {
  let i = 0,
    j = 0;

  while (i < a.length && j < b.length) {
    if (a[i] === b[j]) {
      return a[i];
    } else if (a[i] > b[j]) {
      i++;
    } else if (a[i] < b[j]) {
      j++;
    }
  }

  return -1;
};

const getCmdline = (window: Window): string => {
  if (window.foreground_processes.length === 0) {
    return "/bin/fish";
  }

  let cmd: string = window.foreground_processes[0].cmdline?.join(" ");
  if (cmd === "/bin/sh /home/devansh/.config/kitty/scripts/save_session.sh") {
    cmd = "/bin/fish";
  } else if (
    cmd !== "/bin/fish" &&
    cmd !== "/usr/bin/fish" &&
    !cmd.endsWith("; exec fish'")
  ) {
    cmd = `/bin/fish -c '${cmd}; exec fish'`;
  }

  return cmd;
};

// @ts-ignore: process is built-in
const config: OsWindow[] = JSON.parse(process.argv[2]);
log(`foundOsWindows: count=${config.length}`);

const activeOsWindow: OsWindow | undefined = config.find(
  (win) => win.is_active,
);
if (activeOsWindow) {
  console.log(activeOsWindow.wm_name);
  log(
    `foundActiveOsWindow: id=${activeOsWindow.id} name=${activeOsWindow.wm_name}`,
  );

  const tabs: Tab[] = activeOsWindow.tabs;
  log(`foundTabsInActiveOsWindow: count=${tabs.length}`);
  tabs.forEach((tab, j) => {
    log(`processingTab: id=${tab.id} layout=${tab.layout}`);

    if (j > 0) {
      console.log("new_tab");
    }

    console.log(`layout ${tab.layout}`);

    const windows: Window[] = tab.windows.sort((a, b) => a.id - b.id);
    log(`foundWindowsInTab: count=${windows.length}`);

    const ancestorMap: Map<number, number[]> = new Map();
    const splitMap: Map<number, SplitData> = new Map();

    const groupMap: Map<number, number> = new Map();

    tab.groups.forEach((group) => {
      groupMap.set(group.id, group.windows[0]);
    });
    log(
      `groupMapForTab: tabId=${tab.id} map=${JSON.stringify(Array.from(groupMap))}`,
    );

    dfs(tab.layout_state.pairs, splitMap, [], ancestorMap, groupMap);

    const launchedWindows: number[] = [];

    windows.forEach((window, i) => {
      const id: number = window.id;
      log(`processingWindow: id=${id}`);

      let envStr: string = "";
      Object.entries(window.env).forEach(([key, value]) => {
        envStr += `--env ${key}=${value} `;
      });
      envStr = envStr.trim();
      log(`envVarsForWindow: env=${envStr}`);

      if (
        window.cwd !== "/home/devansh/.dotfiles/kitty/.config/kitty/scripts" &&
        !envStr.includes(
          "_=/home/devansh/.config/kitty/scripts/save_session.sh",
        )
      ) {
        if (i === 0) {
          log("processingFirstWindow");
          console.log(
            `launch --cwd=${window.cwd} ${envStr} ${getCmdline(window)}`,
          );

          launchedWindows.push(id);
        } else {
          log(`processingNthWindow: n=${launchedWindows.length}`);

          let commonId: number = -1;
          let relativeId: number = -1;

          launchedWindows.forEach((winId) => {
            const tempId: number = commonAncestor(
              ancestorMap.get(id) || [],
              ancestorMap.get(winId) || [],
            );
            if (tempId > commonId) {
              commonId = tempId;
              relativeId = winId;
            }
          });

          log(
            `ancestorMapCreated: winId=${id} map=${JSON.stringify(Array.from(ancestorMap))} ancestorId=${commonId}`,
          );

          if (commonId !== -1) {
            const data: SplitData | undefined = splitMap.get(commonId);
            log(`splitDataExtracted: data=${JSON.stringify(data)}`);

            if (data) {
              console.log(
                `launch --cwd=${window.cwd} ${envStr} --next-to='id:${relativeId}' --location=${data.horizontal ? "vsplit" : "hsplit"} --bias=${100 - data.bias * 100} ${getCmdline(window)}`,
              );

              launchedWindows.push(id);
            }
          }
        }
      }
    });
  });
}
