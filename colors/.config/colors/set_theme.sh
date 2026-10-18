#!/bin/bash
#
# theme.sh — Full theme workflow: generate + apply
#
# 1. Prompts you to select a theme from a numbered menu.
# 2. Generates all format files (theme.json, theme.lua, nvim.lua, etc.)
#    from the theme's output file.
# 3. Sets up ~/.active_theme symlink and applies the theme to every
#    application defined in applications.json.
#
# Usage: ./theme.sh [--dry-run] [--force]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
APPLICATIONS_JSON="$SCRIPT_DIR/applications.json"
ACTIVE_THEME_DIR="$HOME/.active_theme"
THEME_JSON="$ACTIVE_THEME_DIR/theme.json"

# ── Flags ─────────────────────────────────────────────────────────────────
DRY_RUN=false
FORCE=false
THEME_NAME=""

for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=true ;;
  --force) FORCE=true ;;
  -*)
    echo "Unknown option: $arg"
    exit 1
    ;;
  *)
    echo "Unknown argument: $arg"
    exit 1
    ;;
  esac
done

# ── Logging helpers ──────────────────────────────────────────────────────
ts() { date '+%Y-%m-%d %H:%M:%S'; }

log() {
  local level="$1"
  shift
  echo "[$(ts)] [$level] $*"
}

verbose() {
  [[ "$VERBOSE" == "true" ]] && log "INFO" "$@" || true
}
VERBOSE=true

