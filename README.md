# Zoomie

macOS menu bar app. Before a qualifying calendar event, a character tows a message banner across the screen — full left-to-right traverse, above fullscreen apps, click-through, with a system sound.

Personal use only. Apple Silicon, macOS 14 (Sonoma) and later. No App Store listing. Unsigned build.

## Install

Apple Silicon, macOS 14+.

```bash
curl -fsSL https://raw.githubusercontent.com/SakshamKarnawat/zoomie-meeting-reminder/main/install.sh | bash
```

Menu bar pawprint → **Settings…**. Allow Calendar access if prompted. If macOS blocks the app: **System Settings → Privacy & Security → Open Anyway**.

EventKit reads calendars already linked in **System Settings > Internet Accounts** (iCloud and Google included). No OAuth or CalDAV in this app.

## Qualifying events

An event is reminded when it has a title, is not all-day, the user has not declined it, and its calendar is enabled in Zoomie settings.

## Build and run

Needs Xcode on an Apple Silicon Mac.

```bash
git clone <this-repo>
cd zoomie
xcodebuild -scheme Zoomie -configuration Release -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
```

The app lands under Xcode’s DerivedData `Build/Products/Release/Zoomie.app`. Copy it to `/Applications` if you want Launch at Login to stick.

Regenerate the OpenMoji Dock/app icon with `scripts/generate-icons.sh` (optional; the sized PNGs are already in the repo). Pass a color source path if you already have it; otherwise the script downloads `1F436` from [OpenMoji](https://github.com/hfg-gmuend/openmoji). The menu bar uses the SF Symbol `pawprint.fill`, not this bitmap.

In Xcode: open `Zoomie.xcodeproj`, select the Zoomie scheme, Run. First launch asks for Calendar access.

## Manual unsigned copy

If you already have `Zoomie.app`: copy it to `/Applications`, then:

```bash
xattr -rd com.apple.quarantine "/Applications/Zoomie.app"
```

Open Zoomie. Grant Calendar access when prompted. If access was denied earlier: **System Settings > Privacy & Security > Calendars**, enable Zoomie, then reopen the app.

## Menu and settings

Menu bar item (SF Symbol `pawprint.fill`, template-tinted for light/dark): **Settings…**, **Test Now**, **Launch at Login**, **Quit**. **Settings…** brings the existing settings window forward if it is already open — it does not spawn a second one.

**Test Now** flies the banner immediately with the current character, theme, font, and message template (`{event}` becomes `Zoomie preview`, `{mins}` is the selected lead time). No calendar event needed. If a banner is already crossing the screen, Test Now does nothing.

Settings (UserDefaults, no extra config file):

- Character: Cat or Corgi (code-drawn, looping bob/wag, a soft color-matched glow plus a light fill gradient so they stay readable), color swatches plus a color picker, or a custom image
- Banner position: Top, Upper-center, or custom % from top, with a scaled screen preview
- Banner theme: Classic, Midnight, Sunset, Mint, Bubblegum
- Lead time: 5 or 10 minutes, optional ping at meeting start
- Message template, default `{event} in {mins} min`
- Banner font: System, Rounded, Serif, Mono, Condensed
- Calendar checklist (all on by default)
- Launch at Login via `SMAppService.mainApp`
- Test Now (same action as the menu item)

## Inspired by

Zoomie’s design and feature set were inspired by [Quakpit](https://quakpit.app) ([Ooble-Studio/QuakPit](https://github.com/Ooble-Studio/QuakPit)).

## Credits

The Dock/app icon is the OpenMoji dog face (U+1F436), resized with `scripts/generate-icons.sh`. [OpenMoji](https://openmoji.org) — the open-source emoji and icon project. License: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Source: [hfg-gmuend/openmoji](https://github.com/hfg-gmuend/openmoji). The menu bar icon is the SF Symbol `pawprint.fill`.

## Architecture

See [docs/architecture.md](docs/architecture.md) for scheduling, calendar filtering, and the banner window.

## Constraints

No paywall, no telemetry, no network besides EventKit’s local calendar store. arm64 only. Requires macOS 14 or later.
