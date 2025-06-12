import Foundation


/// Encapsulates logic to translate Home Assistant events into light states.
public final class Maestro {
    private let api: HomeAssistantAPI
    private let lights: LightController
    private let clock: () -> Date

    public init(api: HomeAssistantAPI, lights: LightController, clock: @escaping () -> Date = Date.init) {
        self.api = api
        self.lights = lights
        self.clock = clock
    }

    /// Fetches state from Home Assistant and applies the current scene.
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
