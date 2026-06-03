#!/usr/bin/env python3
"""Generate Google Play listing graphics from assets/icons/app_logo.png."""

from __future__ import annotations

import os
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "icons" / "app_logo.png"
OUT = ROOT / "assets" / "google_play"


def make_gradient(w: int, h: int, c1=(27, 107, 94), c2=(13, 77, 68)) -> Image.Image:
    base = Image.new("RGB", (w, h))
    px = base.load()
    for y in range(h):
        for x in range(w):
            u, t = x / max(w - 1, 1), y / max(h - 1, 1)
            d = ((u - 0.5) ** 2 + (t - 0.45) ** 2) ** 0.5
            blend = min(1.0, d * 1.8)
            px[x, y] = tuple(int(c1[i] * (1 - blend) + c2[i] * blend) for i in range(3))
    return base


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    logo = Image.open(SRC).convert("RGBA")

    logo.resize((512, 512), Image.Resampling.LANCZOS).save(
        OUT / "app_icon_512.png", "PNG", optimize=True
    )
    logo.save(OUT / "app_icon_1024.png", "PNG", optimize=True)

    fw, fh = 1024, 500
    fg = make_gradient(fw, fh)
    pattern = logo.resize((fw, fw), Image.Resampling.LANCZOS)
    top = (fw - fh) // 2
    pattern = pattern.crop((0, top, fw, top + fh))
    pattern_rgb = Image.new("RGB", (fw, fh), (27, 107, 94))
    pattern_rgb.paste(pattern, mask=pattern.split()[3])
    fg = Image.blend(fg, pattern_rgb, 0.22)

    logo_h = int(fh * 0.82)
    center_logo = logo.resize((logo_h, logo_h), Image.Resampling.LANCZOS)
    fg_rgba = fg.convert("RGBA")
    fg_rgba.paste(center_logo, ((fw - logo_h) // 2, (fh - logo_h) // 2), center_logo)
    fg_rgba.save(OUT / "feature_graphic_1024x500.png", "PNG", optimize=True)

    pw = 1200
    promo = make_gradient(pw, pw)
    pl = logo.resize((int(pw * 0.72), int(pw * 0.72)), Image.Resampling.LANCZOS)
    promo_rgba = promo.convert("RGBA")
    promo_rgba.paste(pl, ((pw - pl.width) // 2, (pw - pl.height) // 2), pl)
    promo_rgba.save(OUT / "promo_square_1200.png", "PNG", optimize=True)

    for path in sorted(OUT.glob("*.png")):
        print(f"{path.name}: {path.stat().st_size // 1024} KB")


if __name__ == "__main__":
    main()
