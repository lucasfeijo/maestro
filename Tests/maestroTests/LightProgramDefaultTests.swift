import XCTest
@testable import maestro

final class LightProgramDefaultTests: XCTestCase {
    func testOffSceneTurnsAllLightsOff() {
        let context = StateContext(states: ["input_select.living_scene": ["state": "off"]])
        let diff = LightProgramDefault().computeStateSet(context: context)
        
        // Verify all lights are turned off
        for lightState in diff.changes {
            XCTAssertFalse(lightState.on, "Expected light \(lightState.entityId) to be off")
        }
    }

    func testNormalSceneHyperionRunning() {
        let context = StateContext(states: [
            "input_select.living_scene": ["state": "normal"],
            "sun.sun": ["state": "above_horizon"],
            "binary_sensor.living_tv_hyperion_running_condition_for_the_scene": ["state": "on"],
            "binary_sensor.dining_espresence": ["state": "off"],
            "binary_sensor.kitchen_espresence": ["state": "off"],
            "input_boolean.kitchen_extra_brightness": ["state": "off"]
        ])
        let diff = LightProgramDefault().computeStateSet(context: context)
        
        let tvLight = diff.changes.first { $0.entityId == "light.tv_light" }
        XCTAssertFalse(tvLight?.on ?? true)
        
        let tvShelf = diff.changes.first { $0.entityId == "light.tv_shelf_group" }
        XCTAssertFalse(tvShelf?.on ?? true)
    }

    func testBrightSceneHyperionRunning() {
        let context = StateContext(states: [
            "input_select.living_scene": ["state": "bright"],
            "sun.sun": ["state": "above_horizon"],
            "binary_sensor.living_tv_hyperion_running_condition_for_the_scene": ["state": "on"],
            "binary_sensor.dining_espresence": ["state": "off"],
            "binary_sensor.kitchen_espresence": ["state": "off"],
            "input_boolean.kitchen_extra_brightness": ["state": "off"]
        ])
        let diff = LightProgramDefault().computeStateSet(context: context)
        
        let tvLight = diff.changes.first { $0.entityId == "light.tv_light" }
        XCTAssertFalse(tvLight?.on ?? true)
    }

    func testCalmNightDiningPresenceLightsIncrease() {
        let contextWithPresence = StateContext(states: [
            "input_select.living_scene": ["state": "calm night"],
            "sun.sun": ["state": "below_horizon"],
            "binary_sensor.living_tv_hyperion_running_condition_for_the_scene": ["state": "off"], 
            "binary_sensor.dining_espresence": ["state": "on"],
            "binary_sensor.kitchen_espresence": ["state": "on"],
            "input_boolean.kitchen_extra_brightness": ["state": "off"]
        ])
        let contextWithoutPresence = StateContext(states: [
            "input_select.living_scene": ["state": "calm night"],
            "sun.sun": ["state": "below_horizon"],
            "binary_sensor.living_tv_hyperion_running_condition_for_the_scene": ["state": "off"], 
            "binary_sensor.dining_espresence": ["state": "off"],
            "binary_sensor.kitchen_espresence": ["state": "off"],
            "input_boolean.kitchen_extra_brightness": ["state": "off"]
        ])
        
        let diffWithPresence = LightProgramDefault().computeStateSet(context: contextWithPresence)
        let diffWithoutPresence = LightProgramDefault().computeStateSet(context: contextWithoutPresence)
        
        // dining table brighter when presence detected
        let diningWithPresence = diffWithPresence.changes.first { $0.entityId == "light.dining_table_light" }
        let diningWithoutPresence = diffWithoutPresence.changes.first { $0.entityId == "light.dining_table_light" }
        XCTAssertGreaterThan(diningWithPresence?.brightness ?? 0, diningWithoutPresence?.brightness ?? 0)
    }
}
