import Foundation

public struct LightProgramSecondary: LightProgram {
    public init() {}

    public func computeStateSet(context: StateContext) -> LightStateSet {
        let change = LightState(entityId: "light.secondary", on: true, brightness: 1)
        return LightStateSet(changes: [change], currentStates: context.states)
    }
}
