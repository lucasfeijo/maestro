import Foundation

/// Represents the data extracted from Home Assistant states needed to compute light changes.
public struct StateContext {
    public let scene: Scene
    public let environment: Environment
    public let states: [String: [String: Any]]

    public init(scene: Scene, environment: Environment, states: [String: [String: Any]]) {
        self.scene = scene
        self.environment = environment
        self.states = states
    }
}

/// Converts raw Home Assistant state objects into a `StateContext` used by `Maestro`.
public func makeStateContext(from states: [[String: Any]]) -> StateContext {
    var map: [String: [String: Any]] = [:]
    for s in states {
        if let id = s["entity_id"] as? String {
            map[id] = s
        }
    }

    let sceneStr = (map["input_select.living_scene"]?["state"] as? String) ?? "off"
    let scene: Scene
    switch sceneStr {
    case "calm night": scene = .calmNight
    case "normal": scene = .normal
    case "bright": scene = .bright
    case "brightest": scene = .brightest
    case "preset": scene = .preset
    default: scene = .off
    }

    let sunState = map["sun.sun"]?["state"] as? String ?? "below_horizon"
    let timeOfDay: TimeOfDay = sunState == "above_horizon" ? .daytime : .nighttime
    let hyperionRunning = map["binary_sensor.living_tv_hyperion_running_condition_for_the_scene"]?["state"] as? String == "on"
    let diningPresence = map["binary_sensor.dining_espresence"]?["state"] as? String == "on"
    let kitchenPresence = map["binary_sensor.kitchen_espresence"]?["state"] as? String == "on"
    let kitchenExtraBrightness = map["input_boolean.kitchen_extra_brightness"]?["state"] as? String == "on"
    let env = Environment(timeOfDay: timeOfDay,
                          hyperionRunning: hyperionRunning,
                          diningPresence: diningPresence,
                          kitchenPresence: kitchenPresence,
                          kitchenExtraBrightness: kitchenExtraBrightness)

    return StateContext(scene: scene, environment: env, states: map)
}
