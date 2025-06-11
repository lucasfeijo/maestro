import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol HomeAssistantAPI {
    func fetchState(entityId: String) -> String?
    func fetchAllStates() -> [[String: Any]]?
}

/// Sends commands to change light states.
public protocol LightController {
    func setLightState(entityId: String, on: Bool, brightness: Int?, colorTemperature: Int?)
}

/// Simple HTTP based implementation used by the server. It expects Home Assistant
/// to expose a REST API accessible at `baseURL`.
public final class HTTPHomeAssistantClient: HomeAssistantAPI, LightController {
    private let baseURL: URL
    private let session: URLSession
    private let token: String?

    public init(baseURL: URL, token: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    public func fetchState(entityId: String) -> String? {
        // Build a request to Home Assistant's REST API.
        // The actual network call is synchronous for simplicity.
        let url = baseURL.appendingPathComponent("api/states/\(entityId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let semaphore = DispatchSemaphore(value: 0)
        final class Box: @unchecked Sendable { var value: String? = nil }
        let box = Box()
        let task = session.dataTask(with: request) { data, _, _ in
            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let state = json["state"] as? String {
                box.value = state
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 5)
        return box.value
    }

    public func fetchAllStates() -> [[String: Any]]? {
        let url = baseURL.appendingPathComponent("api/states")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let semaphore = DispatchSemaphore(value: 0)
        final class Box: @unchecked Sendable { var value: [[String: Any]]? = nil }
        let box = Box()
        let task = session.dataTask(with: request) { data, _, _ in
            if let data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                box.value = json
            }
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 10)
        return box.value
    }

    public func setLightState(entityId: String, on: Bool, brightness: Int?, colorTemperature: Int?) {
        let url = baseURL.appendingPathComponent("api/services/light/turn_\(on ? "on" : "off")")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        var body: [String: Any] = ["entity_id": entityId]
        if let b = brightness { body["brightness_pct"] = b }
        if let ct = colorTemperature { body["color_temp"] = ct }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request) { _, _, _ in
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 5)
    }
}
