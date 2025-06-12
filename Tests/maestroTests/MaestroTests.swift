import XCTest
@testable import maestro

final class MaestroTests: XCTestCase {
    private final class MockAPI: HomeAssistantAPI, LightController {
        private let states: [String: String]
        struct Call { let entity: String; let on: Bool; let brightness: Int?; let colorTemp: Int? }
        var setCalls: [Call] = []

        init(states: [String: String]) {
            self.states = states
        }

        func fetchAllStates() -> Result<HomeAssistantStateMap, Error> {
            .success(states.mapValues { ["state": $0] })
        }

        func setLightState(entityId: String, on: Bool, brightness: Int?, colorTemperature: Int?) {
            setCalls.append(Call(entity: entityId, on: on, brightness: brightness, colorTemp: colorTemperature))
        }
    }

    func testCalmNightDiningPresence() {
        let api = MockAPI(states: [
            "input_select.living_scene": "calm night",
            "sun.sun": "below_horizon",
            "binary_sensor.living_tv_hyperion_running_condition_for_the_scene": "off",
            "binary_sensor.dining_espresence": "on",
            "binary_sensor.kitchen_espresence": "on",
            "input_boolean.kitchen_extra_brightness": "off"
        ])
        let maestro = Maestro(api: api, lights: api)
        maestro.run()
        
        // dining table bright when presence
        let dining = api.setCalls.first { $0.entity == "light.dining_table_light" }
        XCTAssertEqual(dining?.brightness, 30)
        // tv shelf group on because hyperion off
        let shelf = api.setCalls.first { $0.entity == "light.tv_shelf_group" }
        XCTAssertEqual(shelf?.on, true)
    }

    func testBrightSceneHyperionRunning() {
        let api = MockAPI(states: [
            "input_select.living_scene": "bright",
            "sun.sun": "above_horizon",
            "binary_sensor.living_tv_hyperion_running_condition_for_the_scene": "on",
            "binary_sensor.dining_espresence": "off",
            "binary_sensor.kitchen_espresence": "off",
            "input_boolean.kitchen_extra_brightness": "off"
        ])
        let maestro = Maestro(api: api, lights: api)
        maestro.run()
        
        let tv = api.setCalls.first { $0.entity == "light.tv_light" }
        XCTAssertEqual(tv?.on, false)
    }
}
