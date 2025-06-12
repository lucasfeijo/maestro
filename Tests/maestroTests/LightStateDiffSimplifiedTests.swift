import XCTest
@testable import maestro

final class LightStateDiffSimplifiedTests: XCTestCase {
    func testSimplifiedFiltersUnchangedStates() {
        let simplified = LightStateDiff(
            changes: [LightState(entityId: "light.tv_light", on: true, brightness: 50)],
            currentStates: [
                "light.tv_light": [
                    "state": "on",
                    "attributes": ["brightness": 128]
                ]
            ]
        ).simplified
        XCTAssertTrue(simplified.isEmpty)
    }

    func testSimplifiedIncludesChangedStates() {
        let simplified = LightStateDiff(
            changes: [LightState(entityId: "light.tv_light", on: true, brightness: 50)],
            currentStates: [
                "light.tv_light": [
                    "state": "on",
                    "attributes": ["brightness": 102]
                ]
            ]
        ).simplified
        let tvLight = simplified.first { $0.entityId == "light.tv_light" }
        XCTAssertEqual(tvLight?.brightness, 50)
    }

    func testSimplifiedIncludesOnOffChanges() {
        let simplified = LightStateDiff(
            changes: [LightState(entityId: "light.corner_light", on: false)],
            currentStates: ["light.corner_light": ["state": "on"]]
        ).simplified
        let corner = simplified.first { $0.entityId == "light.corner_light" }
        XCTAssertEqual(corner?.on, false)
    }
}
