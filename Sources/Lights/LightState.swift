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