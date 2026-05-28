use crate::config::EffectsConfig;
use image::RgbaImage;
use tiny_skia::{
    BlendMode, Color, FillRule, Paint, Path, PathBuilder, Pixmap, PixmapPaint, Transform,
};

pub fn apply_effects(img: RgbaImage, cfg: &EffectsConfig) -> RgbaImage {
    let img = if cfg.rounded_corners {
        apply_rounded_corners(img, cfg.corner_radius)
    } else {
        img
    };
    if cfg.drop_shadow {
        apply_drop_shadow(
            img,
            cfg.shadow_blur_radius,
            cfg.shadow_offset_x,
            cfg.shadow_offset_y,
            cfg.shadow_color,
        )
    } else {
        img
    }
}

pub fn apply_rounded_corners(img: RgbaImage, radius: f32) -> RgbaImage {
    let (w, h) = img.dimensions();
    let mut mask = Pixmap::new(w, h).expect("mask pixmap");
    let path = rounded_rect_path(0.0, 0.0, w as f32, h as f32, radius);
    let mut paint = Paint::default();
    paint.set_color(Color::WHITE);
    paint.anti_alias = true;
    mask.fill_path(
        &path,
        &paint,
        FillRule::Winding,
        Transform::identity(),
        None,
    );

    let mut pixmap = rgba_image_to_pixmap(&img);
    let dst_paint = PixmapPaint {
        blend_mode: BlendMode::DestinationIn,
        ..Default::default()
    };
    pixmap.draw_pixmap(0, 0, mask.as_ref(), &dst_paint, Transform::identity(), None);
    pixmap_to_rgba_image(pixmap)
}

pub fn apply_drop_shadow(
    img: RgbaImage,
    blur_radius: f32,
    offset_x: f32,
    offset_y: f32,
    // blur_passes: u32,
    shadow_color: [u8; 4],
) -> RgbaImage {
    let (iw, ih) = img.dimensions();
    let br = blur_radius.ceil() as u32;
    let bp = 1;
    // Original idea
    // let spread = br * bp;
    // Claude is hallucinating but let's try it **Worked btw**
    let spread = (br as f32 * (bp as f32).sqrt() * 2.0).ceil() as u32;

    let extra_left = spread + (-offset_x).max(0.0).ceil() as u32;
    let extra_top = spread + (-offset_y).max(0.0).ceil() as u32;
    let extra_right = spread + offset_x.max(0.0).ceil() as u32;
    let extra_bottom = spread + offset_y.max(0.0).ceil() as u32;

    let canvas_w = iw + extra_left + extra_right;
    let canvas_h = ih + extra_top + extra_bottom;

    let mut shadow_pixmap = Pixmap::new(canvas_w, canvas_h).expect("shadow pixmap");
    let img_pixmap = rgba_image_to_pixmap(&img);
    let shadow_x = (extra_left as f32 + offset_x) as i32;
    let shadow_y = (extra_top as f32 + offset_y) as i32;

    let sp = PixmapPaint {
        blend_mode: BlendMode::Source,
        ..Default::default()
    };
    shadow_pixmap.draw_pixmap(
        shadow_x,
        shadow_y,
        img_pixmap.as_ref(),
        &sp,
        Transform::identity(),
        None,
    );

    tint_pixmap_as_shadow(&mut shadow_pixmap, shadow_color);

    // Shadow
    let shadow_img = pixmap_to_rgba_image(shadow_pixmap);
    // Shadow blur
    let blurred = box_blur_rgba(&shadow_img, br, bp);
    // Shadow pos
    let blurred_pixmap = rgba_image_to_pixmap(&blurred);

    let mut canvas = Pixmap::new(canvas_w, canvas_h).expect("canvas pixmap");
    let p = PixmapPaint {
        blend_mode: BlendMode::Source,
        ..Default::default()
    };
    canvas.draw_pixmap(
        0,
        0,
        blurred_pixmap.as_ref(),
        &p,
        Transform::identity(),
        None,
    );

    let p2 = PixmapPaint {
        blend_mode: BlendMode::SourceOver,
        ..Default::default()
    };
    canvas.draw_pixmap(
        extra_left as i32,
        extra_top as i32,
        img_pixmap.as_ref(),
        &p2,
        Transform::identity(),
        None,
    );

    pixmap_to_rgba_image(canvas)
}

fn rounded_rect_path(x: f32, y: f32, w: f32, h: f32, r: f32) -> Path {
    let r = r.min(w / 2.0).min(h / 2.0);
    let mut pb = PathBuilder::new();
    pb.move_to(x + r, y);
    pb.line_to(x + w - r, y);
    pb.quad_to(x + w, y, x + w, y + r);
    pb.line_to(x + w, y + h - r);
    pb.quad_to(x + w, y + h, x + w - r, y + h);
    pb.line_to(x + r, y + h);
    pb.quad_to(x, y + h, x, y + h - r);
    pb.line_to(x, y + r);
    pb.quad_to(x, y, x + r, y);
    pb.close();
    pb.finish().expect("rounded rect path")
}

// Shadow pos
fn rgba_image_to_pixmap(img: &RgbaImage) -> Pixmap {
    let (w, h) = img.dimensions();
    let mut pixmap = Pixmap::new(w, h).expect("pixmap alloc");
    let pixels = pixmap.pixels_mut();
    for (i, px) in img.pixels().enumerate() {
        let [r, g, b, a] = px.0;
        let af = a as f32 / 255.0;
        pixels[i] = tiny_skia::PremultipliedColorU8::from_rgba(
            (r as f32 * af) as u8,
            (g as f32 * af) as u8,
            (b as f32 * af) as u8,
            a,
        )
        .unwrap_or(tiny_skia::PremultipliedColorU8::TRANSPARENT);
    }
    pixmap
}

