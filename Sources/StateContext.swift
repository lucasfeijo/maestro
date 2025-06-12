import Foundation

/// A context that represents the current state of the home automation system.
///
/// StateContext interprets raw Home Assistant states into a structured representation
/// of the current scene and environment. The context includes:
///
/// - The active scene (off, calm night, normal, etc)
/// - Environmental factors like time of day and presence detection
///
/// This structured representation allows for consistent and centralized handling
/// of light state calculations based on the current conditions.
public struct StateContext {
    public let scene: Scene
    public let environment: Environment
    public let states: HomeAssistantStateMap

    public init(states: HomeAssistantStateMap) {
        let sceneStr = (states["input_select.living_scene"]?["state"] as? String) ?? "off"
        let scene: Scene
        switch sceneStr {
        case "calm night": scene = .calmNight
        case "normal": scene = .normal
        case "bright": scene = .bright
        case "brightest": scene = .brightest
        case "preset": scene = .preset
        default: scene = .off
        }

        let sunState = states["sun.sun"]?["state"] as? String ?? "below_horizon"
        let timeOfDay: TimeOfDay = sunState == "above_horizon" ? .daytime : .nighttime
        let hyperionRunning = states["binary_sensor.living_tv_hyperion_running_condition_for_the_scene"]?["state"] as? String == "on"
        let diningPresence = states["binary_sensor.dining_espresence"]?["state"] as? String == "on"
        let kitchenPresence = states["binary_sensor.kitchen_espresence"]?["state"] as? String == "on"
        let kitchenExtraBrightness = states["input_boolean.kitchen_extra_brightness"]?["state"] as? String == "on"
        let env = Environment(timeOfDay: timeOfDay,
                            hyperionRunning: hyperionRunning,
                            diningPresence: diningPresence,
                            kitchenPresence: kitchenPresence,
                            kitchenExtraBrightness: kitchenExtraBrightness)

        self.scene = scene
        self.environment = env
        self.states = states
    }

    /// Computes the desired light changes for a scene in a given environment.
    public func computeDesiredStates() -> LightStateDiff {
        var changes: [LightState] = []

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

        return LightStateDiff(changes: changes, currentStates: states)
    }
}

