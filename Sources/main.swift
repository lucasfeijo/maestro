import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Minimal HTTP server handling GET requests from Home Assistant.
func startServer(on port: Int32, maestro: Maestro) throws {
#if os(Linux)
    let serverFD = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
#else
    let serverFD = socket(AF_INET, SOCK_STREAM, 0)
#endif
    guard serverFD >= 0 else { fatalError("Unable to create socket") }

    var value: Int32 = 1
    setsockopt(serverFD, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size))

    var addr = sockaddr_in()
    addr.sin_family = sa_family_t(AF_INET)
    addr.sin_port = in_port_t(port).bigEndian
    addr.sin_addr = in_addr(s_addr: INADDR_ANY.bigEndian)

    var bindAddr = sockaddr()
    memcpy(&bindAddr, &addr, MemoryLayout<sockaddr_in>.size)
    guard bind(serverFD, &bindAddr, socklen_t(MemoryLayout<sockaddr_in>.size)) >= 0 else {
        fatalError("bind failed")
    }
    listen(serverFD, 10)
    print("Server listening on port \(port)")

    while true {
        var clientAddr = sockaddr()
        var len: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)
        let clientFD = accept(serverFD, &clientAddr, &len)
        if clientFD < 0 { continue }

        var buffer = [UInt8](repeating: 0, count: 1024)
        let count = read(clientFD, &buffer, 1024)

        var statusLine = "HTTP/1.1 200 OK"
        var body = "OK"

        if count > 0 {
            let request = String(decoding: buffer[0..<count], as: UTF8.self)
            if request.hasPrefix("GET ") {
                if let firstLine = request.components(separatedBy: "\r\n").first,
                   let range = firstLine.range(of: " ") {
                    let start = firstLine.index(after: range.lowerBound)
                    let end = firstLine.range(of: " ", range: start..<firstLine.endIndex)?.lowerBound ?? firstLine.endIndex
                    let path = firstLine[start..<end]
                    if path == "/run" {
                        maestro.run()
                    } else {
                        statusLine = "HTTP/1.1 404 Not Found"
                        body = "Not Found"
                    }
                }
            }
        }

        let response = "\(statusLine)\r\nContent-Length: \(body.utf8.count)\r\n\r\n\(body)"
        _ = response.withCString { send(clientFD, $0, strlen($0), 0) }
        close(clientFD)
    }
}


var baseURL = URL(string: "http://homeassistant.local:8123/")!
var token: String? = nil
var simulate = false
var programName = "default"
var idx = 1
let args = CommandLine.arguments
while idx < args.count {
    let arg = args[idx]
    if arg.hasPrefix("--baseurl=") {
        let value = String(arg.dropFirst("--baseurl=".count))
        if let url = URL(string: value) { baseURL = url }
    } else if arg == "--baseurl", idx + 1 < args.count {
        idx += 1
        if let url = URL(string: args[idx]) { baseURL = url }
    } else if arg.hasPrefix("--token=") {
        token = String(arg.dropFirst("--token=".count))
    } else if arg == "--token", idx + 1 < args.count {
        idx += 1
        token = args[idx]
    } else if arg == "--simulate" {
        simulate = true
    } else if arg.hasPrefix("--program=") {
        programName = String(arg.dropFirst("--program=".count))
    } else if arg == "--program", idx + 1 < args.count {
        idx += 1
        programName = args[idx]
    }
    idx += 1
}

let api = HTTPHomeAssistantClient(baseURL: baseURL, token: token)
let lights: LightController = simulate ? LoggingLightController() : api
let program: LightProgram
switch programName.lowercased() {
case LightProgramSecondary().name:
    program = LightProgramSecondary()
default:
    program = LightProgramDefault()
}
let maestro = Maestro(api: api, lights: lights, differ: program)
try startServer(on: 8080, maestro: maestro)
