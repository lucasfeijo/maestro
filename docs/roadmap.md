# Maestro Feature Roadmap

The original Home Assistant Python automation includes a variety of capabilities that are not yet represented in the Swift implementation. The items below describe functionality still missing from **maestro** that could be implemented in future versions.

## Missing Functional Areas

- **Light colors and effects**
  - The Python script sets `rgb_color`, `rgbw_color` and `effect` values for many lights. `LightState` currently only models brightness and color temperature【F:Sources/Lights/LightState.swift†L1-L12】.
  - The changeset logic also only compares brightness when deciding whether to send an update【F:Sources/Lights/LightStateChangeset.swift†L15-L37】.

- **Transition support**
  - Several actions in the script specify transition times (e.g. 2 second fades). `LightState` and the light controller do not handle transition durations at the moment.

- **Advanced time‑of‑day handling**
  - The Python automation derives `daytime`, `pre_sunset`, `sunset` and `nighttime` using the sun's next setting time. `StateContext` currently collapses this into just `daytime` or `nighttime` based on `sun.sun` state【F:Sources/Context/StateContext.swift†L31-L33】, leaving the additional cases unused.

- **Per‑shelf TV light control**
  - The script checks each `input_boolean.wled_tv_shelf_n` to decide whether individual shelf segments should be on or off. Maestro currently treats `light.tv_shelf_group` as a single entity without per‑shelf adjustments.

- **Nested group updates**
  - Functions like `process_light_group` and `update_specific_light` recursively apply updates to groups of lights. The current Swift code operates on explicit entity lists only.

- **Preset/dynamic scenes**
  - When the `preset` scene is selected the Python version interacts with `scene_presets` and stops dynamic scenes. Maestro's `LightProgramDefault` leaves the `preset` case empty【F:Sources/Programs/LightProgramDefault.swift†L97-L101】.

- **Presence‑based behavior for the kitchen sink**
  - The script adjusts brightness and RGBW color of the kitchen sink lights based on both `kitchen_espresence` and `kitchen_presence_occupancy` sensors and resets the `kitchen_extra_brightness` helper when nobody is present. Maestro only monitors one presence sensor and does not change the helper state.

- **Auto mode toggle**
  - The Python automation honors `input_boolean.living_scene_auto` to freeze all changes when auto=off. This toggle is not considered by the Swift program.

- **Error reporting and detailed logging**
  - The existing script records skipped updates and sends persistent notifications on errors. Maestro currently just prints failures without structured logging or Home Assistant notifications.
  - We would need another protocol like NotificationPusher that sends a request to the server to push a notification.
  - There should also be a way to disable these notifications via cmd line args.

## Suggested Next Steps

1. Extend `LightState` to include color, effect and transition fields, updating `LightController` implementations accordingly.
2. Implement more granular time‑of‑day detection within `StateContext`.
3. Add logic for per‑shelf control of `light.tv_shelf_group` using the shelf input booleans.
4. Introduce support for nested groups and helper functions similar to `process_light_group`.
5. Flesh out the `preset` scene handling and dynamic scene interactions.
6. Expand presence handling and automation toggles to match the Python behavior.
7. Provide better error reporting and logging, optionally via Home Assistant persistent notifications.

