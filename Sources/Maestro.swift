import Foundation

public struct LightStateChange {
    public let entityId: String
    public let on: Bool
}

/// Encapsulates logic to translate Home Assistant events into light states.
public final class Maestro {
    private let api: HomeAssistantAPI
    private let clock: () -> Date

    public init(api: HomeAssistantAPI, clock: @escaping () -> Date = Date.init) {
        self.api = api
        self.clock = clock
    }

    /// Handles a change for a given entity and returns the light changes.
    @discardableResult
    public func handleStateChange(entityId: String, newState: String) -> [LightStateChange] {
        // Example logic: if a motion sensor turns "on" in the evening, turn on the living room light.
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hour = Int(formatter.string(from: clock())) ?? 12
        var changes: [LightStateChange] = []

        if entityId == "sensor.motion" && newState == "on" && hour >= 18 {
            changes.append(LightStateChange(entityId: "light.living_room", on: true))
        }

        for change in changes {
            api.setLightState(entityId: change.entityId, on: change.on)
        }
        return changes
    }
}
