import Foundation

/// `LightController` implementation that prints light commands instead of
/// sending them to Home Assistant. Useful for debugging.
public final class LoggingLightController: LightController {
    public init() {}

    public func setLightState(entityId: String, on: Bool, brightness: Int?, colorTemperature: Int?) {
        let state = on ? "on" : "off"
        var message = "[LOG] \(entityId) -> \(state)"
        if let b = brightness { message += " brightness:\(b)" }
        if let ct = colorTemperature { message += " colorTemp:\(ct)" }
        print(message)
    }
}
