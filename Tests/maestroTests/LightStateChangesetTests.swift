import XCTest
@testable import maestro

final class LightStateChangesetTests: XCTestCase {
    func testSimplifiedFiltersUnchangedStates() {
        let simplified = LightStateChangeset(
            currentStates: ["light.tv_light": ["state": "on", "attributes": ["brightness": 50]]],
            desiredStates: [LightState(entityId: "light.tv_light", on: true, brightness: 50)]
        ).simplified
        XCTAssertTrue(simplified.isEmpty)
    }

    func testSimplifiedIncludesChangedStates() {
        let simplified = LightStateChangeset(
            currentStates: ["light.tv_light": ["state": "on", "attributes": ["brightness": 102]]],
            desiredStates: [LightState(entityId: "light.tv_light", on: true, brightness: 50)]
        ).simplified
        let tvLight = simplified.first { $0.entityId == "light.tv_light" }
        XCTAssertEqual(tvLight?.brightness, 50)
    }

    func testSimplifiedIncludesOnOffChanges() {
        let simplified = LightStateChangeset(
            currentStates: ["light.corner_light": ["state": "on"]],
            desiredStates: [LightState(entityId: "light.corner_light", on: false)]
        ).simplified
        let corner = simplified.first { $0.entityId == "light.corner_light" }
        XCTAssertEqual(corner?.on, false)
    }

    func testSimplifiedIgnoresSmallBrightnessDifference() {
        let simplified = LightStateChangeset(
            currentStates: ["light.tv_light": ["state": "on", "attributes": ["brightness": 51]]],
            desiredStates: [LightState(entityId: "light.tv_light", on: true, brightness: 50)]
        ).simplified
        XCTAssertTrue(simplified.isEmpty)
    }
}
