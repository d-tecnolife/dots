# dotfiles

Arch Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```sh
cd ~/.dotfiles
stow fish git hypr kitty nvim rofi swaync tmux wallust waybar wlogout yazi

# keyd requires root target
sudo stow -d ~/.dotfiles -t / keyd
```

## Packages

| Package | Description |
|---|---|
| `fish` | Fish shell |
| `git` | Git config |
| `hypr` | Hyprland, hyprlock, hypridle, scripts |
| `keyd` | System-level key remapping daemon |
| `kitty` | Kitty terminal |
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

Wallpapers are managed with swww. Changing a wallpaper automatically:

1. Runs Wallust to generate a color palette from the image
2. Updates Waybar, Rofi, Kitty, Ghostty, Yazi themes
3. Syncs the wallpaper and colors to the SDDM login screen

Keybinds: `Super+W` (select), `Ctrl+Alt+W` (random), `Super+Shift+W` (effects).
