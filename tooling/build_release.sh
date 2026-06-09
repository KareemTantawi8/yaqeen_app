#!/usr/bin/env bash
# Build release artifacts for Google Play (AAB) and iOS (IPA).
# Requires: Flutter SDK, android/key.properties for signed Android release.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Version from pubspec"
grep '^version:' pubspec.yaml

echo "==> flutter pub get"
flutter pub get

echo "==> Android App Bundle (Google Play)"
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
echo "    AAB: build/app/outputs/bundle/release/app-release.aab"
ls -lh build/app/outputs/bundle/release/app-release.aab 2>/dev/null || true

echo "==> iOS IPA (App Store / TestFlight)"
if [[ "$(uname -s)" == "Darwin" ]]; then
  (cd ios && pod install)
  flutter build ipa --release
  echo "    IPA: build/ios/ipa/*.ipa (or use Xcode Archive)"
else
  echo "    Skip IPA on non-macOS host"
fi

echo "==> Done"
