#!/usr/bin/env python3
"""Resize assets/app_store screenshots for App Store Connect upload sizes."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "assets" / "app_store"
IPHONE_SIZE = (1242, 2688)  # 6.5" display portrait
IPAD_SIZE = (2048, 2732)  # 13" / 12.9" display portrait
BG = (27, 107, 94)  # matches app branding in generate_google_play_assets.py
JPEG_QUALITY = 92


def cover_resize(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    target_w, target_h = size
    src_w, src_h = img.size
    scale = max(target_w / src_w, target_h / src_h)
    resized = img.resize(
        (round(src_w * scale), round(src_h * scale)), Image.Resampling.LANCZOS
    )
    left = (resized.width - target_w) // 2
    top = (resized.height - target_h) // 2
    return resized.crop((left, top, left + target_w, top + target_h))


def fit_on_canvas(img: Image.Image, size: tuple[int, int], bg: tuple[int, int, int]) -> Image.Image:
    target_w, target_h = size
    src_w, src_h = img.size
    scale = min(target_w / src_w, target_h / src_h)
    fitted = img.resize(
        (round(src_w * scale), round(src_h * scale)), Image.Resampling.LANCZOS
    )
    canvas = Image.new("RGB", size, bg)
    x = (target_w - fitted.width) // 2
    y = (target_h - fitted.height) // 2
    if fitted.mode == "RGBA":
        canvas.paste(fitted, (x, y), fitted)
    else:
        canvas.paste(fitted, (x, y))
    return canvas


def source_images() -> list[Path]:
    exts = {".jpeg", ".jpg", ".png"}
    return sorted(
        p
        for p in SRC_DIR.iterdir()
        if p.is_file() and p.suffix.lower() in exts and p.parent == SRC_DIR
    )


def main() -> None:
    iphone_dir = SRC_DIR / "iphone"
    ipad_dir = SRC_DIR / "ipad"
    iphone_dir.mkdir(parents=True, exist_ok=True)
    ipad_dir.mkdir(parents=True, exist_ok=True)

    for path in source_images():
        img = Image.open(path).convert("RGB")
        iphone_out = cover_resize(img, IPHONE_SIZE)
        ipad_out = fit_on_canvas(img, IPAD_SIZE, BG)

        out_name = path.name
        iphone_path = iphone_dir / out_name
        ipad_path = ipad_dir / out_name

        iphone_out.save(iphone_path, "JPEG", quality=JPEG_QUALITY, optimize=True)
        ipad_out.save(ipad_path, "JPEG", quality=JPEG_QUALITY, optimize=True)
        print(f"{out_name}: iphone {iphone_out.size}, ipad {ipad_out.size}")

    print(f"\nWrote {len(source_images())} file(s) to {iphone_dir.relative_to(ROOT)} and {ipad_dir.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
