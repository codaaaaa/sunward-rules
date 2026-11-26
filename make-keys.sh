#!/usr/bin/env bash
# Run ONCE, in Git Bash. Makes the signing keys for Sunward's rules file.
# Keep sunward-rules-private.pem secret and backed up. Never put it in any repo.
set -e
KEYDIR="$HOME/sunward-keys"
mkdir -p "$KEYDIR"
if [ -f "$KEYDIR/sunward-rules-private.pem" ]; then
  echo "Keys already exist in $KEYDIR. Not overwriting."; exit 1
fi
openssl ecparam -name prime256v1 -genkey -noout -out "$KEYDIR/sunward-rules-private.pem"
openssl ec -in "$KEYDIR/sunward-rules-private.pem" -pubout -outform DER 2>/dev/null | base64 -w0 > "$KEYDIR/public-key.txt"
echo
echo "Private key saved to: $KEYDIR/sunward-rules-private.pem  (back it up, keep it secret)"
echo
echo "Paste this into Rules.kt as PUBLIC_KEY:"
echo
cat "$KEYDIR/public-key.txt"; echo
