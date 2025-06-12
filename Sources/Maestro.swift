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
            let context = StateContext.computeFrom(states: states)
            let diff = context.computeDesiredStates()
            for change in diff.simplified {
                lights.setLightState(entityId: change.entityId, on: change.on, brightness: change.brightness, colorTemperature: change.colorTemperature)
            }
        case .failure(let error):
                print("Failed to fetch home assistant states: \(error)")
        }
    }
}
