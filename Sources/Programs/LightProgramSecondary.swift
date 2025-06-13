import Foundation

public struct LightProgramSecondary: LightProgram {
    public let name = "secondary"
    public init() {}

    public func computeStateSet(context: StateContext) -> LightStateChangeset {
        let change = LightState(entityId: "light.secondary", on: true, brightness: 1)
        return LightStateChangeset(currentStates: context.states, desiredStates: [change])
    }
}
