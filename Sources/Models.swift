import Foundation

public struct LightStateChange {
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