// Shadow
fn pixmap_to_rgba_image(pixmap: Pixmap) -> RgbaImage {
    let (w, h) = (pixmap.width(), pixmap.height());
    let mut out = RgbaImage::new(w, h);
    for (i, px) in pixmap.pixels().iter().enumerate() {
        let x = (i as u32) % w;
        let y = (i as u32) / w;
        let a = px.alpha();
        let (r, g, b) = if a == 0 {
            (0, 0, 0)
        } else {
            let af = a as f32 / 255.0;
            (
                (px.red() as f32 / af).round().min(255.0) as u8,
                (px.green() as f32 / af).round().min(255.0) as u8,
                (px.blue() as f32 / af).round().min(255.0) as u8,
            )
        };
        out.put_pixel(x, y, image::Rgba([r, g, b, a]));
    }
    out
}

// Shadow blur
fn box_blur_rgba(img: &RgbaImage, radius: u32, bp: u32) -> RgbaImage {
    if radius == 0 {
        return img.clone();
    }
    let mut buf = img.clone();
    for _ in 0..bp {
        buf = sliding_horizontal(&buf, radius);
        buf = sliding_vertical(&buf, radius);
    }
    buf
}

fn sliding_horizontal(img: &RgbaImage, radius: u32) -> RgbaImage {
    let (w, h) = img.dimensions();
    let r = radius as i32;
    let diam = (2 * r + 1) as u32;
    let mut out = RgbaImage::new(w, h);

    for y in 0..h {
        let mut sr = 0u32;
        let mut sg = 0u32;
        let mut sb = 0u32;
        let mut sa = 0u32;

        for dx in -r..=r {
            let sx = dx.clamp(0, w as i32 - 1) as u32;
            let p = img.get_pixel(sx, y).0;
            sr += p[0] as u32;
            sg += p[1] as u32;
            sb += p[2] as u32;
            sa += p[3] as u32;
        }

        for x in 0..w {
            out.put_pixel(
                x,
                y,
                image::Rgba([
                    (sr / diam) as u8,
                    (sg / diam) as u8,
                    (sb / diam) as u8,
                    (sa / diam) as u8,
                ]),
            );

            let remove_x = (x as i32 - r).clamp(0, w as i32 - 1) as u32;
            let add_x = (x as i32 + r + 1).clamp(0, w as i32 - 1) as u32;
            let rp = img.get_pixel(remove_x, y).0;
            let ap = img.get_pixel(add_x, y).0;
            sr = sr.saturating_sub(rp[0] as u32) + ap[0] as u32;
            sg = sg.saturating_sub(rp[1] as u32) + ap[1] as u32;
            sb = sb.saturating_sub(rp[2] as u32) + ap[2] as u32;
            sa = sa.saturating_sub(rp[3] as u32) + ap[3] as u32;
        }
    }
    out
}

fn tint_pixmap_as_shadow(pixmap: &mut Pixmap, color: [u8; 4]) {
    let [sr, sg, sb, _] = color;
    for px in pixmap.pixels_mut() {
        let a = px.alpha();
        if a > 0 {
            let af = a as f32 / 255.0;
            *px = tiny_skia::PremultipliedColorU8::from_rgba(
                (sr as f32 * af) as u8,
                (sg as f32 * af) as u8,
                (sb as f32 * af) as u8,
                a,
            )
            .unwrap_or(tiny_skia::PremultipliedColorU8::TRANSPARENT);
        }
    }
}

fn sliding_vertical(img: &RgbaImage, radius: u32) -> RgbaImage {
    let (w, h) = img.dimensions();
    let r = radius as i32;
    let diam = (2 * r + 1) as u32;
    let mut out = RgbaImage::new(w, h);

    for x in 0..w {
        let mut sr = 0u32;
        let mut sg = 0u32;
        let mut sb = 0u32;
        let mut sa = 0u32;

        for dy in -r..=r {
            let sy = dy.clamp(0, h as i32 - 1) as u32;
            let p = img.get_pixel(x, sy).0;
            sr += p[0] as u32;
            sg += p[1] as u32;
            sb += p[2] as u32;
            sa += p[3] as u32;
        }

        for y in 0..h {
            out.put_pixel(
                x,
                y,
                image::Rgba([
                    (sr / diam) as u8,
                    (sg / diam) as u8,
                    (sb / diam) as u8,
                    (sa / diam) as u8,
                ]),
            );

            let remove_y = (y as i32 - r).clamp(0, h as i32 - 1) as u32;
            let add_y = (y as i32 + r + 1).clamp(0, h as i32 - 1) as u32;
            let rp = img.get_pixel(x, remove_y).0;
            let ap = img.get_pixel(x, add_y).0;
            sr = sr.saturating_sub(rp[0] as u32) + ap[0] as u32;
            sg = sg.saturating_sub(rp[1] as u32) + ap[1] as u32;
            sb = sb.saturating_sub(rp[2] as u32) + ap[2] as u32;
            sa = sa.saturating_sub(rp[3] as u32) + ap[3] as u32;
        }
    }
    out
}
