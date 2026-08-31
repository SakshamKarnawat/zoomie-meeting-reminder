# Zoomie architecture

Feature folders under `Zoomie/`: App, Settings, Calendar, Google, Banner, Scheduling, Update. One Swift type per file. Shared UI numbers live in `Design`. Settings persist through `SettingsStore` → `UserDefaults`. Google OAuth tokens persist in the Keychain (`GoogleTokenStore`).

Deployment target is macOS 14 (Sonoma); later macOS versions are supported. `SettingsStore`, `CalendarService`, `GoogleCalendarService`, and `EventCatalog` are `@Observable` `@MainActor` classes. Settings views take stores as `@Bindable`. `AppRuntime` and `EventScheduler` are plain `@MainActor` classes. UserDefaults writes live in `SettingsStore` property `didSet` — not `@AppStorage` inside the observable class.

## Banner window

`BannerController` builds an AppKit `NSPanel` itself and hosts `BannerView` in an `NSHostingController`. This is not a SwiftUI `WindowGroup` window.

The panel is borderless, transparent, click-through (`ignoresMouseEvents = true`), level `.screenSaver`, and uses collection behavior `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]` so it can appear over other spaces and fullscreen apps without taking the key window or the Dock.

The window is sized to the banner content (character + ribbon), not the full screen. Vertical placement is `BannerPlacement.originY(visibleFrame:bannerHeight:fromTop:)` using `SettingsStore.resolvedFromTop` (0 = top, 1 = bottom, with `BannerPlacement.edgeInset`). Settings preview calls the same `offsetFromTop` and scales it — no second formula.

## Settings window

`AppRuntime` keeps one `SettingsWindowController` and one `AboutWindowController`. There is no SwiftUI `Settings` scene and no `SettingsLink` — those do not refocus an already-open window while Zoomie is an accessory app (`LSUIElement`). Menu **Settings…** / **About Zoomie…** create the window on first click; later clicks use `AppActivation.bringToFront` (`setActivationPolicy(.regular)`, `activate(ignoringOtherApps: true)`, `makeKeyAndOrderFront`) on that same instance. Close orders the window out (`isReleasedWhenClosed = false`, `windowShouldClose` returns false) and `AppActivation.restoreAccessoryIfNeeded` only if no other titled window is visible. Two settings windows and two about windows are never created.

## Menu bar and app icon

`MenuBarExtra` uses `MenuBarIcon.templateImage`: SF Symbol `pawprint.fill` as an `NSImage` with `isTemplate = true`, sized to 18 pt so it matches other menu bar icons and follows light/dark tint. The Dock/Finder icon is `AppIcon.appiconset` (OpenMoji color `1F436`, 16–1024 px). `scripts/generate-icons.sh` downloads the 618×618 color source if needed and resizes it with `sips` — it does not generate the tray icon.

The menu’s first block is `NextEventMenuSection`: on appear it asks `EventCatalog.nextUpcomingEvent` (Apple EventKit plus Google Calendar cache, same `EventQualifying` filter as the scheduler, including muted titles) and shows `UpcomingEventLabel` plus **Join** when `MeetingLink` found an http(s) URL on the event, notes, or location (Zoom / Meet / Teams / FaceTime / Webex preferred). **Sync Calendars Now** is the same `CalendarSync.syncNow()` as Settings. **Update Zoomie** calls `AppUpdateService.installLatest`, which runs `install.sh` from GitHub.

## Marquee

The **window** moves, not an inner SwiftUI slide. `BannerAnimator` runs one 120 Hz `Timer` on the main `.common` run loop and only writes `setFrameOrigin` each tick — it does not rebuild the SwiftUI view. (A window-tied `CADisplayLink` was dropped: the panel starts fully off-screen, so that link never fired and Test Now played the sound with no visible banner.) Speed is `Design.pixelsPerSecond` (220). Duration is `(screenWidth + bannerWidth) / speed`. `BannerMotion.progress` eases the first and last 10% (`Design.easePortion`); the middle stretch is linear. Start `x = screen.minX - bannerWidth`, end `x = screen.maxX`. Hosted in `NSHostingController` sized with `sizeThatFits`, not a forced 2400-pt frame. Then the panel is ordered out. Only one banner runs at a time (`isShowing`).

