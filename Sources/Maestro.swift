import Foundation

public final class Maestro {
    private let api: HomeAssistantAPI
    private let lights: LightController

    public init(api: HomeAssistantAPI, lights: LightController) {
        self.api = api
        self.lights = lights
    }

    /// Fetches state from Home Assistant and applies the current scene.
    /// 
    /// This method executes a 5-step process to synchronize light states:
    /// 1. Fetches all current states from Home Assistant using the API
    /// 2. Derives a StateContext from the fetched states interpreting the scene and environment
    /// 3. Computes the desired light states based on the current context
    /// 4. Simplifies the state changes to minimize transitions
    /// 5. Applies each new light state to the physical lights
    ///
    /// If any step fails, the error is logged and the process stops.
    public func run() {
        let result = api.fetchAllStates()
        switch result {
        case .success(let states):
            let context = StateContext(states: states)
            let diff = context.computeDesiredStates()
            for newLightState in diff.simplified {
                lights.setLightState(state: newLightState)
            }
        case .failure(let error):
                print("Failed to fetch home assistant states: \(error)")
        }
    }
}
