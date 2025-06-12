import Foundation

public struct LightState {
    public let entityId: String
    public let on: Bool
    public let brightness: Int?
    public let colorTemperature: Int?

    public init(entityId: String, on: Bool, brightness: Int? = nil, colorTemperature: Int? = nil) {
        self.entityId = entityId
        self.on = on
        self.brightness = brightness
        self.colorTemperature = colorTemperature
    }
}

public struct LightStateDiff {
    public let changes: [LightState]
    public let currentStates: HomeAssistantStateMap

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

    public init(changes: [LightState], currentStates: HomeAssistantStateMap) {
        self.changes = changes
        self.currentStates = currentStates
    }
}

public enum Scene {
    case off, calmNight, normal, bright, brightest, preset
}

public enum TimeOfDay {
    case daytime, preSunset, sunset, nighttime
}

public struct Environment {
    public var timeOfDay: TimeOfDay
    public var hyperionRunning: Bool
    public var diningPresence: Bool
    public var kitchenPresence: Bool
    public var kitchenExtraBrightness: Bool

    public init(timeOfDay: TimeOfDay, hyperionRunning: Bool, diningPresence: Bool, kitchenPresence: Bool, kitchenExtraBrightness: Bool) {
        self.timeOfDay = timeOfDay
        self.hyperionRunning = hyperionRunning
        self.diningPresence = diningPresence
        self.kitchenPresence = kitchenPresence
        self.kitchenExtraBrightness = kitchenExtraBrightness
    }
}
