# Google Play store graphics

Generated from `assets/icons/app_logo.png`. Regenerate anytime:

```bash
.venv_assets/bin/python tooling/generate_google_play_assets.py
```

## Files to upload in Play Console

| File | Size | Where in Play Console |
|------|------|------------------------|
| `app_icon_512.png` | 512×512 | **Store listing → App icon** (required) |
| `feature_graphic_1024x500.png` | 1024×500 | **Store listing → Feature graphic** (required) |
| `app_icon_1024.png` | 1024×1024 | Backup / high-res reference (not uploaded) |
| `promo_square_1200.png` | 1200×1200 | Optional promos / social (not required for first publish) |

## You still need (from the running app)

Take **phone screenshots** on a device or emulator (min. 2, recommended 4–8):

- Home (prayer times)
- Quran
- Azkar
- Qibla or Mosques

Regenerate from `assets/app_store/` sources:

```bash
.venv_assets/bin/python tooling/generate_google_play_screenshots.py
```

Output: `assets/google_play/screenshots/phone/` (**1080×2400** JPEG).

**Manual capture:** 1080×1920 or 1080×2400 (9:16 portrait), PNG or JPEG, each under 8 MB.

## Limits (Google Play)

- App icon: PNG/JPEG, **512×512**, max **1 MB**
- Feature graphic: PNG/JPEG, **1024×500**, max **1 MB**
