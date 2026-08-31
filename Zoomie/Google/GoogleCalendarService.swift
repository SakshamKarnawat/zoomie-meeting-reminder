import Foundation
import SwiftUI

@MainActor
@Observable
final class GoogleCalendarService {
    var calendars: [CalendarDescriptor] = []
    var email: String?
    var isBusy = false
    var errorMessage: String?
    private(set) var snapshotID = 0
    private var tokens: GoogleTokens?
    private var cachedEvents: [TimedEvent] = []

    var isSignedIn: Bool { tokens != nil }

    init() {
        tokens = GoogleTokenStore.load()
        email = tokens?.email
    }

    func signIn() async {
        guard GoogleClientConfig.isConfigured else {
            errorMessage = GoogleOAuthError.notConfigured.localizedDescription
            return
        }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        do {
            let next = try await GoogleOAuthClient.signIn()
            try GoogleTokenStore.save(next)
            tokens = next
            email = next.email
            try await pull(using: next)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func signOut() async {
        if let tokens {
            await GoogleOAuthClient.revoke(tokens)
        }
        GoogleTokenStore.clear()
        tokens = nil
        email = nil
        calendars = []
        cachedEvents = []
        errorMessage = nil
        snapshotID += 1
    }

    func refresh() async {
        guard var tokens else { return }
        isBusy = true
        errorMessage = nil
        defer { isBusy = false }
        do {
            if tokens.isExpired {
                tokens = try await rotate(tokens)
            }
            do {
                try await pull(using: tokens)
            } catch GoogleOAuthError.httpStatus(401) {
                tokens = try await rotate(tokens)
                try await pull(using: tokens)
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func timedEvents(disabledCalendarIDs: Set<String>, from now: Date) -> [TimedEvent] {
        cachedEvents.filter { event in
            event.startDate > now || (event.endDate ?? event.startDate) > now
        }
        .filter { event in
            !disabledCalendarIDs.contains(event.calendarID)
        }
    }

    private func rotate(_ tokens: GoogleTokens) async throws -> GoogleTokens {
        let next = try await GoogleOAuthClient.refresh(tokens)
        try GoogleTokenStore.save(next)
        self.tokens = next
        email = next.email
        return next
    }

    private func pull(using tokens: GoogleTokens) async throws {
        let entries = try await GoogleCalendarAPI.calendarList(accessToken: tokens.accessToken)
        calendars = entries.map { entry in
            CalendarDescriptor(
                id: CalendarSource.google.namespacedID(entry.id),
                title: entry.summary ?? entry.id,
                color: StoredColor.color(fromHex: entry.backgroundColor ?? StoredColor.defaultHex),
                source: .google
            )
        }
        .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }

        let now = Date.now
        let horizon = now.addingTimeInterval(TimeInterval(Design.lookAheadDays * 24 * 60 * 60))
        var events: [TimedEvent] = []
        for entry in entries {
            let dtos = try await GoogleCalendarAPI.events(
                calendarID: entry.id,
                accessToken: tokens.accessToken,
                from: now,
                to: horizon
            )
            let calendarID = CalendarSource.google.namespacedID(entry.id)
            for dto in dtos {
                if let timed = TimedEvent(google: dto, calendarID: calendarID) {
                    events.append(timed)
                }
            }
        }
        cachedEvents = events
        snapshotID += 1
    }
}
