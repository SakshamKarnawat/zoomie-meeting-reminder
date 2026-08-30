#!/bin/bash
set -euo pipefail

REPO="SakshamKarnawat/zoomie-meeting-reminder"
ZIP_URL="https://github.com/${REPO}/releases/latest/download/Zoomie.zip"
DEST="/Applications/Zoomie.app"

echo
echo "  Installing Zoomie…"
echo

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "  Zoomie is a Mac app. This computer is not a Mac."
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "  Zoomie requires Apple Silicon (arm64)."
  echo "  This Mac is $(uname -m)."
  exit 1
fi

macos_major="$(sw_vers -productVersion | cut -d. -f1)"
if [[ "${macos_major}" -lt 14 ]]; then
  echo "  Zoomie needs macOS Sonoma or newer (14+)."
  echo "  This Mac has $(sw_vers -productVersion)."
  exit 1
fi

if [[ ! -w "/Applications" ]]; then
  mkdir -p "${HOME}/Applications"
  DEST="${HOME}/Applications/Zoomie.app"
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

echo "  Downloading…"
if ! curl -fL --progress-bar "${ZIP_URL}" -o "${tmpdir}/Zoomie.zip"; then
  echo
  echo "  Download failed. Check ${ZIP_URL}"
  exit 1
fi

echo "  Unpacking…"
unzip -q "${tmpdir}/Zoomie.zip" -d "${tmpdir}/out"
app="$(find "${tmpdir}/out" -name "Zoomie.app" -print -quit || true)"
if [[ -z "${app}" ]]; then
  echo "  Archive did not contain Zoomie.app."
  exit 1
fi

echo "  Putting Zoomie in Applications…"
osascript -e 'quit app "Zoomie"' >/dev/null 2>&1 || true
sleep 0.4
rm -rf "${DEST}"
ditto "${app}" "${DEST}"

echo "  Allowing the Mac to open it…"
xattr -rd com.apple.quarantine "${DEST}" 2>/dev/null || true

echo "  Opening Zoomie…"
open "${DEST}"

echo
echo "  Done."
echo
echo "  Look at the top-right of the screen for a small bird icon."
echo "  Click it → Settings…  Allow Calendar access if asked."
echo
echo "  If the Mac says it cannot open Zoomie:"
echo "  System Settings → Privacy & Security → Open Anyway"
echo
