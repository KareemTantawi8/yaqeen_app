# Google Play Console — Yaqeen 1.1.0

**Package name:** `com.yaqeen.mobile`  
**Version name / code:** `1.1.0` / `3`

---

## Store listing (Main store listing)

| Field | Suggested value |
|-------|-----------------|
| **App name** | يقين |
| **Short description** (80 chars max) | رفيقك الإسلامي: قرآن، أذكار، أوقات صلاة، قبلة، مساجد، وأذان |
| **Full description** | See block below |
| **App icon** | `assets/google_play/app_icon_512.png` |
| **Feature graphic** | `assets/google_play/feature_graphic_1024x500.png` |
| **Phone screenshots** | `assets/google_play/screenshots/phone/` (min. 2, up to 8) |
| **Category** | Lifestyle or Books & Reference |
| **Tags** | Islam, Quran, Prayer, Muslim (as allowed by Play) |
| **Contact email** | Your real support email |
| **Privacy policy URL** | `https://kareemtantawi8.github.io/yaqeen_app/privacy.html` |

### Full description (Arabic — paste into Play Console)

```
يقين — تطبيق إسلامي مجاني باللغة العربية (واجهة من اليمين لليسار).

المميزات:
• أوقات الصلاة حسب موقعك مع تنبيهات وأذان (أصوات متعددة: مكة، المدينة، مشاري العفاسي، وغيرهم)
• القرآن الكريم — قراءة واستماع
• الأذكار والأدعية
• اتجاه القبلة
• مساجد قريبة
• تقويم هجري ومحتوى يومي

الإصدار 1.1 يحسّن موثوقية إشعارات الصلاة (جدولة 7 أيام)، إعدادات الأذان لكل صلاة، واستقرار التطبيق.

لا يتطلب التطبيق حساباً أو اشتراكاً. الموقع اختياري لأوقات الصلاة والقبلة.

الدعم: support@yaqeen.app
```

---

## Release (Production)

1. **Create new release** → upload `app-release.aab` from `flutter build appbundle --release`
2. **Release name** (internal): `1.1.0 (3)` or `Yaqeen 1.1`
3. **Release notes:** copy from [release-notes-1.1.0.md](./release-notes-1.1.0.md) (Arabic section)

---

## Data safety

Align with [app-store-connect.md](./app-store-connect.md) → Google Play Data safety:

| Data type | Collected? | Shared? | Purpose |
|-----------|------------|---------|---------|
| Location (approximate / precise) | Optional, user grants | With prayer-time APIs (e.g. Aladhan) | App functionality |
| Device or other IDs | FCM token | With Google (Firebase) | Push notifications |
| App activity | Prayer preferences stored locally | No | App functionality |

- **No ads**, **no sale of personal data**, **not primarily directed at children**

---

## Content rating

Complete the questionnaire honestly (religious content, no violence/gambling). Typical result: **Everyone** or regional equivalent.

---

## Target API level

Use the SDK versions from your current Flutter/Android toolchain (`targetSdk` from `flutter build appbundle` output). Play may require recent target API — rebuild before upload if Console warns.

---

## Testing tracks (recommended)

1. **Internal testing** — upload AAB, install via opt-in link, verify notifications + Adhan
2. **Closed testing** — small group of testers
3. **Production** — roll out after 24–48 h on internal track

---

## Graphics checklist

```bash
.venv_assets/bin/python tooling/generate_google_play_assets.py
.venv_assets/bin/python tooling/generate_google_play_screenshots.py
```

| File | Size |
|------|------|
| `app_icon_512.png` | 512×512 |
| `feature_graphic_1024x500.png` | 1024×500 |
| `screenshots/phone/*.jpeg` | 1080×2400 |
