import Testing
@testable import Zoomie

struct MessageTemplateTests {
    @Test func substitutesEventAndMinutes() {
        let rendered = MessageTemplate.render(
            "{event} in {mins} min",
            event: "Standup",
            minutes: 5
        )
        #expect(rendered == "Standup in 5 min")
    }

    @Test func usesDefaultWhenTemplateBlank() {
        let rendered = MessageTemplate.render("   ", event: "Retro", minutes: 10)
        #expect(rendered == "Retro in 10 min")
    }

    @Test func substitutesZeroMinutesAtStart() {
        let rendered = MessageTemplate.render(
            "{event} in {mins} min",
            event: "1:1",
            minutes: 0
        )
        #expect(rendered == "1:1 in 0 min")
    }
}
