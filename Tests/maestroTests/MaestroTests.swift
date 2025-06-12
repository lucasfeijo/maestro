import XCTest
@testable import maestro

final class MaestroTests: XCTestCase {
    private final class MockAPI: HomeAssistantAPI, LightController {
        private let states: [String: String]
        struct Call { let state: LightState }
        var setCalls: [Call] = []

        init(states: [String: String]) {
            self.states = states
        }

        func fetchAllStates() -> Result<HomeAssistantStateMap, Error> {
            .success(states.mapValues { ["state": $0] })
        }

        func setLightState(state: LightState) {
            setCalls.append(Call(state: state))
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
        let dining = api.setCalls.first { $0.state.entityId == "light.dining_table_light" }
        XCTAssertEqual(dining?.state.brightness, 30)
        // tv shelf group on because hyperion off
        let shelf = api.setCalls.first { $0.state.entityId == "light.tv_shelf_group" }
        XCTAssertEqual(shelf?.state.on, true)
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
        
        let tv = api.setCalls.first { $0.state.entityId == "light.tv_light" }
        XCTAssertEqual(tv?.state.on, false)
    }
}
