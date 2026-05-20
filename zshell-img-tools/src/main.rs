mod config;
mod effects;

use anyhow::{Context, Result, bail};
use std::io::Write as _;
use std::process::{Command, Stdio};

/// CLI overrides that map 1:1 to `EffectsConfig` fields.
/// All fields are `Option<T>` so we can tell "not supplied" from any concrete value.
#[derive(Default)]
struct CliOverrides {
    rounded_corners: Option<bool>,
    corner_radius: Option<f32>,
    drop_shadow: Option<bool>,
    shadow_blur_radius: Option<f32>,
    shadow_offset_x: Option<f32>,
    shadow_offset_y: Option<f32>,
    /// Accepted as four comma-separated u8 values, e.g. `255,0,0,200`
    shadow_color: Option<[u8; 4]>,
}

fn parse_bool(s: &str) -> Result<bool> {
    match s.to_lowercase().as_str() {
        "true" | "1" | "yes" => Ok(true),
        "false" | "0" | "no" => Ok(false),
        other => bail!("Expected a boolean (true/false), got '{other}'"),
    }
}

fn parse_shadow_color(s: &str) -> Result<[u8; 4]> {
    let parts: Vec<&str> = s.split(',').collect();
    if parts.len() != 4 {
        bail!("--shadow_color expects four comma-separated u8 values, e.g. 255,0,0,200");
    }
    let r = parts[0]
        .trim()
        .parse::<u8>()
        .context("shadow_color red channel")?;
    let g = parts[1]
        .trim()
        .parse::<u8>()
        .context("shadow_color green channel")?;
    let b = parts[2]
        .trim()
        .parse::<u8>()
        .context("shadow_color blue channel")?;
    let a = parts[3]
        .trim()
        .parse::<u8>()
        .context("shadow_color alpha channel")?;
    Ok([r, g, b, a])
}

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().skip(1).collect();

    let mut image_path: Option<String> = None;
    let mut overrides = CliOverrides::default();

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--image" => {
                i += 1;
                image_path = Some(
                    args.get(i)
                        .cloned()
                        .context("Expected a path after --image")?,
                );
            }
            "--rounded_corners" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected true/false after --rounded_corners")?;
                overrides.rounded_corners = Some(parse_bool(val)?);
            }
            "--corner_radius" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected a number after --corner_radius")?;
                overrides.corner_radius = Some(
                    val.parse::<f32>()
                        .context("--corner_radius must be a number")?,
                );
            }
            "--drop_shadow" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected true/false after --drop_shadow")?;
                overrides.drop_shadow = Some(parse_bool(val)?);
            }
            "--shadow_blur_radius" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected a number after --shadow_blur_radius")?;
                overrides.shadow_blur_radius = Some(
                    val.parse::<f32>()
                        .context("--shadow_blur_radius must be a number")?,
                );
            }
            "--shadow_offset_x" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected a number after --shadow_offset_x")?;
                overrides.shadow_offset_x = Some(
                    val.parse::<f32>()
                        .context("--shadow_offset_x must be a number")?,
                );
            }
            "--shadow_offset_y" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected a number after --shadow_offset_y")?;
                overrides.shadow_offset_y = Some(
                    val.parse::<f32>()
                        .context("--shadow_offset_y must be a number")?,
                );
            }
            "--shadow_color" => {
                i += 1;
                let val = args
                    .get(i)
                    .context("Expected r,g,b,a after --shadow_color")?;
                overrides.shadow_color = Some(parse_shadow_color(val)?);
            }
            unknown => bail!("Unknown argument: {unknown}"),
        }
        i += 1;
    }

    let image_path = image_path.context("Missing --image <path>")?;

    let config = config::Config::load().context("Failed to load config")?;

    let mut effects = config.screenshot;
    if effects.mode == "auto" {
        if let Some(v) = overrides.rounded_corners {
            effects.rounded_corners = v;
        }
        if let Some(v) = overrides.corner_radius {
            effects.corner_radius = v;
        }
        if let Some(v) = overrides.drop_shadow {
            effects.drop_shadow = v;
        }
        if let Some(v) = overrides.shadow_blur_radius {
            effects.shadow_blur_radius = v;
        }
        if let Some(v) = overrides.shadow_offset_x {
            effects.shadow_offset_x = v;
        }
        if let Some(v) = overrides.shadow_offset_y {
            effects.shadow_offset_y = v;
        }
        if let Some(v) = overrides.shadow_color {
            effects.shadow_color = v;
        }
    }

    if let Err(e) = process_image(&image_path, &effects) {
        eprintln!("Error processing '{}': {e:#}", image_path);
    }

    Ok(())
}

fn process_image(path: &str, effects: &config::EffectsConfig) -> Result<()> {
    let img = image::open(path)
        .with_context(|| format!("Failed to open image '{path}'"))?
        .into_rgba8();

    let processed = effects::apply_effects(img, effects);

    let mut png_bytes: Vec<u8> = Vec::new();
    image::DynamicImage::ImageRgba8(processed)
        .write_to(
            &mut std::io::Cursor::new(&mut png_bytes),
            image::ImageFormat::Png,
        )
        .context("Failed to encode processed image as PNG")?;

    let mut child = Command::new("swappy")
        .args(["-f", "-"])
        .stdin(Stdio::piped())
        .spawn()
        .context("Failed to spawn swappy. Is it installed and in PATH?")?;

    child
        .stdin
        .take()
        .context("Failed to get swappy stdin")?
        .write_all(&png_bytes)
        .context("Failed to write image data to swappy")?;

    let status = child.wait().context("Failed to wait for swappy")?;

    if !status.success() {
        eprintln!(
            "swappy exited with non-zero status for '{}': {}",
            path, status
        );
    }

    Ok(())
}
