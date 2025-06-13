import Foundation

let options = parseArguments(CommandLine.arguments)
let states = HomeAssistantStateProvider(baseURL: options.baseURL, token: options.token)
let lights: LightController = options.simulate ? LoggingLightController() : HomeAssistantLightController(baseURL: options.baseURL, token: options.token)
let program: LightProgram
switch options.programName.lowercased() {
case LightProgramSecondary().name:
    program = LightProgramSecondary()
default:
    program = LightProgramDefault()
}
let maestro = Maestro(states: states, lights: lights, program: program)
try startServer(on: 8080, maestro: maestro)
