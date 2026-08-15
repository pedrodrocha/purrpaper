# Security Baseline

This Omarchy plugin runs unsandboxed in the long-running Omarchy shell process with the current user's permissions.

## Dependencies

Runtime dependencies are standard Omarchy/Arch tools already expected on an Omarchy system:

- `bash`
- `curl`
- `grep`
- `sed`
- `jq`
- `shuf` from GNU coreutils
- Omarchy CLI commands: `omarchy`, `omarchy-shell`
- Quickshell/Omarchy shell QML APIs

## Network access

The rotator fetches wallpaper metadata and image files from orangc's Catppuccin Mocha wallpaper mirror:

- `https://files.orangc.net/media/walls-catppuccin-mocha/`
- `https://api.github.com/repos/orangci/walls-catppuccin-mocha/contents/` as a fallback index
- `https://raw.githubusercontent.com/orangci/walls-catppuccin-mocha/...` as a fallback image mirror

Downloaded data is treated as data only. It is filtered by filename, file type, and expected URL prefix, saved as an image, and never executed.

## Privilege boundary

This plugin does not use `sudo`, `pkexec`, setuid binaries, privileged services, system package installation, or privileged policy changes.

## Filesystem writes

The plugin writes only to user-owned Omarchy/config/state locations:

- `~/.config/omarchy/backgrounds/catppuccin/orangc-random/`
- `~/.config/omarchy/backgrounds/catppuccin/`
- `~/.local/state/omarchy/pedrodrocha.purrpaper/`
- `~/.config/omarchy/plugins/pedrodrocha.purrpaper/` during local `install.sh`

## Install/remove behavior

Local `install.sh` copies this repository into the user plugin directory, validates it with `omarchy plugin validate`, rescans plugins, enables the plugin, and restarts the Omarchy shell. It does not modify `/usr/share/omarchy` or any system-owned path.

Remove with:

```sh
omarchy plugin remove pedrodrocha.purrpaper
```
