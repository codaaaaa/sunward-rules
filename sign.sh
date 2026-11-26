#!/usr/bin/env bash
# Run in Git Bash from this folder after every change to rules.json.
# Checks the file, signs it, then you commit and push both files.
set -e
KEY="$HOME/sunward-keys/sunward-rules-private.pem"
[ -f "$KEY" ] || { echo "No private key at $KEY. Run make-keys.sh first."; exit 1; }
python -c "import json,sys; json.load(open('rules.json',encoding='utf-8'))" 2>/dev/null \
  || python3 -c "import json,sys; json.load(open('rules.json',encoding='utf-8'))" 2>/dev/null \
  || { echo "rules.json isn't valid JSON (a missing comma or quote?). Not signed."; exit 1; }
openssl dgst -sha256 -sign "$KEY" -out rules.json.sig rules.json
echo "Signed. Now: git add rules.json rules.json.sig && git commit -m \"Rules vN\" && git push"
