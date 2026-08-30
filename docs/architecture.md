# Zoomie architecture

Feature folders under `Zoomie/`: App, Settings, Calendar, Banner, Scheduling. One Swift type per file. Shared UI numbers live in `Design`. Settings persist through `SettingsStore` → `UserDefaults`.

Deployment target is macOS 14 (Sonoma); later macOS versions are supported. `SettingsStore` and `CalendarService` are `@Observable` `@MainActor` classes. Settings views take them as `@Bindable`. `AppRuntime` and `EventScheduler` are plain `@MainActor` classes. UserDefaults writes live in `SettingsStore` property `didSet` — not `@AppStorage` inside the observable class.

## Banner window

`BannerController` builds an AppKit `NSPanel` itself and hosts `BannerView` in an `NSHostingView`. This is not a SwiftUI `WindowGroup` window.

The panel is borderless, transparent, click-through (`ignoresMouseEvents = true`), level `.screenSaver`, and uses collection behavior `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]` so it can appear over other spaces and fullscreen apps without taking the key window or the Dock.

The window is sized to the banner content (character + text), not the full screen. It sits near the top of `NSScreen.main` (menu-bar offset via `Design.bannerTopMargin`).

## Marquee

The **window** moves, not an inner SwiftUI slide. Start frame `x = screen.minX - bannerWidth` (fully off the left). End frame `x = screen.maxX` (fully off the right). `NSAnimationContext.runAnimationGroup` animates `panel.animator().setFrame` over `Design.animationDuration` (4.5s), linear. Then the panel is ordered out. Only one banner runs at a time (`isShowing`).

On fire, `NSSound(named: "Glass")` plays (falls back to Ping, then `NSSound.beep()`).

**Test Now** (`AppRuntime.previewBanner()`) uses the same `BannerController` path with a fake title (`MessageTemplate.previewEventTitle`) and the current lead-time minutes. Menu bar and Settings both call it. `preview()` no-ops if a banner is already on screen. A real scheduled fire that lands during a preview is stored as `pending` and starts when the preview finishes, so two banners never overlap and the meeting reminder is not dropped.

## Scheduling

`EventScheduler` keeps **one** `Timer` on the main run loop. No poll loop.

On launch, after a fire, after a scheduling-relevant settings change, on `EKEventStoreChanged`, and on wake: query EventKit for the next qualifying fires, then either fire immediately (catch-up) or `Timer(fire:interval:repeats:)` for that exact date.

A fire is `event.startDate - leadTimeMinutes`, plus `event.startDate` when “Also ping at meeting start” is on. Already-shown fires are remembered in-memory (`deliveredKeys`) so catch-up does not repeat in the same process.

If two fire times fall within `Design.clusterWindow` (5 seconds), extras wait in `queue` and start when the current banner finishes. Two banners never overlap.

If nothing is upcoming in the 60-day look-ahead, a single refresh timer is set for 24 hours so the scheduler does not go silent forever.

## Sleep / wake

`NSWorkspace.didWakeNotification` invalidates the current timer and runs the same reschedule path as launch. `Timer` does not fire during sleep; a pre-sleep fire date would be stale after wake.

## Calendar filtering

`CalendarService` uses EventKit only (`requestFullAccessToEvents`). Denied access shows one alert pointing at **System Settings > Privacy & Security > Calendars**, then the app exits. No retry loop.

`EventQualifying` is the pure filter: non-empty title, not all-day, user has not declined (current-user attendee status `.declined`), calendar not in `disabledCalendarIDs`. New calendars are on by default because we store the disabled set, not the enabled set.

## Launch at login

`LoginItemService` calls `SMAppService.mainApp.register()` / `unregister()`. The settings toggle and the menu toggle share `SettingsStore.launchAtLogin`. Most reliable after the app lives in `/Applications`.
