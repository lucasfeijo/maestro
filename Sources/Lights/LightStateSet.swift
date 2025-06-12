import Foundation

public struct LightStateSet {
    public let changes: [LightState]
    public let currentStates: HomeAssistantStateMap

    public init(changes: [LightState], currentStates: HomeAssistantStateMap) {
        self.changes = changes
        self.currentStates = currentStates
    }

    /// A simplified list of states omitting changes that would not alter
    /// the current Home Assistant state.
    public var simplified: [LightState] {
        var simplified: [LightState] = []
        for change in changes {
            if let current = currentStates[change.entityId],
               let state = current["state"] as? String {
                var shouldSend = false
                if (state == "on") != change.on {
                    shouldSend = true
                } else if let desired = change.brightness,
                          let attrs = current["attributes"] as? [String: Any],
                          let curr = attrs["brightness"] as? Int {
                    let pct = Int(round(Double(curr) * 100.0 / 255.0))
                    if pct != desired { shouldSend = true }
                } else if change.brightness != nil {
                    shouldSend = true
                }
                if !shouldSend { continue }
            }
            simplified.append(change)
        }
        return simplified
    }
}