# ═══════════════════════════════════════════════════════════════════════════
# STEP 0: Interactive theme picker (with * marker for active theme)
# ═══════════════════════════════════════════════════════════════════════════
pick_theme() {
  if [[ ! -d "$THEMES_DIR" ]]; then
    log "ERROR" "Themes directory not found at: $THEMES_DIR" >&2
    exit 1
  fi

  local themes=()
  while IFS= read -r -d '' entry; do
    themes+=("$(basename "$entry")")
  done < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

  if [[ ${#themes[@]} -eq 0 ]]; then
    log "ERROR" "No themes found in $THEMES_DIR" >&2
    exit 1
  fi

  echo ""
  echo "Available themes:"
  for i in "${!themes[@]}"; do
    local num=$((i + 1))
    local marker=" "
    if [[ -L "$HOME/.active_theme" ]]; then
      readlink "$HOME/.active_theme" | grep -q "${THEMES_DIR}/${themes[$i]}$" && marker="*"
    fi
    printf "  %2d) %s%s\n" "$num" "$marker" "${themes[$i]}"
  done
  echo ""

  while true; do
    read -rp "Select a theme [1-${#themes[@]}]: " choice

    # Empty input → use current active theme
    if [[ -z "$choice" ]]; then
      if [[ -L "$HOME/.active_theme" ]]; then
        local active_base
        active_base="$(basename "$(readlink "$HOME/.active_theme")")"
        for t in "${themes[@]}"; do
          if [[ "$t" == "$active_base" ]]; then
            THEME_NAME="$t"
            break 2
          fi
        done
        echo "No active theme set. Please enter a number."
        continue
      else
        echo "No active theme set. Please enter a number."
        continue
      fi
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1)) && ((choice <= ${#themes[@]})); then
      THEME_NAME="${themes[$((choice - 1))]}"
      return
    else
      echo "Please enter a number between 1 and ${#themes[@]}."
    fi
  done
}

pick_theme

THEME_DIR="$THEMES_DIR/$THEME_NAME"
OUTPUT_FILE="$THEME_DIR/output"

# ═══════════════════════════════════════════════════════════════════════════
# STEP 1: Generate format files from the theme's output file
# ═══════════════════════════════════════════════════════════════════════════
if [[ ! -f "$OUTPUT_FILE" ]]; then
  log "ERROR" "'output' file not found in theme directory '$THEME_NAME'." >&2
  exit 1
fi

# Extract theme, variant, and primary color from theme name (format: theme-variant_primary)
REST="${THEME_NAME##*-}"
GEN_THEME="${THEME_NAME%-$REST}"
VARIANT=$(echo "$REST" | cut -d'_' -f1)
PRIMARY=$(echo "$REST" | cut -d'_' -f2)

# Arrays to store colors
declare -a COLOR_NAMES
declare -a COLOR_VALUES

LINE_NUM=0
while IFS= read -r line || [[ -n "$line" ]]; do
  LINE_NUM=$((LINE_NUM + 1))

  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  # Validate format: color_name:color_hex
  if ! echo "$line" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*:#?[a-fA-F0-9]{6}$'; then
    log "ERROR" "Invalid format at line $LINE_NUM: '$line'" >&2
    log "ERROR" "Expected format: color_name:color_hex (e.g., bg_main:#1e1e2e)" >&2
    exit 1
  fi

  COLOR_NAME=$(echo "$line" | cut -d':' -f1)
  COLOR_HEX=$(echo "$line" | cut -d':' -f2 | sed 's/^#//')

  COLOR_NAMES+=("$COLOR_NAME")
  COLOR_VALUES+=("$COLOR_HEX")
done <"$OUTPUT_FILE"

if [[ ${#COLOR_NAMES[@]} -eq 0 ]]; then
  log "ERROR" "No valid color entries found in output file." >&2
  exit 1
fi

log "INFO" "Generating theme files for '$THEME_NAME'..."

# ── Generate JSON ─────────────────────────────────────────────────────────
{
  echo "{"
  for i in "${!COLOR_NAMES[@]}"; do
    if [[ $i -lt $((${#COLOR_NAMES[@]} - 1)) ]]; then
      echo "  \"${COLOR_NAMES[$i]}\": \"#${COLOR_VALUES[$i]}\","
    else
      echo "  \"${COLOR_NAMES[$i]}\": \"#${COLOR_VALUES[$i]}\""
    fi
  done
  echo "}"
} >"$THEME_DIR/theme.json"

# ── Generate Lua ──────────────────────────────────────────────────────────
{
  echo "-- Theme: $GEN_THEME"
  echo "-- Variant: $VARIANT"
  echo "-- Primary Color: #$PRIMARY"
  echo ""
  echo "return {"
  for i in "${!COLOR_NAMES[@]}"; do
    if [[ $i -lt $((${#COLOR_NAMES[@]} - 1)) ]]; then
      echo "  [\"${COLOR_NAMES[$i]}\"] = \"#${COLOR_VALUES[$i]}\","
    else
      echo "  [\"${COLOR_NAMES[$i]}\"] = \"#${COLOR_VALUES[$i]}\""
    fi
  done
  echo "}"
} >"$THEME_DIR/theme.lua"

# ── Generate nvim.lua ────────────────────────────────────────────────────
cat >"$THEME_DIR/nvim.lua" <<EOF
return {
  colorscheme = "$GEN_THEME",
  variant = "$VARIANT",
  accent = "$PRIMARY",
}
EOF

# ── Generate CONF ────────────────────────────────────────────────────────
{
  echo "# Theme: $GEN_THEME"
  echo "# Variant: $VARIANT"
  echo "# Primary Color: #$PRIMARY"
  for i in "${!COLOR_NAMES[@]}"; do
    echo "${COLOR_NAMES[$i]} #${COLOR_VALUES[$i]}"
  done
} >"$THEME_DIR/theme.conf"

# ── Generate CSS (:root variables) ───────────────────────────────────────
{
  echo "/* Theme: $GEN_THEME */"
  echo "/* Variant: $VARIANT */"
  echo "/* Primary Color: #$PRIMARY */"
  echo ""
  echo ":root {"
  for i in "${!COLOR_NAMES[@]}"; do
    echo "  --color-${COLOR_NAMES[$i]}: #${COLOR_VALUES[$i]};"
  done
  echo "}"
} >"$THEME_DIR/theme.css"

# ── Generate .define.css ─────────────────────────────────────────────────
{
  echo "/* Theme: $GEN_THEME */"
  echo "/* Variant: $VARIANT */"
  echo "/* Primary Color: #$PRIMARY */"
  for i in "${!COLOR_NAMES[@]}"; do
    echo "@define-color ${COLOR_NAMES[$i]} #${COLOR_VALUES[$i]};"
  done
} >"$THEME_DIR/theme.define.css"

log "OK" "Generated theme files:"
log "OK" "  - theme.json"
log "OK" "  - theme.lua"
log "OK" "  - nvim.lua"
log "OK" "  - theme.conf"
log "OK" "  - theme.css"
log "OK" "  - theme.define.css"

# ═══════════════════════════════════════════════════════════════════════════
# STEP 2: Set up active theme symlink
# ═══════════════════════════════════════════════════════════════════════════
mkdir -p "$HOME"
ln -sfn "$THEME_DIR" "$ACTIVE_THEME_DIR"
log "INFO" "Updated ~/.active_theme → $THEME_NAME"

# ── Kill and restart hyprpaper ─────────────────
log "INFO" "Restarting hyprpaper..."
if pgrep -x hyprpaper >/dev/null 2>&1; then
  log "INFO" "hyprpaper is already running, restarting..."
  pkill -TERM -x hyprpaper 2>/dev/null || true
fi
nohup hyprpaper </dev/null >/dev/null 2>&1 &
log "OK" "hyprpaper restarted"

# ── Helper: render template content (outputs to stdout) ────────────────
render_template_content() {
  perl -e '
    my $skip_hash = $ENV{"SKIP_HASH"} eq "true";
    my $pattern = $ENV{"TMPL_PATTERN"};
    my $color_vars = $ENV{"COLOR_VARS"};

    my %colors;
    for my $line (split /\n/, $color_vars) {
      if ($line =~ /^(.+?)=(.*)$/) {
        $colors{$1} = $2;
      }
    }

    local $/;
    my $content = <STDIN>;

    $content =~ s{$pattern}{
      my $match = $&;
      my $key = $match;
      if ($key =~ /^\{\{(.+)\}\}$/) {
        $key = $1;
      } elsif ($key =~ /^\x27(.+?)\x27$/) {
        $key = $1;
      }
      if (exists $colors{$key}) {
        my $val = $colors{$key};
        if ($skip_hash && $val =~ /^#/) {
          substr($val, 1);
        } else {
          $val;
        }
      } else {
        $match;
      }
    }ge;

    print $content;
  '
}

# ═══════════════════════════════════════════════════════════════════════════
# STEP 3: Apply theme to all applications defined in applications.json
# ═══════════════════════════════════════════════════════════════════════════

validate_prerequisites() {
  if ! command -v jq &>/dev/null; then
    log "ERROR" "jq is required but not installed. Install it and try again."
    exit 1
  fi

  if [[ ! -f "$APPLICATIONS_JSON" ]]; then
    log "ERROR" "applications.json not found at: $APPLICATIONS_JSON"
    exit 1
  fi

  if ! jq empty "$APPLICATIONS_JSON" 2>/dev/null; then
    log "ERROR" "applications.json is not valid JSON."
    exit 1
  fi

  if [[ ! -f "$THEME_JSON" ]]; then
    log "ERROR" "theme.json not found at: $THEME_JSON"
    exit 1
  fi

  local clean_json
  clean_json="$(strip_json_comments "$THEME_JSON")"
  if ! echo "$clean_json" | jq empty 2>/dev/null; then
    log "ERROR" "theme.json is not valid JSON (even after stripping comments)."
    exit 1
  fi
}

# ── Helper: strip C-style comments from theme.json ──────────────────────
strip_json_comments() {
  grep -v '^[[:space:]]*/\*' "$1" | grep -v '^[[:space:]]*$'
}

# ── Expand path helper (handles ~) ──────────────────────────────────────
expand_path() {
  local p="$1"
  echo "${p/\~/$HOME}"
}

# ── Build color lookup map from theme.json ───────────────────────────────
declare -A COLOR_MAP

build_color_map() {
  verbose "Building color lookup map from $THEME_JSON"
  local clean_json
  clean_json="$(strip_json_comments "$THEME_JSON")"

  while IFS='=' read -r key value; do
    key="$(echo "$key" | xargs)"
    value="$(echo "$value" | xargs)"
    COLOR_MAP["$key"]="$value"
  done < <(echo "$clean_json" | jq -r 'to_entries[] | "\(.key)=\(.value)"')

  verbose "Loaded ${#COLOR_MAP[@]} color values"
}

# ── Copy mode: theme_file → destination ──────────────────────────────────
apply_theme_file() {
  local app_name="$1"
  local theme_file_rel="$2"
  local dest="$3"
  local force="$4"

  local theme_src="$ACTIVE_THEME_DIR/$theme_file_rel"
  dest="$(expand_path "$dest")"
  theme_src="$(expand_path "$theme_src")"

  verbose "[$app_name] Copying theme file: $theme_src → $dest"

  if [[ ! -f "$theme_src" ]]; then
    log "ERROR" "[$app_name] theme_file not found at: $theme_src"
    return 1
  fi

  if ! $force && [[ -f "$dest" ]] && cmp -s "$theme_src" "$dest"; then
    log "SKIP" "[$app_name] Destination already up to date: $dest"
    return 2
  fi

  if $DRY_RUN; then
    log "DRY-RUN" "[$app_name] Would copy: $theme_src → $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  cp -f "$theme_src" "$dest"
  log "OK" "[$app_name] Copied theme file to: $dest"
}

# ── Template mode: render → destination ──────────────────────────────────
apply_template() {
  local app_name="$1"
  local template_rel="$2"
  local dest="$3"
  local skip_hash="$4"
  local tmpl_pattern="$5"
  local force="$6"

  local tmpl_src
  tmpl_src="$(expand_path "$template_rel")"
  dest="$(expand_path "$dest")"

  verbose "[$app_name] Rendering template: $tmpl_src → $dest (skip_hash=$skip_hash, pattern=$tmpl_pattern)"

  if [[ ! -f "$tmpl_src" ]]; then
    log "ERROR" "[$app_name] Template file not found at: $tmpl_src"
    return 1
  fi

  local content
  content="$(TMPL_PATTERN="$tmpl_pattern" SKIP_HASH="$skip_hash" COLOR_VARS="$color_vars" \
    render_template_content < "$tmpl_src")"

  local perl_rc=$?
  if [[ $perl_rc -ne 0 ]]; then
    log "ERROR" "[$app_name] Perl replacement failed (rc=$perl_rc)"
    return 1
  fi

  if ! $force && [[ -f "$dest" ]] && [[ "$(echo "$content")" == "$(cat "$dest")" ]]; then
    log "SKIP" "[$app_name] Destination already up to date: $dest"
    return 2
  fi

  if $DRY_RUN; then
    log "DRY-RUN" "[$app_name] Would render template to: $dest"
    verbose "DRY-RUN" "Rendered content preview (first 5 lines):"
    echo "$content" | head -5 | sed 's/^/  /'
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  echo "$content" >"$dest"
  log "OK" "[$app_name] Rendered template to: $dest"
}

# ── Validate & apply ─────────────────────────────────────────────────────
validate_prerequisites
build_color_map

mapfile -t apps < <(jq -r 'keys[]' "$APPLICATIONS_JSON")

log "INFO" "Found ${#apps[@]} applications to process"

# ── Build color vars string once (shared between template and cmd rendering) ──
color_vars=""
for key in "${!COLOR_MAP[@]}"; do
  color_vars+="${key}=${COLOR_MAP[$key]}"$'\n'
done

success=0
failed=0
skipped=0

for app in "${apps[@]}"; do
  verbose "--- Processing application: $app ---"

  file="$(jq -r --arg app "$app" '.[$app].file // empty' "$APPLICATIONS_JSON")"
  theme_file="$(jq -r --arg app "$app" '.[$app].theme_file // empty' "$APPLICATIONS_JSON")"
  template="$(jq -r --arg app "$app" '.[$app].template // empty' "$APPLICATIONS_JSON")"
  skip_hash="$(jq -r --arg app "$app" '.[$app].skip_hash // false' "$APPLICATIONS_JSON")"
  run_dir="$(jq -r --arg app "$app" '.[$app].dir // empty' "$APPLICATIONS_JSON")"
  run_cmd="$(jq -r --arg app "$app" '.[$app].cmd // empty' "$APPLICATIONS_JSON")"

  # ── Run dir/cmd if specified ─────────────────────────────────────
  if [[ -n "$run_dir" && -n "$run_cmd" ]]; then
    run_dir="$(expand_path "$run_dir")"

    # Render template variables in command (if cmd_pattern is set)
    rendered_cmd="$run_cmd"
    cmd_pattern=
    cmd_pattern="$(jq -r --arg app "$app" '.[$app].cmd_template_pattern // empty' "$APPLICATIONS_JSON")"
    if [[ -n "$cmd_pattern" ]]; then
      rendered_cmd="$(echo "$run_cmd" | TMPL_PATTERN="$cmd_pattern" SKIP_HASH="$skip_hash" COLOR_VARS="$color_vars" render_template_content)"
      verbose "[$app] Rendered cmd: $rendered_cmd"
    fi

    log "INFO" "[$app] Running in $run_dir: $rendered_cmd"
    (cd "$run_dir" && eval "$rendered_cmd")
    ((success++)) || true
    continue
  fi

  if [[ -z "$theme_file" && -z "$template" ]]; then
    log "ERROR" "[$app] No 'file', 'theme_file', or 'template' key found. Skipping."
    ((failed++)) || true
    continue
  fi

  if [[ -n "$template" && -z "$(jq -r --arg app "$app" '.[$app].template_pattern // empty' "$APPLICATIONS_JSON")" ]]; then
    log "ERROR" "[$app] 'template' is set but 'template_pattern' is missing."
    ((failed++)) || true
    continue
  fi

  if [[ -n "$theme_file" ]]; then
    rc=0
    apply_theme_file "$app" "$theme_file" "$file" "$FORCE" || rc=$?
    if [[ $rc -eq 0 ]]; then
      ((success++)) || true
    elif [[ $rc -eq 2 ]]; then
      : # skip — already up to date
    else
      ((failed++)) || true
    fi
    continue
  fi

  tmpl_pattern="$(jq -r --arg app "$app" '.[$app].template_pattern' "$APPLICATIONS_JSON")"
  verbose "[$app] Using pattern: $tmpl_pattern"

  rc=0
  apply_template "$app" "$template" "$file" "$skip_hash" "$tmpl_pattern" "$FORCE" || rc=$?
  if [[ $rc -eq 0 ]]; then
    ((success++)) || true
  elif [[ $rc -eq 2 ]]; then
    : # skip — already up to date
  else
    ((failed++)) || true
  fi
done

# ── Summary ──────────────────────────────────────────────────────────────
log "INFO" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "INFO" "Summary: $success succeeded, $failed failed, $((${#apps[@]} - success - failed)) skipped"
log "INFO" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $failed -eq 0 ]] && exit 0 || exit 1
