import XCTest
@testable import maestro

final class MaestroDynamicScenesTests: XCTestCase {
    final class DummyStateProvider: StateProvider {
        let states: HomeAssistantStateMap
        init(states: HomeAssistantStateMap) { self.states = states }
        func fetchAllStates() -> Result<HomeAssistantStateMap, Error> { .success(states) }
    }

    final class DummyLightController: LightController {
        var stopCount = 0
        func setLightState(state: LightState) {}
        func stopAllDynamicScenes() { stopCount += 1 }
    }

    final class StubProgram: LightProgram {
        let name = "stub"
        func computeStateSet(context: StateContext) -> LightStateChangeset {
            .init(currentStates: context.states, desiredStates: [])
        }
    }

    func testStopsDynamicScenesWhenNotPreset() {
        let provider = DummyStateProvider(states: [
            "input_select.living_scene": ["state": "normal"],
            "input_boolean.living_scene_auto": ["state": "on"]
        ])
        let lights = DummyLightController()
        let maestro = Maestro(states: provider, lights: lights, program: StubProgram(), logger: Logger(pusher: nil))
        maestro.run()
        XCTAssertEqual(lights.stopCount, 1)
    }

    func testDoesNotStopDynamicScenesForPreset() {
        let provider = DummyStateProvider(states: [
            "input_select.living_scene": ["state": "preset"],
            "input_boolean.living_scene_auto": ["state": "on"]
        ])
        let lights = DummyLightController()
        let maestro = Maestro(states: provider, lights: lights, program: StubProgram(), logger: Logger(pusher: nil))
        maestro.run()
        XCTAssertEqual(lights.stopCount, 0)
    }
}
