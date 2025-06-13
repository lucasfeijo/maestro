# Maestro Feature Roadmap

The original Home Assistant Python automation includes a variety of capabilities that are not yet represented in the Swift implementation. Below is a prioritized list of features to implement in future versions.

## Quick Wins (Low Complexity)

### 1. Auto Mode Toggle *(implemented)*
- Add support for `input_boolean.living_scene_auto` to freeze all changes when auto=off
- Simple boolean check added to the program flow
- No complex state management required

### 2. Error Reporting and Logging
- Implement structured logging for failures
- Add support for Home Assistant persistent notifications
- Create a `NotificationPusher` protocol for sending notifications to hass
- Add command-line option to disable notifications

## Medium Complexity

### 3. Transition Support
- Add transition duration field to `LightState`
- Update `LightController` implementations to handle transitions
- Implement 2-second fade support for relevant actions

### 4. Advanced Time-of-Day Handling
- Extend `StateContext` to support additional states:
  - `daytime`
  - `pre_sunset`
  - `sunset`
  - `nighttime`
- Implement sun-based time detection logic

### 5. Per-Shelf TV Light Control
- Add support for individual shelf control via `input_boolean.wled_tv_shelf_n`
- Update `light.tv_shelf_group` handling to support per-shelf adjustments
- Implement shelf-specific state management

## High Complexity

### 6. Light Colors and Effects
- Extend `LightState` to support:
  - `rgb_color`
  - `rgbw_color`
  - `effect` values
- Update `LightStateChangeset` to compare color and effect values
- Modify light controller implementations accordingly

### 7. Nested Group Updates
- Implement recursive group handling similar to `process_light_group`
- Add support for `update_specific_light` functionality
- Create helper functions for group operations

### 8. Preset/Dynamic Scenes
- Implement `preset` scene handling in `LightProgramDefault`
- Add support for `scene_presets` interaction
- Implement dynamic scene stopping logic

### 9. Presence-Based Kitchen Sink Behavior
- Add support for multiple presence sensors:
  - `kitchen_espresence`
  - `kitchen_presence_occupancy`
- Implement brightness and RGBW color adjustments
- Add `kitchen_extra_brightness` helper state management

## Implementation Strategy

1. Start with Quick Wins to build momentum and improve usability
2. Move to Medium Complexity items to enhance core functionality
3. Tackle High Complexity items last, as they require more architectural changes

Each feature should be implemented with:
- Comprehensive testing
- Documentation updates
- Backward compatibility where possible
- Performance considerations

