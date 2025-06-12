public extension Array where Element == LightState {
    mutating func on(_ entityId: String, brightness: Int? = nil, colorTemperature: Int? = nil) {
        append(LightState(entityId: entityId, on: true, brightness: brightness, colorTemperature: colorTemperature))
    }

    mutating func on(_ entityIds: [String], brightness: Int? = nil, colorTemperature: Int? = nil) {
        for id in entityIds { on(id, brightness: brightness, colorTemperature: colorTemperature) }
    }

    mutating func off(_ entityId: String) {
        append(LightState(entityId: entityId, on: false))
    }

    mutating func off(_ entityIds: [String]) {
        for id in entityIds { off(id) }
    }
}
