#!/usr/bin/env bash
#
# Idempotent Cloud Agent bootstrap for Frappe Books.
#
# Runs after the repository is checked out. Prepares the exact toolchain the
# project pins (Node v20.18.1 + Yarn 1.x) and installs JS dependencies. The
# postinstall hook rebuilds the native `better-sqlite3` addon against Electron's
# ABI via `electron-rebuild`.
set -euo pipefail

# scripts/runner.sh (used by `yarn test`) has a zsh shebang, so zsh must exist.
if ! command -v zsh >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh
fi

# Node version pinned by the project (README "Pre-requisites" + CI workflows).
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm install 20.18.1
nvm alias default 20.18.1
nvm use 20.18.1

# Provide Yarn 1.x through Corepack without mutating package.json.
corepack enable
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export COREPACK_ENABLE_AUTO_PIN=0

# Install dependencies exactly as locked (postinstall runs electron-rebuild).
yarn install --frozen-lockfile
