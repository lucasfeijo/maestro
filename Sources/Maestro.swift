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

private extension Array where Element == LightStateChange {
    mutating func on(_ entityId: String, brightness: Int? = nil, colorTemperature: Int? = nil) {
        append(LightStateChange(entityId: entityId, on: true, brightness: brightness, colorTemperature: colorTemperature))
    }

    mutating func on(_ entityIds: [String], brightness: Int? = nil, colorTemperature: Int? = nil) {
        for id in entityIds { on(id, brightness: brightness, colorTemperature: colorTemperature) }
    }

    mutating func off(_ entityId: String) {
        append(LightStateChange(entityId: entityId, on: false))
    }

    mutating func off(_ entityIds: [String]) {
        for id in entityIds { off(id) }
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

/// Encapsulates logic to translate Home Assistant events into light states.
public final class Maestro {
    private let api: HomeAssistantAPI
    private let clock: () -> Date

    public init(api: HomeAssistantAPI, clock: @escaping () -> Date = Date.init) {
        self.api = api
        self.clock = clock
    }

    /// Handles a change for a given entity and returns the light changes.
    @discardableResult
    public func handleStateChange(entityId: String, newState: String) -> [LightStateChange] {
        // Example logic: if a motion sensor turns "on" in the evening, turn on the living room light.
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let hour = Int(formatter.string(from: clock())) ?? 12
        var changes: [LightStateChange] = []

        if entityId == "sensor.motion" && newState == "on" && hour >= 18 {
            changes.on("light.living_room")
        }

        for change in changes {
            api.setLightState(entityId: change.entityId, on: change.on, brightness: change.brightness, colorTemperature: change.colorTemperature)
        }
        return changes
    }

    /// Generates light changes for a given scene and environment.
    public func applyScene(_ scene: Scene, environment: Environment) -> [LightStateChange] {
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
            api.setLightState(entityId: change.entityId, on: change.on, brightness: change.brightness, colorTemperature: change.colorTemperature)
        }
        return changes
    }
}
