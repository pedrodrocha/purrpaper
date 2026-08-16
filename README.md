# purrpaper

> tiny wallpaper magic for Catppuccin Omarchy

Purrpaper is a cozy little Omarchy plugin for people who want their Catppuccin desktop to quietly surprise them. It picks a random wallpaper from orangc's Catppuccin Mocha collection, downloads it, and applies it with `omarchy theme bg set`.

The cat is polite about it. Rotation only happens while your active Omarchy theme is `catppuccin`; if you switch themes, purrpaper curls up and leaves your background alone until Catppuccin comes back.

The source gallery lives at <https://files.orangc.net/media/walls-catppuccin-mocha/>, and the script reads its index from that gallery directly. GitHub is kept only as a fallback mirror.

It is meant to feel like a little bit of desktop magic: quiet most of the time, present when you ask for it, and just playful enough to make wallpaper rotation feel less like configuration and more like a tiny ritual.

## tiny wallpaper gallery

Purrpaper shuffles through orangc's Catppuccin Mocha wallpaper collection. These are small previews of the kind of backgrounds it can pull into your Omarchy setup, rotate on a schedule, and save as favorites when one feels too good to lose.

<p align="center">
  <img src="docs/assets/wallpapers/cartoon-castle.webp" alt="Catppuccin Mocha wallpaper preview: cartoon castle" width="245">
  <img src="docs/assets/wallpapers/astronaut.webp" alt="Catppuccin Mocha wallpaper preview: astronaut" width="245">
  <img src="docs/assets/wallpapers/black-hole.webp" alt="Catppuccin Mocha wallpaper preview: black hole" width="245">
  <img src="docs/assets/wallpapers/asian-village.webp" alt="Catppuccin Mocha wallpaper preview: asian village" width="245">
  <img src="docs/assets/wallpapers/beach-path.webp" alt="Catppuccin Mocha wallpaper preview: beach path" width="245">
  <img src="docs/assets/wallpapers/blue-flowers.webp" alt="Catppuccin Mocha wallpaper preview: blue flowers" width="245">
</p>

The previews above are intentionally tiny and compressed for the README. Purrpaper downloads the real images from the source collection when it rotates your background.

## the vibe

Purrpaper gives you an Omarchy service, a small bar widget, and a friendly `purrpaper` CLI. The service does the quiet wallpaper work in the background. The widget is there for quick little rituals: left click opens the panel, right click rotates now, and middle click saves the current wallpaper before it wanders back into the cozy void.

The panel shows what purrpaper is wearing, when the next shuffle happens, whether automatic rotation is enabled, and where your favorites are saved. The CLI tells the same story from the terminal, just with more Catppuccin charm.

```bash
purrpaper status
purrpaper rotate
purrpaper save
purrpaper every 4h
```

```text
󰄛 Purrpaper - tiny wallpaper magic for Catppuccin Omarchy
Status             enabled (󰄛 softly shuffling pixels)
Wallpaper          dominik-mayer-20.jpg
Theme              catppuccin
Interval           1 day
Next rotation      23h 51m
Favorites          ~/.config/omarchy/backgrounds/catppuccin
Cache              ~/.config/omarchy/backgrounds/catppuccin/orangc-random
```

When your terminal supports color, purrpaper uses the Catppuccin palette. If you prefer plain text, run it with `NO_COLOR=1`.

## small promises

Purrpaper keeps only one temporary random wallpaper in its cache, so it should not grow into a tiny wallpaper dragon. Saved favorites are copied into Omarchy's normal Catppuccin backgrounds folder and are never deleted by cache cleanup. If a favorite filename already exists, purrpaper will not duplicate it.

If the network, gallery, or download fails, the script exits cleanly, keeps your current background, and reports the no-internet state through the widget and CLI.

## install

Install it from GitHub with Omarchy:

```bash
omarchy plugin add https://github.com/pedrodrocha/purrpaper.git --enable
```

For local development, clone the repo and run the installer from inside it:

```bash
cd <wherever you cloned this repo>/purrpaper
./install.sh
```

The installer also links the CLI into `~/.local/bin` as `purrpaper`. Make sure `~/.local/bin` is in your `PATH`; on Omarchy, it usually already is.

## commands

Ask purrpaper what it is doing with:

```bash
purrpaper status
```

Rotate immediately when you want fresh pixels and a fresh mood:

```bash
purrpaper rotate
# 󰄛 Now wearing puffy-stars.jpg. Fresh pixels, fresh mood.
```

Save the current wallpaper as a favorite when it feels too good to lose:

```bash
purrpaper save
# 󰄛 Saved foggy-city.jpg to your favorites. Good catch.
```

Automatic rotation can be enabled, disabled, or toggled whenever the mood changes:

```bash
purrpaper enable
# 󰄛 Automatic rotation enabled. Back on wallpaper duty.

purrpaper disable
# 󰄛 Automatic rotation disabled. Curled up under a Mocha blanket.

purrpaper toggle
```

Schedules use friendly durations, so you can ask for minutes, hours, days, or the soft human words `hourly` and `daily`:

```bash
purrpaper every 30m
purrpaper every 4h
purrpaper every 1d
purrpaper every hourly
purrpaper every daily
```

If the current interval is close but not quite right, nudge it instead of doing math:

```bash
purrpaper sooner 1h
purrpaper later 30m
```

You can open the current wallpaper file directly:

```bash
purrpaper open
```

And if you want the raw state that powers the widget, ask for JSON:

```bash
purrpaper status --json
```

The lower-level script API still exists at `scripts/control`, but the CLI is the human-facing path.

## remove

Let purrpaper clean up its own pawprints with:

```bash
purrpaper remove
```

That removes the `~/.local/bin/purrpaper` symlink first, then asks Omarchy to remove the plugin.

If you only want to remove the terminal command and keep the plugin installed, unlink the CLI instead:

```bash
purrpaper unlink
```

You can also remove the plugin directly through Omarchy:

```bash
omarchy plugin remove pedrodrocha.purrpaper
```

Omarchy will remove the plugin, but it does not run plugin cleanup hooks, so the CLI symlink may stay behind.

## files and state

Temporary cache lives here:

```text
~/.config/omarchy/backgrounds/catppuccin/orangc-random/
```

Saved favorites live here:

```text
~/.config/omarchy/backgrounds/catppuccin/
```

Plugin settings and runtime state live here:

```text
~/.local/state/omarchy/pedrodrocha.purrpaper/
```

The installed plugin copy lives here:

```text
~/.config/omarchy/plugins/pedrodrocha.purrpaper/
```

## development

Useful little incantations live in the `Makefile`:

```bash
make check
make install
make status
make rotate
make save
make enable
make disable
```

The code is intentionally boring: shell scripts own behavior and state, QML displays that state and calls `scripts/control`, and the CLI wraps the same control script with friendlier output. The `Makefile` is the development entry point for validation, linting, install, and local control commands.

Purrpaper uses common Omarchy dependencies such as `bash`, `curl`, `jq`, and `shuf`. It does not use privilege escalation, generated build steps, embedded Python, or download-and-execute behavior. See `SECURITY_BASELINE.md` for the marketplace baseline notes.
