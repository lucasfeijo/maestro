import Foundation

let options = parseArguments(CommandLine.arguments)
let notificationPusher: NotificationPusher? = options.notificationsEnabled ?
    HomeAssistantNotificationPusher(baseURL: options.baseURL, token: options.token) : nil
let logger = Logger(pusher: notificationPusher)

let states = HomeAssistantStateProvider(baseURL: options.baseURL, token: options.token)
let lights: LightController = options.simulate ?
    LoggingLightController() :
    HomeAssistantLightController(baseURL: options.baseURL,
                                token: options.token,
                                logger: logger)
let program: LightProgram
switch options.programName.lowercased() {
case LightProgramSecondary().name:
    program = LightProgramSecondary()
default:
    program = LightProgramDefault()
}
let maestro = Maestro(states: states, lights: lights, program: program, logger: logger)
try startServer(on: options.port, maestro: maestro)
