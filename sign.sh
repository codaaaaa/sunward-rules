#!/usr/bin/env bash
# Run in Git Bash from this folder after every change to rules.json.
# Checks the file, signs it, then you upload rules.json and rules.json.sig to GitHub.
set -e
cd "$(dirname "$0")"
KEY="$HOME/sunward-keys/sunward-rules-private.pem"
LAST="$HOME/sunward-keys/last-signed-version.txt"
[ -f "$KEY" ] || { echo "No private key at $KEY. Run make-keys.sh first."; exit 1; }

# The version must go up every time, or phones quietly ignore the new file
VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*[0-9]\+' rules.json | head -1 | grep -o '[0-9]\+$' || true)
[ -n "$VERSION" ] || { echo "Couldn't find \"version\" in rules.json. Not signed."; exit 1; }
if [ -f "$LAST" ] && [ "$VERSION" -le "$(cat "$LAST")" ]; then
  echo "\"version\" is $VERSION, but you already signed version $(cat "$LAST")."
  echo "Raise it to $(( $(cat "$LAST") + 1 )) or more, or phones will ignore this file. Not signed."
  exit 1
fi

# Check the file properly if Python is installed (Windows' fake "python" shortcut doesn't count)
PY=""
for p in python3 python py; do
  if command -v "$p" >/dev/null 2>&1 && "$p" -c "pass" >/dev/null 2>&1; then PY="$p"; break; fi
done
if [ -n "$PY" ]; then
  "$PY" - << 'PYEOF' || { echo "Not signed."; exit 1; }
import json, sys
KNOWN = {"com.instagram.android", "com.google.android.youtube", "com.zhiliaoapp.musically",
         "com.zhiliaoapp.musically.go", "com.snapchat.android", "com.facebook.katana"}
raw = open("rules.json", "rb").read()
if raw.startswith(b"\xef\xbb\xbf"):
    sys.exit("rules.json was saved 'UTF-8 with BOM'. In Notepad: File > Save as > Encoding: UTF-8.")
try:
    doc = json.loads(raw.decode("utf-8"))
except Exception as e:
    sys.exit(f"rules.json isn't valid JSON ({e}). A missing comma or quote?")
apps = doc.get("apps", {})
for pkg, entry in apps.items():
    if pkg not in KNOWN:
        sys.exit(f"Unknown app '{pkg}': a typo? Phones would ignore it.")
    if not isinstance(entry.get("enabled", True), bool):
        sys.exit(f"{pkg}: \"enabled\" must be true or false, with no quotes.")
off = [p for p, e in apps.items() if e.get("enabled", True) is False]
if off:
    print("Heads up, switched OFF for everyone: " + ", ".join(off))
PYEOF
else
  echo "(Python isn't installed, so the file's contents weren't checked. Double-check commas and quotes.)"
fi

openssl dgst -sha256 -sign "$KEY" -out rules.json.sig rules.json
echo "$VERSION" > "$LAST"
echo "Signed version $VERSION. Now upload rules.json and rules.json.sig to GitHub."
