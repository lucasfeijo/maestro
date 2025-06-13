// LIGHTS:
public protocol LightController {
    func setLightState(state: LightState)
    func stopAllDynamicScenes()
}