The hosted view is one fixed layout: fluttering ribbon (V-notch on the trailing/left edge; `RibbonShape.phase` driven by `TimelineView` at 30 Hz, ~2.4 pt sine on the edges) + overlapping rope (`Design.ropeOverlap`) + Cat/Corgi vector silhouette (or a static custom image) on the leading/right edge, with a drop shadow on the whole group. Drawn characters are `Design.customCharacterSide` (80 pt). Fill is `CharacterPaint.gradient` (a short highlight → base → shade lerp of `SettingsStore.characterColor`). Behind them, `CharacterBackdrop` draws a blurred radial plate in `CharacterPaint.plate` — a hue-tinted opposite-luminance wash — so cream reads on a bright desktop and black reads on a dark one. Eyes are white with black pupils. Custom uploads ignore fill and plate. Cat/Corgi bob and wag via the same `TimelineView` clock; custom uploads do not animate. `--preview-banner` on launch fires `previewBanner()` after a short delay.

On fire, `NSSound(named: "Glass")` plays (falls back to Ping, then `NSSound.beep()`).

**Test Now** (`AppRuntime.previewBanner()`) uses the same `BannerController` path with a fake title (`MessageTemplate.previewEventTitle`) and the current lead-time minutes. Menu bar and Settings both call it. `preview()` no-ops if a banner is already on screen. A real scheduled fire that lands during a preview is stored as `pending` and starts when the preview finishes, so two banners never overlap and the meeting reminder is not dropped.

## Scheduling

`EventScheduler` keeps **one** `Timer` on the main run loop for the next banner fire. No poll loop for fires.

On launch, after a fire, after a scheduling-relevant settings change, on `EKEventStoreChanged`, and on wake: query `EventCatalog` for the next qualifying fires (Apple EventKit plus cached Google events), then either fire immediately (catch-up) or `Timer(fire:interval:repeats:)` for that exact date. Google is not re-fetched on every reschedule — only on Sync Now, the interval timer, wake, Settings open, and after Connect / Disconnect.

A fire is `event.startDate - leadTimeMinutes`, plus `event.startDate` when “Also ping at meeting start” is on. Already-shown fires are remembered in-memory (`deliveredKeys`) so catch-up does not repeat in the same process.

If two fire times fall within `Design.clusterWindow` (10 seconds — about one traverse at 220 px/s on a typical display), extras wait in `queue` and start when the current banner finishes. Two banners never overlap.

If nothing is upcoming in the 60-day look-ahead, a single refresh timer is set for 24 hours so the scheduler does not go silent forever.

## Sleep / wake

`NSWorkspace.didWakeNotification` invalidates the current timer and runs the same reschedule path as launch. `Timer` does not fire during sleep; a pre-sleep fire date would be stale after wake.

`CalendarSync` is a second, repeating timer (`SettingsStore.calendarSyncInterval`, default 6 hours: 4 / 6 / 12 / 24). Each tick, each wake, and **Sync Now** call `EventCatalog.reload()`: Apple `CalendarService.reload()` (`EKEventStore.reset()`, `refreshSourcesIfNecessary()`, `refreshCalendars()`) and, if signed in, `GoogleCalendarService.refresh()` (token refresh + Calendar API). `EventScheduler.reschedule()` runs after that. Changing the interval restarts the timer without skipping that reload. `EKEventStoreChanged` still reloads Apple only, then reschedules against the current Google cache. `reload()` is re-entrancy-guarded on the Apple store so a reset does not loop. The menu next-event row reloads when catalog snapshot IDs change or after the menu Sync item.

## Calendar filtering

`CalendarService` uses EventKit only (`requestFullAccessToEvents`). Denied access shows one alert pointing at **System Settings > Privacy & Security > Calendars**, then the app exits. No retry loop. Settings **Apple Calendar** (`CalendarSourceSection`) is this EventKit path — iCloud and Outlook via **System Settings → Internet Accounts**. **Open Internet Accounts…** calls `SystemSettingsLink.openInternetAccounts`.

