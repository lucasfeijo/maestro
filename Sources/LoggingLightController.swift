import Foundation

/// `LightController` implementation that prints light commands instead of
/// sending them to Home Assistant. Useful for debugging.
public final class LoggingLightController: LightController {
    public init() {}

    public func setLightState(state: LightState) {
        var message = "[LOG] \(state.entityId) -> \(state.on ? "on" : "off")"
        if let b = state.brightness { message += " brightness:\(b)" }
        if let ct = state.colorTemperature { message += " colorTemp:\(ct)" }
        print(message)
    }
}
