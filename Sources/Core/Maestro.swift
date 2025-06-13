import Foundation

public final class Maestro {
    private let states: StateProvider
    private let lights: LightController
    private let program: LightProgram
    private let logger: Logger

    public init(states: StateProvider,
                lights: LightController,
                program: LightProgram,
                logger: Logger) {
        self.states = states
        self.lights = lights
        self.program = program
        self.logger = logger
    }

    /// Fetches state from Home Assistant and applies the current scene.
    /// 
    /// This method executes a 5-step process to synchronize light states:
    /// 1. STATE: Fetches all current states from Home Assistant using the API
    /// 2. CONTEXT: Derives a StateContext from the fetched states interpreting the scene and environment
    /// 3. PROGRAM: Computes the desired light states based on the current context
    /// 4. CHANGESET: Simplifies the state changes to minimize transitions
    /// 5. LIGHTS: Applies each new light state to the physical lights
    ///
    /// If any step fails, the error is logged and the process stops.
    public func run() {
        let result = states.fetchAllStates()
        switch result {
        case .success(let states):
            let context = StateContext(states: states)
            let output = program.compute(context: context)
            var effects = output.sideEffects
            for newLightState in output.changeset.simplified {
                effects.append(.setLight(newLightState))
            }
            for effect in effects {
                effect.perform(using: lights)
            }
        case .failure(let error):
            logger.error("Failed to fetch home assistant states: \(error)")
        }
    }
}
