import Foundation

public struct LightStateDiff {
    public let changes: [LightState]
    public let currentStates: HomeAssistantStateMap

    public init(changes: [LightState], currentStates: HomeAssistantStateMap) {
        self.changes = changes
        self.currentStates = currentStates
    }
}

extension LightStateDiff {
    public var simplified: LightStateDiffSimplified {
        LightStateDiffSimplified(self)
    }
}
