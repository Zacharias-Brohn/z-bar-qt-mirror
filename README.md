<div align="center">
    <img src="/images/shell.png" alt="ZShell screenshot">
</div>

# ZShell

ZShell is a Hyprland-focused desktop shell built with Quickshell + Qt6/QML.

It includes a configurable top bar, launcher, notifications daemon + sidebar, wallpaper and dynamic color pipeline, lock screen, OSD widgets, dashboard, dock, desktop icons, and a separate greetd-compatible greeter.

## Highlights

- Multi-window shell layout driven by `Drawers/Windows.qml` and panel/interactions wrappers
- Configurable bar entries and popouts (audio, tray, network, power, resources, clock, active window)
- Launcher with app DB frequency tracking, action commands, fuzzy search modes, and wallpaper/scheme flows
- Notification server with persistence (`~/.local/state/zshell/notifs.json`) and sidebar UI
- Dynamic Material 3 palette generation from wallpaper, optional template rendering, terminal sequence application
- Lock module with PAM support, idle monitors, optional fingerprint integration, and blur background generation
- Additional modules: dock, desktop icons, dashboard, OSD, polkit agent, area picker/screenshot flow

## Project Layout

```text
.
├── shell.qml              # Main shell entry point (qs config: zshell)
├── Drawers/               # Window, panel, interaction composition
├── Modules/               # UI/feature modules (bar, launcher, lock, notifs, settings, etc.)
├── Config/                # JSON-backed config schema + serializers
├── Daemons/               # Notification/audio/network daemons
├── Helpers/               # Shared runtime helpers and integration glue
├── Paths/                 # Runtime paths (XDG + state/cache/data locations)
├── Plugins/ZShell/        # Native Qt/QML plugin (C++)
├── Greeter/               # Separate Quickshell greeter app and scripts
├── cli/                   # Python CLI (`zshell-cli`)
└── scripts/               # Utility scripts (greeter prep, updates, fuzzy helpers)
```

## Runtime Requirements

Core requirements:

- Qt6 + Quickshell
- Hyprland (Wayland session integration)
- Python 3 for scheme/wallpaper tooling

Used by major features (install as needed for your setup):

- `app2unit` (launcher app execution)
- `nmcli` (network integration)
- `brightnessctl`, `ddcutil` (brightness controls)
- `wl-copy`, `swappy` (picker/screenshot flow)
- `libqalculate` (launcher calculator)
- `PipeWire` + audio stack + `aubio`/`cava` paths for media visualization
- `gsettings` (optional GTK dark/light mode sync)

## Build and Install

### CMake (manual)

```bash
cmake -B build -G Ninja
ninja -C build
sudo ninja -C build install
```

Defaults from `CMakeLists.txt`:

- `ENABLE_MODULES="plugin;shell"`
- QML plugin install dir: `usr/lib/qt6/qml`
- shell config install dir: `etc/xdg/quickshell/zshell`
- greeter install dir: `etc/xdg/quickshell/zshell-greeter`

### Nix Flake

The flake exposes:

- `packages.<system>.zshell`
- `packages.<system>.zshell-cli`

Add it as an input in your system flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    z-bar-qt = {
      url = git+https://git.zach-dev.cc/zach/z-bar-qt.git
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

Full `flake.nix` example (`nixosConfigurations`):

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    z-bar-qt = {
      url = git+https://git.zach-dev.cc/zach/z-bar-qt.git
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ({ ... }: {
          environment.systemPackages = [
            inputs.z-bar-qt.packages.${system}.zshell
            inputs.z-bar-qt.packages.${system}.zshell-cli
          ];
        })
        ./configuration.nix
      ];
    };
  };
}
```

Then install shell + CLI from the flake packages:

```nix
{ pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in {
  environment.systemPackages = [
    inputs.z-bar-qt.packages.${system}.zshell
    inputs.z-bar-qt.packages.${system}.zshell-cli
  ];
}
```

If you use Home Manager, the same packages can be added to `home.packages`.

Run shell via wrapper binary:

```bash
zshell
```

CLI entrypoint:

```bash
zshell-cli
```

## Running

- Start shell directly with Quickshell config name: `qs -c zshell`
- Start through CLI helper: `zshell-cli shell start`
- Lock through IPC helper: `zshell-cli shell lock`

## Configuration

Primary config file:

- `~/.config/zshell/config.json`

Important state/cache files:

- `~/.local/state/zshell/scheme.json`
- `~/.local/state/zshell/wallpaper_path.json`
- `~/.local/state/zshell/notifs.json`
- `~/.local/state/zshell/apps.sqlite`
- `~/.cache/zshell/`

Config is hot-reloaded and saved through `Config/Config.qml` serializers. Top-level sections include:

- `general`
- `appearance`
- `background`
- `barConfig`
- `launcher`
- `services`
- `notifs`
- `sidebar`
- `utilities`
- `dashboard`
- `osd`
- `colors`
- `dock`

## Launcher Prefixes

Default prefixes are defined in `Config/Launcher.qml`:

- `actionPrefix`: `>`
- `specialPrefix`: `@`

Special app-search filters (`@` prefix by default):

- `@i ` app id/name
- `@c ` categories
- `@d ` description/comment
- `@e ` exec string
- `@w ` WM class
- `@g ` generic name
- `@k ` keywords
- `@t ` terminal-only apps

Action-driven flows (`>` prefix by default) include calculator, wallpaper picker, and scheme variant selection.

## CLI Commands

`zshell-cli` provides these subcommands:

- `shell` - start/kill/log/IPC calls
- `screenshot` - open area picker (`start`, `start-freeze`)
- `wallpaper` - set wallpaper + generate lockscreen blur image
- `scheme` - generate and apply dynamic/preset color schemes

Note: `cli/src/zshell/subcommands/scheme.py` uses Jinja2 templating for `~/.config/zshell/templates` rendering.

## Greeter

The repository ships a separate greeter shell under `Greeter/` designed for greetd + Hyprland.

- Greeter shell entry: `Greeter/shell.qml`
- Default greeter config path: `/etc/zshell-greeter/config.json`
- Startup script: `Greeter/scripts/start-zshell-greeter`
- Helper installer script: `scripts/prepare-greeter.sh`

## Known Caveats

- `Modules/Launcher/Services/Apps.qml` references `assets/wrap_term_launch.sh`; ensure this script exists in your deployment.
- `cli/pyproject.toml` currently does not list `jinja2`, but `scheme.py` imports it.
- Some scheme variant naming paths may differ between UI values and CLI expectations (`tonalSpot` vs `tonal-spot`, etc.).

## Inspiration

- [Caelestia](https://github.com/caelestia-dots/shell)
- [end-4 dots-hyprland](https://github.com/end-4/dots-hyprland)

## License

See `LICENSE`.
