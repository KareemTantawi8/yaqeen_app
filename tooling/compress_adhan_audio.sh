#!/usr/bin/env bash
# Re-encode bundled Adhan MP3s to 64 kbps mono (needs ffmpeg).
# Saves ~3–4 MB; run before release if you want smaller APK assets.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/assets/audio/adhan"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Install ffmpeg first: brew install ffmpeg"
  exit 1
fi

for name in makkah madinah; do
  src="$DIR/$name.mp3"
  tmp="$DIR/$name.tmp.mp3"
  [[ -f "$src" ]] || { echo "Missing $src"; exit 1; }
  ffmpeg -y -i "$src" -ac 1 -ar 22050 -b:a 64k "$tmp"
  mv "$tmp" "$src"
  echo "Compressed $name.mp3 ($(du -h "$src" | cut -f1))"
done

echo "Done. Rebuild the app bundle."
