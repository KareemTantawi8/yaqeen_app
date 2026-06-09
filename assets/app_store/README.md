# App Store screenshots

Source captures live in this folder (`722×1600`). Regenerate store-ready sizes:

```bash
.venv_assets/bin/python tooling/generate_app_store_screenshots.py
```

## Upload folders

| Folder | Size | App Store Connect slot |
|--------|------|------------------------|
| `iphone/` | **1242×2688** | iPhone → **6.5" Display** (portrait) |
| `ipad/` | **2048×2732** | iPad → **13" Display** (portrait) |

iPhone images are scaled to fill the frame (minimal crop). iPad images keep the full UI centered on a branded background.

## Files

Upload every JPEG from `iphone/` and `ipad/` (same filenames as the sources). Up to **10 screenshots** per device size in App Store Connect.

For **version 1.1.0** upload steps, see `docs/store/RELEASE-v1.1.0.md`.
