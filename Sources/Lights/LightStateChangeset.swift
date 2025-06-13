import Foundation

// CHANGESET:
public struct LightStateChangeset {
    public let desiredStates: [LightState]
    public let currentStates: HomeAssistantStateMap

    public init(currentStates: HomeAssistantStateMap, desiredStates: [LightState]) {
        self.desiredStates = desiredStates
        self.currentStates = currentStates
    }

    /// A simplified list of states omitting changes that would not alter
    /// the current Home Assistant state.
    public var simplified: [LightState] {
        var simplified: [LightState] = []
        for change in desiredStates {

            if let current = currentStates[change.entityId],
               let state = current["state"] as? String {
                var shouldSend = false
                if (state == "on") != change.on {
                    shouldSend = true
                } else if let desired = change.brightness,
                          let attrs = current["attributes"] as? [String: Any],
                          let curr = attrs["brightness"] as? Int {
                    let pct: Int
                    if curr <= 100 {
                        pct = curr
                    } else {
                        pct = Int(round(Double(curr) * 100.0 / 255.0))
                    }
                    if abs(pct - desired) > 1 { shouldSend = true }
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
