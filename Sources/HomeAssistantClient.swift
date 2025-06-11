import Foundation
import FoundationNetworking

public protocol HomeAssistantAPI {
    func fetchState(entityId: String) -> String?
    func setLightState(entityId: String, on: Bool)
}

/// Simple HTTP based implementation used by the server. It expects Home Assistant
/// to expose a REST API accessible at `baseURL`.
public final class HTTPHomeAssistantClient: HomeAssistantAPI {
    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func fetchState(entityId: String) -> String? {
        // Build a request to Home Assistant's REST API.
        // The actual network call is synchronous for simplicity.
        let url = baseURL.appendingPathComponent("api/states/\(entityId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

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

    public func setLightState(entityId: String, on: Bool) {
        let url = baseURL.appendingPathComponent("api/services/light/turn_\(on ? "on" : "off")")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["entity_id": entityId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let semaphore = DispatchSemaphore(value: 0)
        let task = session.dataTask(with: request) { _, _, _ in
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 5)
    }
}
