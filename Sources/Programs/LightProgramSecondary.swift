import Foundation

public struct LightProgramSecondary: LightProgram {
    public let name = "secondary"
    public init() {}

    public func computeStateSet(context: StateContext) -> LightStateChangeset {
        let change = LightState(entityId: "light.secondary", on: true, brightness: 1)
        let states = context.states
        let scaleStr = states["input_number.living_scene_brightness_percentage"]?["state"] as? String ?? "100"
        let scalePct = Double(scaleStr) ?? 100
        let scale = max(0.0, min(scalePct, 100.0)) / 100.0
        let scaled = Int(round(Double(change.brightness ?? 0) * scale))
        let clamped = max(1, min(100, scaled))
        let scaledChange = LightState(entityId: change.entityId, on: change.on, brightness: clamped)
        return LightStateChangeset(currentStates: states,
                                   desiredStates: [scaledChange])
    }
}
