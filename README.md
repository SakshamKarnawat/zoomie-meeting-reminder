# Zoomie

macOS menu bar app. Before a qualifying calendar event, a character tows a message banner across the screen — full left-to-right traverse, above fullscreen apps, click-through, with a system sound.

Personal use only. Apple Silicon, macOS 14 (Sonoma) and later. No App Store listing. Unsigned build.

## Install

Apple Silicon, macOS 14+.

```bash
curl -fsSL https://raw.githubusercontent.com/SakshamKarnawat/zoomie-meeting-reminder/main/install.sh | bash
```

Menu bar pawprint → **Settings…**. Allow Calendar access if prompted. If macOS blocks the app: **System Settings → Privacy & Security → Open Anyway**.

EventKit reads **Apple Calendar** (calendars already linked in **System Settings → Internet Accounts**, including iCloud and Outlook). **Google Calendar** is a separate optional sign-in via the Google Calendar API — it does not go through Calendar.app. Settings explains both under **Apple Calendar** and **Google Calendar**. If the same meeting exists in both, Zoomie keeps one copy.

## Qualifying events

An event is reminded when it has a title, is not all-day, the user has not declined it, its calendar is enabled in Zoomie settings, and the title is not on the ignore list (whole-word match; default `busy, blocked, focus, hold, ooo`).

## Build and run

Needs Xcode on an Apple Silicon Mac.

```bash
git clone <this-repo>
cd zoomie
xcodebuild -scheme Zoomie -configuration Release -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
```

Releases are semantic versions (`vMAJOR.MINOR.PATCH`). Every push to `main` publishes a new GitHub release and stamps that version into the app. Commit prefixes decide the bump: `fix:` (or anything else) → patch `1.0.0 → 1.0.1`; `feat:` → minor `1.0.0 → 1.1.0`; `feat!:` / `fix!:` or a `BREAKING CHANGE:` footer → major `1.0.0 → 2.0.0`. `install.sh` still pulls GitHub’s latest release. What changed in each version is in [CHANGELOG.md](CHANGELOG.md) and on the GitHub release. `scripts/semver.sh` prints the next number locally (`notes` / `changelog` / `test` / `build` for CI).

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

Menu bar item (SF Symbol `pawprint.fill`, template-tinted for light/dark): next upcoming event (and **Join** when the event has a meeting URL), **Settings…**, **Test Now**, **Sync Calendars Now**, **Launch at Login**, **About Zoomie…**, **Update Zoomie**, **Quit**. **Settings…** brings the existing settings window forward if it is already open — it does not spawn a second one. **About Zoomie…** is the same: one window, brought forward. **Update Zoomie** re-runs `install.sh` from GitHub.

**Test Now** flies the banner immediately with the current character, theme, font, and message template (`{event}` becomes `Zoomie preview`, `{mins}` is the selected lead time). No calendar event needed. If a banner is already crossing the screen, Test Now does nothing.

Settings (UserDefaults, no extra config file):

- Character: Cat or Corgi (code-drawn, looping bob/wag, a soft color-matched glow plus a light fill gradient so they stay readable), color swatches plus a color picker, or a custom image
- Banner position: Top, Upper-center, or custom % from top, with a scaled screen preview
- Banner theme: Classic, Midnight, Sunset, Mint, Bubblegum
- Lead time: 5 or 10 minutes, optional ping at meeting start
- Calendar refresh: 4 / 6 / 12 / 24 hours (default 6), plus **Sync Now** (same action as the menu item). Sync Now reloads Apple Calendar and, if you are signed in, Google Calendar. EventKit still updates as soon as the store changes.
- Message template, default `{event} in {mins} min`
- Banner font: System, Rounded, Serif, Mono, Condensed
- Apple Calendar: calendars already in Calendar.app (iCloud / Outlook / Internet Accounts). **Open Internet Accounts…**
- Google Calendar: optional **Connect Google…** (OAuth, tokens in Keychain). Separate checklist from Apple calendars
- Calendar checklists (all on by default)
- Ignore titles: comma-separated whole-word list (default `busy, blocked, focus, hold, ooo`)
- Launch at Login via `SMAppService.mainApp`
- About: version, check GitHub for a newer zip, Update Zoomie
- Test Now (same action as the menu item)

## Inspired by

Zoomie’s design and feature set were inspired by [Quakpit](https://quakpit.app) ([Ooble-Studio/QuakPit](https://github.com/Ooble-Studio/QuakPit)).

## Credits

The Dock/app icon is the OpenMoji dog face (U+1F436), resized with `scripts/generate-icons.sh`. [OpenMoji](https://openmoji.org) — the open-source emoji and icon project. License: [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Source: [hfg-gmuend/openmoji](https://github.com/hfg-gmuend/openmoji). The menu bar icon is the SF Symbol `pawprint.fill`.

## Architecture

See [docs/architecture.md](docs/architecture.md) for scheduling, Apple and Google calendars, calendar sync, updates, and the banner window.

## Constraints

No paywall, no telemetry. Network is EventKit’s local calendar store, optional Google Calendar API after you connect a Google account, plus a user-started GitHub check/install for updates. arm64 only. Requires macOS 14 or later.

## Google Calendar (developers)

Zoomie uses a **Desktop** OAuth client and PKCE (loopback `http://127.0.0.1`). There is no client secret in the app. Do not create a Web or iOS client.

1. In the same GCP project: enable **Google Calendar API**.
2. OAuth consent screen (External, Testing is fine): add yourself as a test user.
3. Credentials → Create OAuth client → application type **Desktop app**. Loopback redirects are automatic — do not add a custom redirect URI.
4. Paste the client ID into `GoogleClientConfig.bakedInClientID`, or set `INFOPLIST_KEY_GoogleClientID` on the Zoomie target.

Connect Google in Settings. Tokens stay in the Keychain. Disconnect revokes them. The client ID is public; treat refresh tokens in Keychain as the secret.
