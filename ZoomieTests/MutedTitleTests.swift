import Testing
@testable import Zoomie

struct MutedTitleTests {
    @Test func tokensSplitOnComma() {
        #expect(MutedTitle.tokens(from: "busy, focus,  hold") == ["busy", "focus", "hold"])
    }

    @Test func wholeWordBusyDoesNotMatchBusiness() {
        #expect(MutedTitle.matches("Busy", tokens: ["busy"]))
        #expect(MutedTitle.matches("Business review", tokens: ["busy"]) == false)
    }

    @Test func phraseTokenMatchesInsideTitle() {
        #expect(MutedTitle.matches("Focus time", tokens: ["focus time"]))
    }
}
