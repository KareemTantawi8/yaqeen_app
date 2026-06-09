# Yaqeen 1.1.0 — Store release checklist

**Version:** `1.1.0` · **Build:** `3` · **Package / bundle ID:** `com.yaqeen.mobile`

Complete these steps before uploading to **Google Play** and **App Store Connect**.

---

## 1. Version and identifiers

| Item | Value |
|------|--------|
| `pubspec.yaml` | `version: 1.1.0+3` |
| Android `versionName` / `versionCode` | `1.1.0` / `3` (from Flutter) |
| iOS `CFBundleShortVersionString` / `CFBundleVersion` | `1.1.0` / `3` |
| Android `applicationId` | `com.yaqeen.mobile` |
| iOS bundle ID | `com.yaqeen.mobile` |

**Important:** Store updates only work if the **same** app ID is already live. If v1 used a different package name (e.g. `com.yaqeen.app`), you cannot ship 1.1 as an update — you need a new listing or to keep the original ID.

---

## 2. Regenerate listing assets

From the project root (requires `.venv_assets` with Pillow — same as other tooling scripts):

```bash
.venv_assets/bin/python tooling/generate_google_play_assets.py
.venv_assets/bin/python tooling/generate_app_store_screenshots.py
.venv_assets/bin/python tooling/generate_google_play_screenshots.py
```

| Output | Use |
|--------|-----|
| `assets/google_play/app_icon_512.png` | Play Console → App icon |
| `assets/google_play/feature_graphic_1024x500.png` | Play Console → Feature graphic |
| `assets/google_play/screenshots/phone/*.jpeg` | Play Console → Phone screenshots |
| `assets/app_store/iphone/*.jpeg` | App Store Connect → iPhone 6.5" |
| `assets/app_store/ipad/*.jpeg` | App Store Connect → iPad 13" |

Refresh source captures in `assets/app_store/` (root JPEGs) if UI changed since last screenshots.

---

## 3. Legal URLs (both stores)

Publish support and privacy pages, then paste URLs:

- **Support:** `https://kareemtantawi8.github.io/yaqeen_app/support.html`
- **Privacy:** `https://kareemtantawi8.github.io/yaqeen_app/privacy.html`

Setup: [README.md](./README.md). Replace placeholder email in `support.md` / `privacy-policy.md` before publishing.

---

## 4. Release notes

Copy from [release-notes-1.1.0.md](./release-notes-1.1.0.md) into each store’s “What’s New” / Release notes field.

---

## 5. App size

See [APP_SIZE.md](./APP_SIZE.md). The upload `.aab` is smaller after removing Google Maps and duplicate Adhan files; Play serves an even smaller per-device download.

---

## 6. Android — Google Play

See [google-play-console.md](./google-play-console.md).

### Signing

1. Copy `android/key.properties.example` → `android/key.properties` (if not already).
2. Point `storeFile` to your upload keystore (`.jks` / `.keystore`). **Never commit** keystore or `key.properties`.

### Build upload artifact

```bash
flutter pub get
flutter build appbundle --release
```

Upload: `build/app/outputs/bundle/release/app-release.aab`

### Play Console

1. **Production** (or testing track) → **Create new release**
2. Upload **AAB** (version code **3** must be greater than any previous upload)
3. Paste **release notes** (Arabic)
4. Confirm **Data safety** still matches [app-store-connect.md](./app-store-connect.md) (location, device ID for FCM, no ads)
5. Store listing graphics from `assets/google_play/` if you changed branding

---

## 7. iOS — App Store Connect

See [app-store-connect.md](./app-store-connect.md).

### Build and upload

```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

Or open `ios/Runner.xcworkspace` in Xcode → **Product → Archive** → **Distribute App**.

### App Store Connect

1. **My Apps → Yaqeen → + Version** → `1.1`
2. **What’s New** — Arabic (and English if you maintain both)
3. Upload build **3** from Xcode / Transporter
4. Screenshots from `assets/app_store/iphone/` and `ipad/` if UI changed
5. **App Review Information → Notes** — use the block in `app-store-connect.md` (still valid for 1.1)
6. **Export compliance** — `ITSAppUsesNonExemptEncryption` is `false` (standard HTTPS only)

---

## 8. Firebase / push (both platforms)

Confirm Firebase project has:

- Android app: `com.yaqeen.mobile` (`android/app/google-services.json`)
- iOS app: `com.yaqeen.mobile` (`ios/Runner/GoogleService-Info.plist`)

Upload **APNs key** (.p8) in Firebase Console for iOS push if not already done.

---

## 9. Pre-submit smoke test (release build)

On a physical device with a **release** install:

- [ ] Cold start → prayer notifications schedule (allow location + notifications)
- [ ] Adhan settings → change voice, toggle prayers, test play
- [ ] Tap a prayer notification → app opens / Adhan flow
- [ ] Quran audio plays in background
- [ ] Qibla with location allowed
- [ ] No crash on deny location (fallback times)

---

## 10. After approval

- [ ] Tag git: `v1.1.0` (optional)
- [ ] Monitor Play Console / App Store Connect crashes
- [ ] Reply to first user reviews mentioning notifications if any issues

---

## Quick links

| Doc | Purpose |
|-----|---------|
| [google-play-console.md](./google-play-console.md) | Play listing fields |
| [app-store-connect.md](./app-store-connect.md) | App Store metadata & privacy |
| [release-notes-1.1.0.md](./release-notes-1.1.0.md) | What’s New text |
