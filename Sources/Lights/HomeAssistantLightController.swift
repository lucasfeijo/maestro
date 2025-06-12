import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Sends commands to change light states.
public protocol LightController {
    func setLightState(state: LightState)
}

/// HTTP-based implementation that communicates with Home Assistant.
public final class HomeAssistantLightController: LightController {
    private let baseURL: URL
    private let token: String?
    private let session: URLSession

    public init(baseURL: URL, token: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    public func setLightState(state: LightState) {
        let url = baseURL.appendingPathComponent("api/services/light/turn_\(state.on ? "on" : "off")")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        var body: [String: Any] = ["entity_id": state.entityId]
        if let b = state.brightness { body["brightness_pct"] = b }
        if let ct = state.colorTemperature { body["color_temp"] = ct }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request) { _, _, _ in
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 5)
    }
}
