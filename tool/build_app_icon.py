"""
Build a polished, store-ready master app icon for the Yaqeen app.

Output files (all 1024x1024 PNG):
- assets/icons/app_icon.png             -> master icon (opaque, full bleed)
- assets/icons/app_icon_foreground.png  -> Android adaptive foreground (transparent)
- assets/icons/app_icon_background.png  -> Android adaptive background (solid gradient)
- assets/icons/store_icon_1024.png      -> Same as master, kept as Play Store / App Store listing

Source logo: assets/images/Yaqeen.png (white logo on transparent background).
The script preserves the original brand identity (Arabic "يقين" + open book + stars)
while presenting it on a refined radial-gradient teal background with proper safe area.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "images" / "Yaqeen.png"
OUT_DIR = ROOT / "assets" / "icons"
OUT_DIR.mkdir(parents=True, exist_ok=True)

CANVAS = 1024

BRAND_DARK = (16, 74, 67)
BRAND_MID = (31, 107, 97)
BRAND_LIGHT = (52, 142, 130)


def _lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def make_radial_background(size: int = CANVAS) -> Image.Image:
    """Subtle radial gradient: brighter teal at the center, deeper teal at the corners."""
    bg = Image.new("RGB", (size, size), BRAND_DARK)
    px = bg.load()
    cx = cy = size / 2.0
    max_r = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            r = math.hypot(x - cx, y - cy) / max_r
            r = min(max(r, 0.0), 1.0)
            if r < 0.5:
                t = r / 0.5
                color = _lerp(BRAND_LIGHT, BRAND_MID, t)
            else:
                t = (r - 0.5) / 0.5
                color = _lerp(BRAND_MID, BRAND_DARK, t)
            px[x, y] = color
    return bg


def _islamic_star_overlay(size: int) -> Image.Image:
    """A very faint 8-point star ring overlay to add subtle depth without competing with the logo."""
    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cx = cy = size / 2.0
    outer = size * 0.46
    inner = size * 0.38
    color = (255, 255, 255, 14)

    def square(angle_deg: float, r: float):
        pts = []
        for k in range(4):
            theta = math.radians(angle_deg + k * 90)
            pts.append((cx + r * math.cos(theta), cy + r * math.sin(theta)))
        return pts

    draw.polygon(square(45, outer), outline=color, width=3)
    draw.polygon(square(0, outer), outline=color, width=3)
    draw.polygon(square(22.5, inner), outline=(255, 255, 255, 8), width=2)
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=0.5))
    return overlay


def load_logo_white(target_height: int) -> Image.Image:
    """Load the brand logo, normalize all visible pixels to pure white while preserving alpha."""
    logo = Image.open(SRC).convert("RGBA")
    bbox = logo.getbbox()
    logo = logo.crop(bbox)
    r, g, b, a = logo.split()
    white = Image.new("L", logo.size, 255)
    logo = Image.merge("RGBA", (white, white, white, a))
    w, h = logo.size
    scale = target_height / h
    new_size = (max(1, int(w * scale)), target_height)
    return logo.resize(new_size, Image.LANCZOS)


def add_soft_glow(canvas: Image.Image, logo: Image.Image, paste_xy):
    """Add a subtle white glow behind the logo for premium depth."""
    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    _, _, _, alpha = logo.split()
    soft = Image.new("RGBA", logo.size, (255, 255, 255, 70))
    soft.putalpha(alpha)
    soft = soft.filter(ImageFilter.GaussianBlur(radius=24))
    glow.paste(soft, paste_xy, soft)
    canvas.alpha_composite(glow)


def build_master() -> Image.Image:
    """Compose the opaque master icon used for iOS and as the Android legacy launcher.

    Logo is rendered large (≈84% of canvas height) so the brand reads clearly even at
    the tiny home-screen sizes. We still keep ~8% padding on every edge so neither iOS'
    rounded-rect mask nor Android's legacy circular mask clip the artwork.
    """
    bg = make_radial_background(CANVAS).convert("RGBA")
    bg.alpha_composite(_islamic_star_overlay(CANVAS))

    logo_height = int(CANVAS * 0.84)
    logo = load_logo_white(logo_height)
    lw, lh = logo.size
    paste_xy = ((CANVAS - lw) // 2, (CANVAS - lh) // 2)

    add_soft_glow(bg, logo, paste_xy)
    bg.paste(logo, paste_xy, logo)
    return bg


def build_adaptive_foreground() -> Image.Image:
    """Transparent canvas with the logo filling most of the PNG.

    flutter_launcher_icons wraps this drawable in an `<inset android:inset="16%"/>`
    inside `ic_launcher.xml`, which already enforces the Android adaptive-icon safe
    zone. So the foreground PNG itself should be filled almost edge-to-edge with the
    artwork — that way the final on-device logo is as large as possible while still
    safe from the launcher mask.
    """
    fg = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    logo_height = int(CANVAS * 0.92)
    logo = load_logo_white(logo_height)
    lw, lh = logo.size
    paste_xy = ((CANVAS - lw) // 2, (CANVAS - lh) // 2)
    fg.paste(logo, paste_xy, logo)
    return fg


def build_adaptive_background() -> Image.Image:
    return make_radial_background(CANVAS).convert("RGBA")


def save_no_alpha(img: Image.Image, path: Path):
    """Save as opaque PNG (no alpha) — required for iOS App Store icons."""
    rgb = img.convert("RGB")
    rgb.save(path, format="PNG", optimize=True)


def save_png(img: Image.Image, path: Path):
    img.save(path, format="PNG", optimize=True)


STORE_DIR = ROOT / "store"


def build_feature_graphic() -> Image.Image:
    """Google Play 1024x500 feature graphic — wide hero with brand + logo."""
    width, height = 1024, 500
    base = Image.new("RGB", (width, height), BRAND_DARK).convert("RGBA")

    radial = make_radial_background(max(width, height)).convert("RGBA")
    radial = radial.crop(((radial.width - width) // 2, (radial.height - height) // 2,
                          (radial.width + width) // 2, (radial.height + height) // 2))
    base.alpha_composite(radial)

    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cx, cy = width * 0.78, height * 0.5
    for r, alpha in [(280, 14), (220, 18), (160, 22)]:
        draw.polygon([
            (cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)
        ], outline=(255, 255, 255, alpha), width=3)
        offset = r * 0.92
        draw.polygon([
            (cx - offset, cy - offset), (cx + offset, cy - offset),
            (cx + offset, cy + offset), (cx - offset, cy + offset)
        ], outline=(255, 255, 255, alpha), width=3)
    overlay = overlay.filter(ImageFilter.GaussianBlur(radius=1))
    base.alpha_composite(overlay)

    logo_h = int(height * 0.86)
    logo = load_logo_white(logo_h)
    lw, lh = logo.size
    paste_xy = (int(width * 0.07), (height - lh) // 2)
    add_soft_glow(base, logo, paste_xy)
    base.paste(logo, paste_xy, logo)
    return base


def main():
    master = build_master()
    save_no_alpha(master, OUT_DIR / "app_icon.png")
    save_no_alpha(master, OUT_DIR / "store_icon_1024.png")

    fg = build_adaptive_foreground()
    save_png(fg, OUT_DIR / "app_icon_foreground.png")

    bg = build_adaptive_background()
    save_no_alpha(bg, OUT_DIR / "app_icon_background.png")

    STORE_DIR.mkdir(parents=True, exist_ok=True)
    save_no_alpha(master, STORE_DIR / "app_store_icon_1024.png")

    play_512 = master.resize((512, 512), Image.LANCZOS)
    save_no_alpha(play_512, STORE_DIR / "play_store_icon_512.png")

    feature = build_feature_graphic()
    save_no_alpha(feature, STORE_DIR / "play_feature_graphic_1024x500.png")

    print("Wrote app icons:")
    for name in ("app_icon.png", "store_icon_1024.png", "app_icon_foreground.png", "app_icon_background.png"):
        p = OUT_DIR / name
        print(f"  {p.relative_to(ROOT)}  ({p.stat().st_size/1024:.1f} KB)")
    print("\nWrote store-listing assets:")
    for name in ("app_store_icon_1024.png", "play_store_icon_512.png", "play_feature_graphic_1024x500.png"):
        p = STORE_DIR / name
        print(f"  {p.relative_to(ROOT)}  ({p.stat().st_size/1024:.1f} KB)")


if __name__ == "__main__":
    main()
