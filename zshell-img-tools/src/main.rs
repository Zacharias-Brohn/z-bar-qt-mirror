mod config;
mod effects;

use anyhow::{bail, Context, Result};
use std::io::Write as _;
use std::process::{Command, Stdio};

#[derive(Default)]
struct CliOverrides {
    rounding: Option<bool>,
    radius: Option<f32>,
    shadow: Option<bool>,
    shadow_blur: Option<f32>,
    shadow_offset_x: Option<f32>,
    shadow_offset_y: Option<f32>,
    // Accepted as four comma-separated u8 values, e.g. `255,0,0,200`
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
        bail!("--shadow-color expects four comma-separated u8 values, e.g. 255,0,0,200");
    }
    let r = parts[0]
        .trim()
        .parse::<u8>()
        .context("shadow-color red channel")?;
    let g = parts[1]
        .trim()
        .parse::<u8>()
        .context("shadow-color green channel")?;
    let b = parts[2]
        .trim()
        .parse::<u8>()
        .context("shadow-color blue channel")?;
    let a = parts[3]
        .trim()
        .parse::<u8>()
        .context("shadow-color alpha channel")?;
    Ok([r, g, b, a])
}

fn extract_image_path() -> Option<String> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    args.windows(2)
        .find(|w| w[0] == "--image")
        .map(|w| w[1].clone())
}

fn main() {
    if let Some(path) = extract_image_path() && let Err(e) = run() {
        eprintln!("Error: {}", e);
        push_image(&path).ok();
    }
}

fn run() -> Result<()> {
    let args: Vec<String> = std::env::args().skip(1).collect();

    let mut image_path: Option<String> = None;
    let mut overrides = CliOverrides::default();
    let mut scale: Option<f32> = None;

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--image" => {
                image_path = Some(next_arg(&args, &mut i, "--image")?);
            }
            "--rounding" => {
                let val = next_arg(&args, &mut i, "--rounding")?;
                overrides.rounding = Some(parse_bool(&val)?);
            }
            "--radius" => {
                let val = next_arg(&args, &mut i, "--radius")?;
                overrides.radius = Some(val.parse::<f32>().context("--radius must be a number")?);
            }
            "--shadow" => {
                let val = next_arg(&args, &mut i, "--shadow")?;
                overrides.shadow = Some(parse_bool(&val)?);
            }
            "--shadow-blur" => {
                let val = next_arg(&args, &mut i, "--shadow-blur")?;
                overrides.shadow_blur = Some(
                    val.parse::<f32>()
                        .context("--shadow-blur must be a number")?,
                );
            }
            "--shadow-offset-x" => {
                let val = next_arg(&args, &mut i, "--shadow-offset-x")?;
                overrides.shadow_offset_x = Some(
                    val.parse::<f32>()
                        .context("--shadow-offset-x must be a number")?,
                );
            }
            "--shadow-offset-y" => {
                let val = next_arg(&args, &mut i, "--shadow-offset-y")?;
                overrides.shadow_offset_y = Some(
                    val.parse::<f32>()
                        .context("--shadow-offset-y must be a number")?,
                );
            }
            "--shadow-color" => {
                let val = next_arg(&args, &mut i, "--shadow-color")?;
                overrides.shadow_color = Some(parse_shadow_color(&val)?);
            }
            "--scale" => {
                let val = next_arg(&args, &mut i, "--scale")?;
                scale = Some(val.parse::<f32>().context("--scale must be a number")?);
            }
            unknown => bail!("Unknown argument: {}", unknown),
        }

        i += 1;
    }

    let image_path = image_path.context("Missing --image <path>")?;

    // Check if any arguments were provided
    let cli_args_provided = overrides.rounding.is_some()
        || overrides.radius.is_some()
        || overrides.shadow.is_some()
        || overrides.shadow_blur.is_some()
        || overrides.shadow_offset_x.is_some()
        || overrides.shadow_offset_y.is_some()
        || overrides.shadow_color.is_some();
    let mut effects = if cli_args_provided {
        // If all args provided
        let rounding = overrides.rounding.context("Missing --rounding")?;
        let radius = overrides.radius.context("Missing --radius")?;
        let shadow = overrides.shadow.context("Missing --shadow")?;
        let shadow_blur = overrides.shadow_blur.context("Missing --shadow-blur")?;
        let shadow_offset_x = overrides
            .shadow_offset_x
            .context("Missing --shadow-offset-x")?;
        let shadow_offset_y = overrides
            .shadow_offset_y
            .context("Missing --shadow-offset-y")?;
        let shadow_color = overrides.shadow_color.context("Missing --shadow-color")?;
        config::EffectsConfig {
            rounding,
            radius,
            shadow,
            shadow_blur,
            shadow_offset_x,
            shadow_offset_y,
            shadow_color,
        }
    } else {
        // If not all args were provided use config file
        let config = config::Config::load()?;
        config.screenshot
    };

    // if scale is set do
    if let Some(scale) = scale.filter(|&s| s != 1.0) {
        effects.radius *= scale;
        effects.shadow_blur *= scale;
        effects.shadow_offset_x *= scale;
        effects.shadow_offset_y *= scale;
    }

    if let Err(e) = process_image(&image_path, &effects) {
        eprintln!("Error processing '{}': {e:#}", image_path);
    }

    Ok(())
}

fn next_arg(args: &[String], i: &mut usize, flag: &str) -> Result<String> {
    *i += 1;

    let val = args
        .get(*i)
        .context(format!("Expected value after {}", flag))?;

    if val.starts_with('-') {
        bail!("Expected value after {}, found flag {}", flag, val);
    }

    Ok(val.clone())
}

fn push_image(path: &str) -> Result<()> {
    let img = image::open(path)
        .with_context(|| format!("Failed to open image '{path}'"))?
        .into_rgba8();

    let mut png_bytes: Vec<u8> = Vec::new();
    image::DynamicImage::ImageRgba8(img)
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

    // Writes the PNG bytes to swappy's stdin and then closes
    if let Some(mut stdin) = child.stdin.take() {
        stdin
            .write_all(&png_bytes)
            .context("Failed to write image data to swappy")?;
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

    // Writes the PNG bytes to swappy's stdin and then closes
    if let Some(mut stdin) = child.stdin.take() {
        stdin
            .write_all(&png_bytes)
            .context("Failed to write image data to swappy")?;
    }

    Ok(())
}
