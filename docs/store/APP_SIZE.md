# Reducing Yaqeen install size

## What you see vs what users download

| Artifact | Typical size | Notes |
|----------|--------------|--------|
| **`.aab` on disk** | ~50–70 MB | Contains all ABIs + debug symbols stripped separately |
| **Play download (one phone)** | ~25–40 MB | Play serves **arm64-only** split from the bundle |
| **Universal APK** | ~80 MB+ | Includes x86_64 + all ABIs — do **not** use for size estimates |

Always upload an **App Bundle** (`.aab`), not a fat APK.

Check real download size: Play Console → **App bundle explorer** → select a release → **Downloads** tab.

---

## Changes already applied in the project

1. **Removed Google Maps SDK** — mosque map uses OpenStreetMap (`flutter_map`). Saves ~15–25 MB.
2. **Adhan audio** — only **Makkah + Madinah** ship in the APK (~6 MB); other voices download on first use.
3. **Removed unused packages** — `clarity_flutter`, `google_maps_flutter`, `flutter_bloc`, `screenshot`, `dartz`, `cupertino_icons`.
4. **Android ABI filter** — `armeabi-v7a` + `arm64-v8a` only (no x86_64 in bundle).
5. **Release build** — `--obfuscate` + `--split-debug-info` in `tooling/build_release.sh`.

---

## Rebuild after size work

```bash
./tooling/build_release.sh
ls -lh build/app/outputs/bundle/release/app-release.aab
```

Optional size breakdown:

```bash
flutter build appbundle --release --analyze-size
```

---

## Further reductions (optional)

| Idea | Savings | Trade-off |
|------|---------|-----------|
| Compress `makkah.mp3` / `madinah.mp3` (64 kbps mono, ffmpeg) | ~3 MB | Slightly lower Adhan quality |
| Host extra Adhan voices on your CDN/Firebase Storage | ~0 in APK | You maintain URLs |
| `quran_with_tafsir` offline text (~8 MB) | Large | Needs online Quran API refactor |

---

## iOS

Archive size is similar drivers (Flutter engine + Quran data + 2 Adhan files). Remove Google Maps pods after `pod install` in `ios/`.

```bash
cd ios && pod install && cd ..
flutter build ipa --release
```
