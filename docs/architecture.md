# Zoomie architecture

Feature folders under `Zoomie/`: App, Settings, Calendar, Banner, Scheduling, Update. One Swift type per file. Shared UI numbers live in `Design`. Settings persist through `SettingsStore` → `UserDefaults`.

Deployment target is macOS 14 (Sonoma); later macOS versions are supported. `SettingsStore` and `CalendarService` are `@Observable` `@MainActor` classes. Settings views take them as `@Bindable`. `AppRuntime` and `EventScheduler` are plain `@MainActor` classes. UserDefaults writes live in `SettingsStore` property `didSet` — not `@AppStorage` inside the observable class.

## Banner window

`BannerController` builds an AppKit `NSPanel` itself and hosts `BannerView` in an `NSHostingView`. This is not a SwiftUI `WindowGroup` window.

The panel is borderless, transparent, click-through (`ignoresMouseEvents = true`), level `.screenSaver`, and uses collection behavior `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]` so it can appear over other spaces and fullscreen apps without taking the key window or the Dock.

The window is sized to the banner content (character + ribbon), not the full screen. Vertical placement is `BannerPlacement.originY(visibleFrame:bannerHeight:fromTop:)` using `SettingsStore.resolvedFromTop` (0 = top, 1 = bottom, with `BannerPlacement.edgeInset`). Settings preview calls the same `offsetFromTop` and scales it — no second formula.

## Settings window

`AppRuntime` keeps one `SettingsWindowController` and one `AboutWindowController`. There is no SwiftUI `Settings` scene and no `SettingsLink` — those do not refocus an already-open window while Zoomie is an accessory app (`LSUIElement`). Menu **Settings…** / **About Zoomie…** create the window on first click; later clicks use `AppActivation.bringToFront` (`setActivationPolicy(.regular)`, `activate(ignoringOtherApps: true)`, `makeKeyAndOrderFront`) on that same instance. Close orders the window out (`isReleasedWhenClosed = false`, `windowShouldClose` returns false) and `AppActivation.restoreAccessoryIfNeeded` only if no other titled window is visible. Two settings windows and two about windows are never created.

## Menu bar and app icon

`MenuBarExtra` uses `MenuBarIcon.templateImage`: SF Symbol `pawprint.fill` as an `NSImage` with `isTemplate = true`, sized to 18 pt so it matches other menu bar icons and follows light/dark tint. The Dock/Finder icon is `AppIcon.appiconset` (OpenMoji color `1F436`, 16–1024 px). `scripts/generate-icons.sh` downloads the 618×618 color source if needed and resizes it with `sips` — it does not generate the tray icon.

The menu’s first block is `NextEventMenuSection`: on appear it asks `CalendarService.nextUpcomingEvent` (same `EventQualifying` filter as the scheduler, including muted titles) and shows `UpcomingEventLabel` plus **Join** when `MeetingLink` found an http(s) URL on the event, notes, or location (Zoom / Meet / Teams / FaceTime / Webex preferred). **Sync Calendars Now** is the same `CalendarSync.syncNow()` as Settings. **Update Zoomie** calls `AppUpdateService.installLatest`, which runs `install.sh` from GitHub.

## Marquee

The **window** moves, not an inner SwiftUI slide. `BannerAnimator` runs one 120 Hz `Timer` on the main `.common` run loop and only writes `setFrameOrigin` each tick — it does not rebuild the SwiftUI view. (A window-tied `CADisplayLink` was dropped: the panel starts fully off-screen, so that link never fired and Test Now played the sound with no visible banner.) Speed is `Design.pixelsPerSecond` (220). Duration is `(screenWidth + bannerWidth) / speed`. `BannerMotion.progress` eases the first and last 10% (`Design.easePortion`); the middle stretch is linear. Start `x = screen.minX - bannerWidth`, end `x = screen.maxX`. Hosted in `NSHostingController` sized with `sizeThatFits`, not a forced 2400-pt frame. Then the panel is ordered out. Only one banner runs at a time (`isShowing`).

The hosted view is one fixed layout: fluttering ribbon (V-notch on the trailing/left edge; `RibbonShape.phase` driven by `TimelineView` at 30 Hz, ~2.4 pt sine on the edges) + overlapping rope (`Design.ropeOverlap`) + Cat/Corgi vector silhouette (or a static custom image) on the leading/right edge, with a drop shadow on the whole group. Drawn characters are `Design.customCharacterSide` (80 pt). Fill is `CharacterPaint.gradient` (a short highlight → base → shade lerp of `SettingsStore.characterColor`). Behind them, `CharacterBackdrop` draws a blurred radial plate in `CharacterPaint.plate` — a hue-tinted opposite-luminance wash — so cream reads on a bright desktop and black reads on a dark one. Eyes are white with black pupils. Custom uploads ignore fill and plate. Cat/Corgi bob and wag via the same `TimelineView` clock; custom uploads do not animate. `--preview-banner` on launch fires `previewBanner()` after a short delay.

