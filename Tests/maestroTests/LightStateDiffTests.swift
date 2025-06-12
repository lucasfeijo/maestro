import XCTest
@testable import maestro

final class LightStateDiffTests: XCTestCase {
    func testSimplifiedFiltersUnchangedStates() {
        let currentStates: HomeAssistantStateMap = [
            "light.test": [
                "state": "on",
                "attributes": [
                    "brightness": 255 // 100%
                ]
            ]
        ]
        
        let changes = [
            LightState(entityId: "light.test", on: true, brightness: 100) // Already at 100%
        ]
        
        let diff = LightStateDiff(changes: changes, currentStates: currentStates)
        XCTAssertEqual(diff.simplified.count, 0)
    }
    
    func testSimplifiedIncludesChangedStates() {
        let currentStates: HomeAssistantStateMap = [
            "light.test": [
                "state": "on",
                "attributes": [
                    "brightness": 128 // 50%
                ]
            ]
        ]
        
        let changes = [
            LightState(entityId: "light.test", on: true, brightness: 100) // Change to 100%
        ]
        
        let diff = LightStateDiff(changes: changes, currentStates: currentStates)
        XCTAssertEqual(diff.simplified.count, 1)
        XCTAssertEqual(diff.simplified[0].brightness, 100)
    }
    
    func testSimplifiedIncludesOnOffChanges() {
        let currentStates: HomeAssistantStateMap = [
            "light.test": [
                "state": "on"
            ]
        ]
        
        let changes = [
            LightState(entityId: "light.test", on: false)
        ]
        
        let diff = LightStateDiff(changes: changes, currentStates: currentStates)
        XCTAssertEqual(diff.simplified.count, 1)
        XCTAssertEqual(diff.simplified[0].on, false)
    }
}
