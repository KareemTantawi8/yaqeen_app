# App Store Connect – copy-paste answers for Yaqeen (يقين)

Use the Support and Privacy pages in this folder on **Notion** (or GitHub Pages — see [README.md](./README.md)). Paste the public links into App Store Connect.

---

## URLs (after you publish)

| Field | What to paste |
|-------|----------------|
| **Support URL** | Your public Support page link |
| **Privacy Policy URL** | Your public Privacy Policy link *(required)* |
| **Marketing URL** | Optional — website or landing page; can leave blank |

**Example (GitHub Pages, after setup):**

- Support: `https://kareemtantawi8.github.io/yaqeen_app/support.html`
- Privacy: `https://kareemtantawi8.github.io/yaqeen_app/privacy.html`

---

## App Information fields (from your screenshot)

### Keywords (max 100 characters)

```
quran,prayer,islam,muslim,azkar,qibla,adhan,hijri,mosque,tasbih,قرآن,صلاة,أذكار
```

*(99 characters — fits Apple’s 100-character limit.)*

### Version

```
1.0
```

*(Match `pubspec.yaml` → `version: 1.0.0+1`.)*

### Copyright (max 200 characters)

```
© 2026 Yaqeen App. All rights reserved.
```

Or with your legal name:

```
© 2026 Kareem Mahmoud. All rights reserved.
```

---

## App Privacy questionnaire (Apple)

Answer honestly in **App Store Connect → App Privacy**. Based on the current Yaqeen codebase:

### Does your app collect data?

**Yes** — limited data for app functionality (not for tracking ads).

### Data types to declare

| Category | Collected? | Linked to user? | Used for tracking? | Purpose |
|----------|------------|-----------------|--------------------|---------|
| **Precise Location** | Yes (if user grants permission) | No | No | App Functionality (prayer times, Qibla) |
| **Coarse Location** | Same as above | No | No | App Functionality |
| **Device ID** (push token via Firebase) | Yes | No | No | App Functionality (notifications) |
| **Product Interaction** | Optional — if you add analytics later | — | — | — |
| **Crash Data** | Only if you enable crash reporting | No | No | Analytics / App Functionality |
| **Contact Info** (email, name) | **No** for normal app use | — | — | — |
| **Health, Financial, etc.** | **No** | — | — | — |

### Tracking

**No** — the app does not track users across apps or websites for advertising (`NSPrivacyTracking` is false in the iOS privacy manifest).

### Third-party partners

Declare **Google (Firebase)** for push notifications if prompted.

---

## Google Play Data safety (summary)

Align with the same privacy policy:

- **Location:** Approximate / precise — optional, for prayer times & Qibla  
- **App activity:** Prayer tracker stored locally  
- **Device or other IDs:** FCM token for notifications  
- **Data shared:** Prayer location may be sent to prayer-time APIs (Aladhan)  
- **No ads, no sale of data**

---

## App Review Information → Notes (max 4,000 characters)

Copy the block below into **App Store Connect → App Review Information → Notes**.

```
Thank you for reviewing Yaqeen (يقين).

APP OVERVIEW
Yaqeen is a free Islamic companion app (Arabic UI, RTL). It provides prayer times, Quran reading/audio, Azkar (dhikr), Qibla direction, mosque listings, and prayer notifications. No account, login, or subscription is required to use the app.

HOW TO TEST (no demo account needed)
1. Launch the app and wait for the splash screen to finish.
2. When prompted, tap Allow for Location (used only for prayer times and Qibla) and Allow for Notifications (prayer/Adhan alerts). You may also test by denying permissions — the app still opens and shows default/fallback prayer times.
3. Bottom tabs (right to left in Arabic):
   • الرئيسية (Home) — prayer times, daily content, quick links to Qibla and Adhan
   • القرآن (Quran) — browse surahs; audio requires internet
   • الأذكار (Azkar) — dhikr categories
   • مساجد (Mosques) — nearby mosques (location optional)
   • المزيد (More/Settings) — theme toggle, share, other services
4. To test Qibla: from Home, open the Qibla/compass feature and allow location if asked.
5. To test audio: open Quran → select a surah → play audio (internet required).
6. To test notifications: allow notifications; prayer alerts are scheduled locally based on calculated prayer times.

PERMISSIONS (why we request them)
• Location (When In Use): Calculate accurate prayer times and Qibla direction for the reviewer’s region. We do not use location for advertising or tracking.
• Notifications: Deliver prayer-time and Adhan reminders only. No marketing push messages.
• Internet: Load Quran text/audio, Azkar content, and prayer-time data from public Islamic APIs.

BACKGROUND MODES
• audio — Quran recitation and Adhan playback continues when the user leaves the app during playback.
• remote-notification — Firebase Cloud Messaging delivers optional push notifications (prayer-related only).
• fetch — refreshes scheduled local prayer notifications when the app is backgrounded.

CONTENT & COMPLIANCE
• All content is Islamic religious/educational material suitable for general audiences.
• No user-generated content, no social features, no dating, no gambling, and no in-app purchases in this version.
• No login screen is shown in the consumer app flow.

OPTIONAL / HIDDEN FEATURES
A vendor/mosque dashboard route exists in the binary for future B2B use but is not linked from the main tab bar and is not required for review. Reviewers do not need credentials.

DEVICE NOTES
• Best tested on iPhone with network connection.
• Interface language is Arabic; layout is RTL.
• Support URL and Privacy Policy URL are provided in App Store Connect metadata.

If you need anything else during review, please contact: support@yaqeen.app
```

*(Replace support@yaqeen.app with your real email before submitting.)*

---

## Before you submit

1. Replace **support@yaqeen.app** in `support.md` and `privacy-policy.md` with your real email.
2. Publish both pages and test links in a private browser window.
3. Paste **Privacy Policy URL** in App Store Connect (required for review).
4. Paste **Support URL** in the same metadata section.
5. Paste the **Notes** block above into App Review Information.
