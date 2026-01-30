# Dotfiles Overview

> **Claude Instructions:**
> - When you learn something new, fix a bug, or discover a gotcha, update this file
> - When the user makes system changes (installs/removes packages, changes configs), update the relevant sections
> - When the user starts a new topic/context, re-read this file to refresh your memory
> - Only focus on info relevant to the current topic - don't mention unrelated sections

Personal dotfiles for a Hyprland-based Wayland desktop environment.

## System Info

| Component | Value |
|-----------|-------|
| **OS** | Arch Linux (rolling) |
| **Display** | Wayland (not X11) |
| **WM** | Hyprland |
| **Dotfiles Base** | JaKooLit's Hyprland dotfiles |
| **Hardware** | Dell Pro 16 Plus (laptop) |
| **GPU** | Intel Arc Graphics 130V/140V (Lunar Lake integrated) |
| **Shell** | fish |
| **Terminal** | Kitty (also: ghostty, wezterm) |
| **Editor** | Neovim (LazyVim) |
| **Bar** | Waybar |
| **Launcher** | Rofi |
| **Notifications** | SwayNC |
| **Wallpaper** | swww |
| **File Manager** | yazi (with wallust theme) |
| **Audio** | PipeWire + WirePlumber |
| **AUR Helper** | yay |
| **Browser** | Firefox |

## Package Compatibility

**IMPORTANT:** This is a pure Wayland setup. When recommending or installing packages:

- **Always prefer Wayland-native packages** (no X11-only tools)
- **Check Hyprland compatibility** before recommending desktop tools/widgets
- **Avoid X11 dependencies** unless XWayland fallback is acceptable
- **Desktop widgets:** Use eww or AGS (Wayland-native), NOT conky (X11, buggy on Wayland)
- **Screen recording:** Use wf-recorder, OBS with pipewire, NOT X11 tools
- **Screenshots:** Use grim + slurp, hyprshot, NOT scrot/maim
- **Clipboard:** Use wl-clipboard, NOT xclip/xsel

### Wayland-Native Alternatives Cheatsheet

| X11 Tool | Wayland Alternative |
|----------|---------------------|
| xclip/xsel | wl-clipboard |
| scrot/maim | grim + slurp, hyprshot |
| xdotool | wtype, ydotool |
| xrandr | wlr-randr, nwg-displays |
| conky | eww, AGS |
| dmenu | rofi, wofi, fuzzel |

## Structure

Dotfiles are organized by application and symlinked to `~/.config/`. Each directory follows the pattern: `app/.config/app/`

```
~/.dotfiles/
├── hypr/       # Hyprland window manager
├── nvim/       # Neovim (LazyVim framework)
├── fish/       # Fish shell
├── kitty/      # Kitty terminal
├── rofi/       # Application launcher
├── waybar/     # Status bar
├── wallust/    # Dynamic color generation
├── swaync/     # Notification daemon
└── wlogout/    # Power menu
```

## Key Configurations

### Hyprland (`hypr/.config/hypr/`)
- `hyprland.conf` - Main entry, sources other configs
- `configs/` - System defaults (Keybinds, WindowRules, Settings)
- `UserConfigs/` - User overrides (01-UserDefaults.conf is key)
- `scripts/` - 70+ utility scripts
- `animations/` - 16+ animation presets

**Important:** User customizations go in `UserConfigs/`, not `configs/`.

### Neovim (`nvim/.config/nvim/`)
- LazyVim framework
- `lua/config/keymaps.lua` - Custom keybinds (jk = Esc)
- `lua/plugins/` - Plugin configs
- `lua/plugins/colorscheme.lua` - Theme (nightfly, transparent bg)
- `lua/plugins/snacks/dashboard.lua` - Dashboard config

### Fish (`fish/.config/fish/`)
- Minimal config, mostly defaults
- Commands must be fish-compatible or wrapped in `bash -c`

### Theming
- **Wallust** generates colors from wallpapers
- Templates in `wallust/.config/wallust/templates/` output to:
  - Hyprland, Kitty, Rofi, Waybar, SwayNC, Ghostty
- Kitty has 200+ themes in `kitty-themes/`
- Rofi has 50+ themes in `themes/`
- Waybar has 80+ styles in `style/`

## Common Tasks

### Hyprland
```bash
# Reload config
hyprctl reload

# Edit user keybinds
nvim ~/.config/hypr/UserConfigs/UserKeybinds.conf

# Quick settings menu
~/.config/hypr/scripts/Kool_Quick_Settings.sh
```

### Neovim
```bash
# Update plugins
:Lazy update

# Check health
:checkhealth
```

### Theming
```bash
# Regenerate colors from wallpaper
wallust run <image>

# Switch waybar style
~/.config/hypr/scripts/WaybarStyles.sh
```

## Notes

- Fish is the default shell - bash syntax like `$((...))` won't work directly
- Hyprland UserConfigs use `$var = value` syntax (Hyprland-specific, not bash)
- The `$files` variable in Hyprland configs needs quoted values if they contain spaces

## Learnings

Things discovered while working on this setup:

- **Hyprland UserDefaults parsing bug:** The `Kool_Quick_Settings.sh` script uses `sed` to convert Hyprland syntax to bash. Lines like `$files = $term yazi` become `files=$term yazi`, which bash interprets as "set env var, then run yazi". Fix: quote values with spaces: `$files = "$term yazi"`
- **Fish + bash in terminal sections:** Snacks dashboard terminal sections run in fish. Wrap bash-specific syntax in `bash -c '...'`. Use `$HOSTNAME` (bash builtin) not `$hostname` (fish variable) inside bash -c.
- **Neovim jk escape:** Custom keymap in `lua/config/keymaps.lua` maps `jk` to Esc in insert mode, with Esc disabled.
- **Hyprland windowrule syntax (2025+):** The syntax changed significantly. Use `match:class` for matching and explicit `on` for boolean properties. Example: `windowrule = float on, match:class myapp`. Properties like `noborder` became `border_size 0`, `noshadow` became `no_shadow on`, `nofocus` became `no_focus on`. Always check https://wiki.hypr.land/Configuring/Window-Rules/ for current syntax.
- **Desktop widgets on Wayland:** Conky has buggy Wayland support (background transparency broken, `own_window` not implemented). For desktop widgets on Hyprland, use **eww** or **AGS** instead - they're Wayland-native and what most "riced" Hyprland setups actually use.
- **Always verify Wayland compatibility:** Before recommending any package, verify it works on Wayland/Hyprland. Many popular Linux tools are X11-only or have limited Wayland support.
- **Wallust Kitty template for readability:** The default wallust dark16 palette generates colors that can be too similar to the background, making text hard to read. The custom template at `wallust/.config/wallust/templates/colors-kitty.conf` uses hardcoded saturated accent colors (red, green, yellow, cyan) while keeping wallpaper-derived purples/blues for theming. This ensures readability across any wallpaper.