On fire, `NSSound(named: "Glass")` plays (falls back to Ping, then `NSSound.beep()`).

**Test Now** (`AppRuntime.previewBanner()`) uses the same `BannerController` path with a fake title (`MessageTemplate.previewEventTitle`) and the current lead-time minutes. Menu bar and Settings both call it. `preview()` no-ops if a banner is already on screen. A real scheduled fire that lands during a preview is stored as `pending` and starts when the preview finishes, so two banners never overlap and the meeting reminder is not dropped.

## Scheduling

`EventScheduler` keeps **one** `Timer` on the main run loop for the next banner fire. No poll loop for fires.

On launch, after a fire, after a scheduling-relevant settings change, on `EKEventStoreChanged`, and on wake: query EventKit for the next qualifying fires, then either fire immediately (catch-up) or `Timer(fire:interval:repeats:)` for that exact date.

A fire is `event.startDate - leadTimeMinutes`, plus `event.startDate` when “Also ping at meeting start” is on. Already-shown fires are remembered in-memory (`deliveredKeys`) so catch-up does not repeat in the same process.

If two fire times fall within `Design.clusterWindow` (10 seconds — about one traverse at 220 px/s on a typical display), extras wait in `queue` and start when the current banner finishes. Two banners never overlap.

If nothing is upcoming in the 60-day look-ahead, a single refresh timer is set for 24 hours so the scheduler does not go silent forever.

## Sleep / wake

`NSWorkspace.didWakeNotification` invalidates the current timer and runs the same reschedule path as launch. `Timer` does not fire during sleep; a pre-sleep fire date would be stale after wake.

`CalendarSync` is a second, repeating timer (`SettingsStore.calendarSyncInterval`, default 6 hours: 4 / 6 / 12 / 24). Each tick and each wake calls `EKEventStore.refreshSourcesIfNecessary()`, then `refreshCalendars()` and `EventScheduler.reschedule()`. Changing the interval restarts that timer. **Sync Now** (Settings next to the interval picker, and the menu item) calls the same `syncNow()` path without resetting the interval timer. This is a background pull of accounts already in Calendar.app — not a substitute for `EKEventStoreChanged`, which still reschedules immediately.

## Calendar filtering

`CalendarService` uses EventKit only (`requestFullAccessToEvents`). Denied access shows one alert pointing at **System Settings > Privacy & Security > Calendars**, then the app exits. No retry loop.

`EventQualifying` is the pure filter: non-empty title, not all-day, user has not declined (current-user attendee status `.declined`), calendar not in `disabledCalendarIDs`, title not matched by `MutedTitle` against `SettingsStore.mutedTitleTokens` (comma-separated, default `busy, blocked, focus, hold, ooo`; single tokens are whole-word so “Busy” mutes and “Business review” does not). New calendars are on by default because we store the disabled set, not the enabled set.

## Updates

`AppUpdateService` is `@Observable` `@MainActor`. **Check for Updates** GETs the GitHub `latest` release (User-Agent `Zoomie/<marketing>`) and `AppUpdateCheck` compares `Zoomie.zip` `updated_at` to the running binary’s modification date. **Update Zoomie** (menu, About window, Settings About section) starts `/bin/bash -lc` with the same `curl | bash` as `install.sh`. The Settings About section and About window share `UpdateActionsView`.

## Install

`install.sh` downloads `Zoomie.zip` from GitHub’s latest release (`/releases/latest`), copies `Zoomie.app` to `/Applications` (or `~/Applications` if needed), runs `xattr -rd com.apple.quarantine`, and opens the app.

`.github/workflows/release.yml` builds that unsigned arm64 zip on `macos-26` (Xcode 26, same project format as this repo) on every push to `main` and on manual workflow dispatch. `macos-14` ships Xcode 15.4, which cannot open objectVersion 77.

Versioning is semantic. `scripts/semver.sh` (one file) prints the next `X.Y.Z` from the latest ancestor `v*` tag (or `1.0.0` if none) and Conventional Commits since that tag: `feat` → minor, `type!` / `BREAKING CHANGE:` → major, everything else including `fix` and unprefixed messages → patch. `scripts/semver.sh notes` groups those commits into Features / Fixes / Other. `scripts/semver.sh changelog X.Y.Z` prepends that section to `CHANGELOG.md`. `scripts/semver.sh test` is the self-check; `scripts/semver.sh build X.Y.Z` is `major*10000 + minor*100 + patch`. Every push therefore increments. The workflow stamps those into `xcodebuild` as `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`, prepends `CHANGELOG.md` and commits `chore(release): vX.Y.Z [skip ci]` so it does not bump again, then `gh release create vX.Y.Z --notes-file` `--latest`. Tags are the source of truth. Local `project.pbxproj` stays at `1.0.0` / `10000` until CI overrides it for a release build.

## Launch at login

`LoginItemService` calls `SMAppService.mainApp.register()` / `unregister()`. The settings toggle and the menu toggle share `SettingsStore.launchAtLogin`. Most reliable after the app lives in `/Applications`.
