import XCTest
@testable import maestro

final class MaestroTests: XCTestCase {
    private final class MockAPI: HomeAssistantAPI {
        var states: [String: String] = [:]
        var setCalls: [(String, Bool)] = []

        func fetchState(entityId: String) -> String? {
            states[entityId]
        }

        func setLightState(entityId: String, on: Bool) {
            setCalls.append((entityId, on))
        }
    }

    func testMotionEveningTurnsOnLight() {
        let api = MockAPI()
        // Set current time to 19:00
        let date = ISO8601DateFormatter().date(from: "2024-01-01T19:00:00Z")!
        let maestro = Maestro(api: api, clock: { date })
        _ = maestro.handleStateChange(entityId: "sensor.motion", newState: "on")
        XCTAssertEqual(api.setCalls.count, 1)
        XCTAssertEqual(api.setCalls.first?.0, "light.living_room")
        XCTAssertEqual(api.setCalls.first?.1, true)
    }
}
