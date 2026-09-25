#!/bin/bash

BUN_BIN="$HOME/.bun/bin/bun"

if ! command -v bun &> /dev/null && [ ! -f "$BUN_BIN" ]; then
  echo "Bun not found. Installing via direct binary download..."
  mkdir -p "$HOME/.bun/bin"

  ARCH=$(uname -m)
  if [ "$ARCH" = "aarch64" ]; then
    BUN_ARCH="bun-linux-aarch64"
  else
    BUN_ARCH="bun-linux-x64"
  fi

  BUN_VERSION=$(curl -fsSL https://api.github.com/repos/oven-sh/bun/releases/latest \
    | python3 -c "import sys,json; print(json.load(sys.stdin)[\"tag_name\"])")

  curl -fsSL "https://github.com/oven-sh/bun/releases/download/${BUN_VERSION}/${BUN_ARCH}.zip" \
    -o /tmp/bun.zip

  python3 - "$BUN_ARCH" "$BUN_BIN" <<'PYEOF'
import sys, zipfile, os, shutil
arch, dest = sys.argv[1], sys.argv[2]
with zipfile.ZipFile("/tmp/bun.zip") as z:
    src = f"{arch}/bun"
    z.extract(src, "/tmp/")
os.chmod(f"/tmp/{src}", 0o755)
shutil.move(f"/tmp/{src}", dest)
PYEOF

  rm -f /tmp/bun.zip
  echo "Bun installed: $($BUN_BIN --version)"
fi

# Symlink bun into node_modules/.bin so yarn scripts can find it regardless of PATH
if [ -f "$BUN_BIN" ] && [ -d "./node_modules/.bin" ] && [ ! -f "./node_modules/.bin/bun" ]; then
  ln -sf "$BUN_BIN" "./node_modules/.bin/bun"
  ln -sf "$BUN_BIN" "./node_modules/.bin/bunx"
  echo "Symlinked bun into ./node_modules/.bin/"
fi
