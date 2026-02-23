# dots

Arch Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```sh
cd ~/dots
stow fish git hypr kitty nvim rofi swaync tmux wallust waybar wlogout yazi local-bin keyd claude

# keyd requires root target
sudo stow -d ~/.dotfiles -t / keyd
```

## Packages

| Package | Description |
|---|---|
| `fish` | Fish shell |
| `git` | Git config |
| `hypr` | Hyprland, hyprlock, hypridle, scripts, themes |
| `keyd` | System-level key remapping daemon |
| `kitty` | Kitty terminal |
| `local-bin` | Custom binaries for the user |
| `nvim` | Neovim |
| `rofi` | Rofi launcher and menus |
| `swaync` | Notification daemon |
| `tmux` | Tmux |
| `wallust` | Wallpaper-based color generation |
| `waybar` | Waybar status bar |
| `wlogout` | Logout menu |
| `yazi` | Yazi file manager |

## Keyd Bindings

Japanese keyboard keys remapped via [keyd](https://github.com/rvaiya/keyd). Config at `keyd/etc/keyd/default.conf`.

| Key | Tap | Hold |
|---|---|---|
| `yen` | `~` (tilde) | — (shift: `` ` `` backtick) |
| `muhenkan` | Escape | Navigation layer |
| `henkan` | Clipboard manager | — |
| `compose` | Screenshot (swappy) | — |
| `katakanahiragana` | Emoji picker | — |

### Navigation layer (hold muhenkan)

| Key | Action |
|---|---|
| `h` `j` `k` `l` | Arrow keys (left/down/up/right) |
| `u` / `d` | Page up / Page down |
| `g` / `Shift+g` | Home / End |

After editing the config: `sudo keyd reload`

## Wallpaper Theming

Wallpapers are managed with swww. Changing a wallpaper automatically runs Wallust to generate colors, updates app themes (Waybar, Rofi, Kitty, Ghostty, Yazi), and syncs the SDDM login screen.

## Theme System

Light and Dark themes with per-theme wallpaper pools, waybar layouts, and wallust palettes. Stored in `hypr/.config/hypr/themes/{light,dark}/`.

- `Super+Shift+W` — switch between Light/Dark mode and toggle auto-rotate
- `Super+W` — pick a wallpaper from the current theme's pool
- Auto-rotate cycles wallpapers from the active theme every 30 minutes

Mode switching applies across the desktop: swaync, rofi, qt5ct/qt6ct, kvantum, gsettings.
