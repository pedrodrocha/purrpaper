# Purrpaper

A cozy little Omarchy plugin for people who want their Catppuccin desktop to quietly surprise them.

It picks a random wallpaper from orangc's Catppuccin Mocha collection, downloads it, and sets it with `omarchy theme bg set`. It runs on a schedule, but only when your active Omarchy theme is `catppuccin`. If you switch themes, it politely stops touching your background.

Source gallery: <https://files.orangc.net/media/walls-catppuccin-mocha/>  
Index used by the script: <https://api.github.com/repos/orangci/walls-catppuccin-mocha/contents/>

## The vibe

You get an Omarchy service, a small bar widget, and a friendly CLI.

The bar widget is for quick clicks: left click opens the panel, right click rotates now, and middle click saves the current wallpaper. The panel shows what is playing, when the next shuffle happens, whether rotation is enabled, and where favorites are saved.

The CLI is for when you are already in the terminal and just want to say things like:

```bash
purrpaper rotate
purrpaper save
purrpaper every 4h
```

Its status output is intentionally a little cute:

```text
󰄛 Purrpaper
Status             enabled (󰄛 softly shuffling pixels)
Wallpaper          dominik-mayer-20.jpg
Theme              catppuccin
Interval           1 day
Next rotation      23h 51m
Favorites          ~/.config/omarchy/backgrounds/catppuccin
Cache              ~/.config/omarchy/backgrounds/catppuccin/orangc-random
```

Colors use the Catppuccin palette when your terminal supports it. If you do not want colors, use `NO_COLOR=1`.

## Install

From GitHub:

```bash
omarchy plugin add https://github.com/pedrodrocha/purrpaper.git --enable
```

For local development:

```bash
cd <wherever you cloned this repo>/purrpaper
./install.sh
```

`./install.sh` also links the CLI into `~/.local/bin` as:

```bash
purrpaper
```

Make sure `~/.local/bin` is in your `PATH`. On Omarchy it usually already is.

## Use it

Show the current state:

```bash
purrpaper status
```

Rotate immediately:

```bash
purrpaper rotate
# 󰄛 Now wearing puffy-stars.jpg. 󰄛 fresh pixels, fresh mood.
```

Save the current wallpaper before it disappears forever into the cozy void:

```bash
purrpaper save
# 󰄛 Saved foggy-city.jpg to your favorites. 󰄛 good catch.
```

Enable, disable, or toggle automatic rotation:

```bash
purrpaper enable
# 󰄛 Automatic rotation enabled. 󰄛 back on wallpaper duty.

purrpaper disable
# 󰄛 Automatic rotation disabled. 󰄛 curled up under a Mocha blanket.

purrpaper toggle
```

Set the schedule with friendly durations:

```bash
purrpaper every 30m
purrpaper every 4h
purrpaper every 1d
purrpaper every hourly
purrpaper every daily
```

Nudge the current interval up or down:

```bash
purrpaper sooner 1h
purrpaper later 30m
```

Open the current wallpaper file:

```bash
purrpaper open
```

Get the raw JSON used by the widget:

```bash
purrpaper status --json
```

The lower-level script API still exists at `scripts/control`, but the CLI is the human-facing way to use the plugin.

## Remove it

Use the plugin uninstaller:

```bash
purrpaper uninstall
```

That removes the `~/.local/bin/purrpaper` symlink first, then calls Omarchy's plugin remover.

If you run this directly:

```bash
omarchy plugin remove pedrodrocha.purrpaper
```

Omarchy removes the plugin, but it does not run plugin cleanup hooks, so the CLI symlink may be left behind.

## Small promises

The rotator keeps only one temporary random wallpaper in its cache, so it will not fill your disk. Saved wallpapers are copied into Omarchy's normal Catppuccin backgrounds folder and are never deleted by the cleanup step. If a saved filename already exists, it will not make a duplicate.

If the network, gallery, or download is unavailable, the script exits cleanly, keeps your current background, and the widget/CLI can report the no-internet state.

## Files and state

Temporary cache:

```text
~/.config/omarchy/backgrounds/catppuccin/orangc-random/
```

Saved favorites:

```text
~/.config/omarchy/backgrounds/catppuccin/
```

Plugin settings and runtime state:

```text
~/.local/state/omarchy/pedrodrocha.purrpaper/
```

Installed plugin copy:

```text
~/.config/omarchy/plugins/pedrodrocha.purrpaper/
```

## Development

Useful commands:

```bash
make check
make install
purrpaper status
purrpaper rotate
purrpaper save
```

The code is intentionally boring. Shell scripts own behavior and state. QML displays that state and calls `scripts/control`. The CLI wraps the same control script with friendlier output.

The plugin uses common Omarchy dependencies such as `bash`, `curl`, `jq`, and `shuf`. It does not use privilege escalation, generated build steps, embedded Python, or download-and-execute behavior. See `SECURITY_BASELINE.md` for the marketplace baseline notes.