`GoogleCalendarService` is a separate source. **Connect Google…** starts a loopback `http://127.0.0.1` listener (`GoogleLoopbackServer`) and lists installed browsers (`InstalledBrowsers`: Safari, Chrome, Firefox, and other known https browsers). The user picks one; Zoomie opens the Google auth URL in that app only — it does not auto-open the default browser. Tokens go in the Keychain; calendars and events come from the Google Calendar API (read-only). **Cancel** stops the listener. Client ID is `GoogleClientConfig` (public). Desktop client secret is never in source. Release builds stamp `INFOPLIST_KEY_GoogleClientSecret` from the GitHub Actions secret `ZOOMIE_GOOGLE_CLIENT_SECRET`. At runtime Zoomie reads Info.plist, then Keychain (`GoogleClientSecretStore`, Settings paste on a local build), then `ZOOMIE_GOOGLE_CLIENT_SECRET` in the process environment. Google calendar IDs are stored as `google:` plus the API id so they do not collide with EventKit identifiers. `EventCatalog` merges both into `TimedEvent` values; `EventDedupe` drops a Google copy when the same title starts within 90 seconds of an Apple event, unless only Google has a meeting URL. Google Meet links come from `hangoutLink`; Zoomie does not treat the Calendar HTML page as a join URL.

`EventQualifying` is the pure filter: non-empty title, not all-day, user has not declined (EventKit current-user `.declined`, or Google `attendees[].self` + `responseStatus=declined`), calendar not in `disabledCalendarIDs`, title not matched by `MutedTitle` against `SettingsStore.mutedTitleTokens` (comma-separated, default `busy, blocked, focus, hold, ooo`; single tokens are whole-word so “Busy” mutes and “Business review” does not). New calendars are on by default because we store the disabled set, not the enabled set.

## Updates

`AppUpdateService` is `@Observable` `@MainActor`. **Check for Updates…** GETs the GitHub `latest` release (User-Agent `Zoomie/<marketing>`) and `AppUpdateCheck` compares `Zoomie.zip` `updated_at` to the running binary’s modification date, with 60 seconds of slack so a just-installed build is not flagged. **Update Zoomie** (menu, About window, Settings About section) starts `/bin/bash -lc` with the same `curl | bash` as `install.sh`. The Settings About section and About window share `UpdateActionsView`.

## Install

`install.sh` downloads `Zoomie.zip` from GitHub’s latest release (`/releases/latest`), copies `Zoomie.app` to `/Applications` (or `~/Applications` if needed), runs `xattr -rd com.apple.quarantine`, and opens the app.

`.github/workflows/release.yml` builds that unsigned arm64 zip on `macos-26` (Xcode 26, same project format as this repo) on every push to `main` and on manual workflow dispatch. `macos-14` ships Xcode 15.4, which cannot open objectVersion 77. The build fails if `ZOOMIE_GOOGLE_CLIENT_SECRET` is unset so a zip cannot ship without Google sign-in.

Versioning is semantic. `scripts/semver.sh` (one file) prints the next `X.Y.Z` from the latest ancestor `v*` tag (or `1.0.0` if none) and Conventional Commits since that tag: `feat` → minor, `type!` / `BREAKING CHANGE:` → major, everything else including `fix` and unprefixed messages → patch. `scripts/semver.sh notes` reads each commit subject plus body and groups them into Features / Fixes / Other. A `feat:` (or `fix:`) body made of `- ` bullets replaces that commit’s subject in the notes, so one commit can list several changes. `chore(release):` lines are skipped. `scripts/semver.sh changelog X.Y.Z` prepends that section to `CHANGELOG.md`. `scripts/semver.sh test` is the self-check; `scripts/semver.sh build X.Y.Z` is `major*10000 + minor*100 + patch`. Every push therefore increments. The workflow stamps those into `xcodebuild` as `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`, prepends `CHANGELOG.md` and commits `chore(release): vX.Y.Z [skip ci]` so it does not bump again, then `gh release create vX.Y.Z --notes-file` `--latest`. Tags are the source of truth. Local `project.pbxproj` stays at `1.0.0` / `10000` until CI overrides it for a release build. After that job finishes, `git pull --ff-only` and `git fetch --tags` so local `CHANGELOG.md` and the new `v*` tag match GitHub.

## Launch at login

`LoginItemService` calls `SMAppService.mainApp.register()` / `unregister()`. The settings toggle and the menu toggle share `SettingsStore.launchAtLogin`. Most reliable after the app lives in `/Applications`.
