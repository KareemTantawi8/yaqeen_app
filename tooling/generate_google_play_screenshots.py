#!/usr/bin/env python3
"""Resize assets/app_store screenshots for Google Play phone listing (9:16)."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "assets" / "app_store"
OUT_DIR = ROOT / "assets" / "google_play" / "screenshots" / "phone"
# Common Play Console phone slot (portrait 9:16)
PHONE_SIZE = (1080, 2400)
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


def source_images() -> list[Path]:
    exts = {".jpeg", ".jpg", ".png"}
    return sorted(
        p
        for p in SRC_DIR.iterdir()
        if p.is_file() and p.suffix.lower() in exts and p.parent == SRC_DIR
    )


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sources = source_images()
    if not sources:
        raise SystemExit(f"No screenshots in {SRC_DIR} (add JPEG/PNG at repo root of app_store/)")

    for path in sources:
        img = Image.open(path).convert("RGB")
        out = cover_resize(img, PHONE_SIZE)
        out_path = OUT_DIR / path.name
        out.save(out_path, "JPEG", quality=JPEG_QUALITY, optimize=True)
        print(f"{path.name}: {out.size} -> {out_path.relative_to(ROOT)}")

    print(f"\nWrote {len(sources)} file(s) to {OUT_DIR.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
