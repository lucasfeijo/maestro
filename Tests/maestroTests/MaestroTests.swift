import XCTest
@testable import maestro

final class MaestroTests: XCTestCase {
    private final class MockAPI: HomeAssistantAPI {
        var states: [String: String] = [:]
        struct Call { let entity: String; let on: Bool; let brightness: Int?; let colorTemp: Int? }
        var setCalls: [Call] = []

        func fetchState(entityId: String) -> String? {
            states[entityId]
        }

        func setLightState(entityId: String, on: Bool, brightness: Int?, colorTemperature: Int?) {
            setCalls.append(Call(entity: entityId, on: on, brightness: brightness, colorTemp: colorTemperature))
        }
    }

    func testMotionEveningTurnsOnLight() {
        let api = MockAPI()
        // Set current time to 19:00
        let date = ISO8601DateFormatter().date(from: "2024-01-01T19:00:00Z")!
        let maestro = Maestro(api: api, clock: { date })
        _ = maestro.handleStateChange(entityId: "sensor.motion", newState: "on")
        XCTAssertEqual(api.setCalls.count, 1)
        XCTAssertEqual(api.setCalls.first?.entity, "light.living_room")
        XCTAssertEqual(api.setCalls.first?.on, true)
    }

    func testCalmNightDiningPresence() {
        let api = MockAPI()
        let maestro = Maestro(api: api)
        let env = Environment(timeOfDay: .nighttime, hyperionRunning: false, diningPresence: true, kitchenPresence: true, kitchenExtraBrightness: false)
        _ = maestro.applyScene(.calmNight, environment: env)
        // dining table bright when presence
        let dining = api.setCalls.first { $0.entity == "light.dining_table_light" }
        XCTAssertEqual(dining?.brightness, 30)
        // tv shelf group on because hyperion off
        let shelf = api.setCalls.first { $0.entity == "light.tv_shelf_group" }
        XCTAssertEqual(shelf?.on, true)
    }

    func testBrightSceneHyperionRunning() {
        let api = MockAPI()
        let maestro = Maestro(api: api)
        let env = Environment(timeOfDay: .daytime, hyperionRunning: true, diningPresence: false, kitchenPresence: false, kitchenExtraBrightness: false)
        _ = maestro.applyScene(.bright, environment: env)
        let tv = api.setCalls.first { $0.entity == "light.tv_light" }
        XCTAssertEqual(tv?.on, false)
    }
}
