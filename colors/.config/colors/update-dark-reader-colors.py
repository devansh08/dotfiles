"""
update-dark-reader-colors.py

Updates Dark Reader's stored theme colors in Firefox/Chrome's
storage-sync-v2.sqlite using the active color theme.

Reads ~/.active_theme/theme.json for:
  bg_main    → darkSchemeBackgroundColor
  fg_main    → darkSchemeTextColor
  fg_selection → selectionColor

Usage: python3 update-dark-reader-colors.py [db_path]
"""

import json
import os
import sqlite3
import sys


DB_NAME = "storage-sync-v2.sqlite"
EXT_ID = "addon@darkreader.org"
ACTIVE_THEME = os.path.expanduser("~/.active_theme/theme.json")

COLOR_MAP = {
    "darkSchemeBackgroundColor": "bg_main",
    "darkSchemeTextColor": "fg_main",
    "selectionColor": "fg_selection",
}


def load_active_colors() -> dict[str, str]:
    """Read bg_main, fg_main, fg_selection from the active theme."""
    if not os.path.isfile(ACTIVE_THEME):
        print(f"ERROR: Active theme not found at {ACTIVE_THEME}", file=sys.stderr)
        sys.exit(1)

    with open(ACTIVE_THEME, "r") as f:
        data = json.load(f)

    colors = {}
    for dr_key, theme_key in COLOR_MAP.items():
        value = data.get(theme_key)
        if not value:
            print(
                f"ERROR: '{theme_key}' not found in {ACTIVE_THEME}",
                file=sys.stderr,
            )
            sys.exit(1)
        colors[dr_key] = value

    return colors


def main():
    # Determine database path
    if len(sys.argv) > 1:
        db_path = os.path.expanduser(sys.argv[1])
    else:
        db_path = DB_NAME

    if not os.path.isfile(db_path):
        print(f"ERROR: Database not found at {db_path}", file=sys.stderr)
        sys.exit(1)

    # Load active colors
    active_colors = load_active_colors()

    # Connect and read existing Dark Reader data
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute(
        "SELECT data FROM storage_sync_data WHERE ext_id = ?",
        (EXT_ID,),
    )
    row = cursor.fetchone()
    if not row:
        print(
            f"ERROR: No entry for '{EXT_ID}' in {db_path}",
            file=sys.stderr,
        )
        conn.close()
        sys.exit(1)

    raw_value = row[0]
    if not raw_value:
        print("ERROR: Row value is empty", file=sys.stderr)
        conn.close()
        sys.exit(1)

    storage = json.loads(raw_value)

    # Ensure top-level 'theme' key exists
    if "theme" not in storage:
        storage["theme"] = {}

    # Apply color updates
    for dr_key, hex_color in active_colors.items():
        storage["theme"][dr_key] = hex_color

    # Write back with compact JSON
    updated_json = json.dumps(storage, separators=(",", ":"))

    cursor.execute(
        "UPDATE storage_sync_data SET data = ? WHERE ext_id = ?",
        (updated_json, EXT_ID),
    )
    conn.commit()

    # ── Verification ──
    cursor.execute(
        "SELECT data FROM storage_sync_data WHERE ext_id = ?",
        (EXT_ID,),
    )
    verify_row = cursor.fetchone()
    if not verify_row:
        print("ERROR: Verification query returned nothing", file=sys.stderr)
        conn.close()
        sys.exit(1)

    verify_storage = json.loads(verify_row[0])
    theme = verify_storage.get("theme", {})

    all_ok = True
    for dr_key, expected in active_colors.items():
        actual = theme.get(dr_key)
        status = "OK" if actual == expected else "MISMATCH"
        print(f"  {dr_key}: {actual} ({status})")
        if actual != expected:
            all_ok = False

    conn.close()

    if not all_ok:
        print("\nERROR: Verification failed — colors were not written correctly.", file=sys.stderr)
        sys.exit(1)

    print("Dark Reader colors updated successfully.")


if __name__ == "__main__":
    main()
