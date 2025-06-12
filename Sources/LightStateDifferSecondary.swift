import Foundation

public struct LightStateDifferSecondary: LightStateDiffer {
    public init() {}

    public func makeDiff(context: StateContext) -> LightStateDiff {
        let change = LightState(entityId: "light.secondary", on: true, brightness: 1)
        return LightStateDiff(changes: [change], currentStates: context.states)
    }
}
