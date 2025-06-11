import Foundation


/// Encapsulates logic to translate Home Assistant events into light states.
public final class Maestro {
    private let api: HomeAssistantAPI
    private let clock: () -> Date

    public init(api: HomeAssistantAPI, clock: @escaping () -> Date = Date.init) {
        self.api = api
        self.clock = clock
    }

    /// Applies the current scene based on raw Home Assistant state objects.
    public func applyStates(_ states: [[String: Any]]) -> [LightStateChange] {
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
        let env = Environment(timeOfDay: timeOfDay, hyperionRunning: hyperionRunning, diningPresence: diningPresence, kitchenPresence: kitchenPresence, kitchenExtraBrightness: kitchenExtraBrightness)

        return applyScene(scene, environment: env, currentStates: map)
    }

    /// Fetches state from Home Assistant and applies the current scene.
    public func run() {
        guard let states = api.fetchAllStates() else { return }
        _ = applyStates(states)
    }

    /// Generates light changes for a given scene and environment.
    public func applyScene(_ scene: Scene, environment: Environment, currentStates: [String: [String: Any]] = [:]) -> [LightStateChange] {
        var changes: [LightStateChange] = []

        switch scene {
        case .off:
            changes.off(["light.living_temperature_lights", "light.color_lights", "light.window_led_strip", "light.kitchen_led"])

        case .calmNight:
            if environment.timeOfDay == .daytime || environment.timeOfDay == .preSunset {
                changes.on("light.kitchen_led", brightness: 50)
                changes.on("light.tripod_lamp", brightness: 10, colorTemperature: 200)
            } else {
                if !environment.hyperionRunning {
                    changes.on("light.tv_shelf_group", brightness: 2)
                } else {
                    changes.off("light.tv_shelf_group")
                }
                changes.on("light.window_led_strip", brightness: 17)
                changes.on(["light.entrance_dining_light", "light.living_entry_door_light", "light.living_fireplace_spot"], brightness: 10)
                changes.on("light.desk_light", brightness: 5)
                changes.off(["light.shoes_light", "light.tv_light", "light.chaise_light", "light.corredor_door_light"])
                changes.on("light.tripod_lamp", brightness: 10)
                changes.on("light.zigbee_hub_estante_lights", brightness: 8)
                changes.on("light.living_art_wall_light", brightness: 10)
                changes.on("light.kitchen_led", brightness: 50)
                if environment.diningPresence {
                    changes.on("light.dining_table_light", brightness: 30)
                } else {
                    changes.on("light.dining_table_light", brightness: 10)
                }
            }

        case .normal:
            if environment.timeOfDay == .daytime || environment.timeOfDay == .preSunset {
                if !environment.hyperionRunning {
                    changes.on("light.tv_light", brightness: 50)
                    changes.on("light.wled_tv_shelf_4", brightness: 20)
                } else {
                    changes.off(["light.tv_light", "light.tv_shelf_group"])
                }
                changes.on("light.dining_table_light", brightness: 100)
                changes.off("light.corner_light")
                changes.on("light.desk_light", brightness: 40)
                changes.on(["light.corredor_door_light", "light.entrance_dining_light", "light.living_entry_door_light"], brightness: 60)
                changes.on("light.shoes_light", brightness: 50)
                changes.off(["light.chaise_light", "light.window_led_strip"])
                changes.on("light.living_art_wall_light", brightness: 60)
                changes.on("light.tripod_lamp", brightness: 49)
                changes.off("light.living_fireplace_spot")
                changes.on("light.zigbee_hub_estante_lights", brightness: 55)
                changes.on("light.kitchen_led", brightness: 50)
            } else {
                if !environment.hyperionRunning {
                    changes.on("light.tv_light", brightness: 51)
                    changes.on("light.tv_shelf_group", brightness: 20)
                } else {
                    changes.off("light.tv_light")
                }
                changes.on("light.color_lights_without_tv_light", brightness: 51)
                changes.on("light.corner_light", brightness: 30)
                changes.on("light.window_led_strip", brightness: 40)
                changes.on(["light.living_fireplace_spot", "light.living_entry_door_light", "light.shoes_light", "light.entrance_dining_light", "light.corredor_door_light"], brightness: 20)
                changes.off("light.chaise_light")
                changes.on("light.kitchen_led", brightness: 26)
            }

        case .bright:
            if !environment.hyperionRunning {
                changes.on("light.tv_light", brightness: 75)
                changes.on("light.tv_shelf_group", brightness: 100)
            } else {
                changes.off(["light.tv_light", "light.tv_shelf_group"])
            }
            changes.on("light.living_temperature_lights", brightness: 60)
            changes.on("light.color_lights_without_tv_light", brightness: 75)
            changes.on("light.window_led_strip", brightness: 100)
            changes.on("light.zigbee_hub_estante_lights", brightness: 75)
            changes.on("light.kitchen_led", brightness: 100)

        case .brightest:
            if !environment.hyperionRunning {
                changes.on("light.tv_light", brightness: 100)
                changes.on("light.tv_shelf_group", brightness: 100)
            } else {
                changes.off(["light.tv_light", "light.tv_shelf_group"])
            }
            changes.on(["light.living_temperature_lights", "light.color_lights_without_tv_light", "light.window_led_strip", "light.zigbee_hub_estante_lights", "light.kitchen_led"], brightness: 100)

        case .preset:
            break
        }

        // Kitchen sink presence behavior
        let kitchenOnBrightness: Int
        if environment.kitchenPresence {
            if (scene == .calmNight || scene == .normal || scene == .off) && !environment.kitchenExtraBrightness {
                kitchenOnBrightness = 60
            } else {
                kitchenOnBrightness = 100
            }
            changes.on("light.kitchen_sink_light", brightness: kitchenOnBrightness)
            changes.on("light.kitchen_sink_light_old", brightness: 20)
        } else if scene != .off {
            changes.on("light.kitchen_sink_light", brightness: 10)
            changes.on("light.kitchen_sink_light_old", brightness: 10)
        }

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
            api.setLightState(entityId: change.entityId, on: change.on, brightness: change.brightness, colorTemperature: change.colorTemperature)
        }
        return changes
    }
}
