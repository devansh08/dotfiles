#!/bin/sh

CONFIG_DIR=~/.config/kitty
SCRIPTS_DIR=$CONFIG_DIR/scripts
SESSION_SCRIPT_DIR=$SCRIPTS_DIR/session
SESSIONS_DIR=$CONFIG_DIR/sessions
LOG_FILE=$SCRIPTS_DIR/logs/session.log
MAX_SIZE=$((1024 * 1024))

cd $SCRIPTS_DIR

if [ -f "$LOG_FILE" ]; then
  filesize=$(stat -c%s "$LOG_FILE")
  if [ "$filesize" -gt "$MAX_SIZE" ]; then
    rm "$LOG_FILE"
  fi
fi

echo $(date) >>$LOG_FILE
echo "" >>$LOG_FILE

json=$(kitten @ ls | jq -c '.')
echo "lsData: data=$json" >>$LOG_FILE
echo "" >>$LOG_FILE

cd $SESSION_SCRIPT_DIR
OUTPUT_FILE=$(mktemp)
echo "tmpOutputFile: path=$OUTPUT_FILE" >>$LOG_FILE
echo "" >>$LOG_FILE
node --experimental-transform-types --disable-warning=ExperimentalWarning session.ts "$json" 1>$OUTPUT_FILE 2>>$LOG_FILE
cd $SCRIPTS_DIR
echo "nodeOutput: stdout=$(cat $OUTPUT_FILE)" >>$LOG_FILE
echo "" >>$LOG_FILE

output=$(cat $OUTPUT_FILE)
id=$(echo "$output" | head -n 1)
echo "osWindowId: id=$id" >>$LOG_FILE
echo "" >>$LOG_FILE
cmds=$(echo "$output" | tail -n +2)
echo "commands: cmd=$cmds" >>$LOG_FILE
echo "" >>$LOG_FILE

echo "$cmds" >$SESSIONS_DIR/$id.kitty

rm $OUTPUT_FILE
