use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    #[serde(rename = "screenshot")]
    pub screenshot: EffectsConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EffectsConfig {
    pub mode: String,
    pub rounded_corners: bool,
    pub corner_radius: f32,
    pub drop_shadow: bool,
    pub shadow_blur_radius: f32,
    pub shadow_offset_x: f32,
    pub shadow_offset_y: f32,
    pub shadow_color: [u8; 4],
}

impl Config {
    pub fn config_path() -> Option<PathBuf> {
        let home = std::env::var("HOME").ok()?;
        Some(
            PathBuf::from(home)
                .join(".config")
                .join("zshell")
                .join("config.json"),
        )
    }

    pub fn load() -> Result<Self> {
        let path = Self::config_path().context("Could not determine HOME directory")?;
        Self::load_from(&path)
    }

    pub fn load_from(path: &PathBuf) -> Result<Self> {
        let raw = std::fs::read_to_string(path)
            .with_context(|| format!("Failed to read config at {}", path.display()))?;
        serde_json::from_str(&raw)
            .with_context(|| format!("Failed to parse JSON config at {}", path.display()))
    }
}
