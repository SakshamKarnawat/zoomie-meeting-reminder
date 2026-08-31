import Foundation
import Network

final class GoogleLoopbackServer: @unchecked Sendable {
    private var listener: NWListener?
    private var continuation: CheckedContinuation<URL, Error>?
    private let lock = NSLock()

    func start() async throws -> UInt16 {
        let parameters = NWParameters.tcp
        parameters.requiredInterfaceType = .loopback
        let listener = try NWListener(using: parameters, on: 0)
        self.listener = listener
        listener.newConnectionHandler = { [weak self] connection in
            self?.accept(connection)
        }
        return try await withCheckedThrowingContinuation { continuation in
            let gate = ResumeGate()
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    guard let port = listener.port?.rawValue else { return }
                    gate.resume {
                        continuation.resume(returning: port)
                    }
                case .failed(let error):
                    gate.resume {
                        continuation.resume(throwing: error)
                    }
                default:
                    break
                }
            }
            listener.start(queue: .global(qos: .userInitiated))
        }
    }

    func waitForRedirect() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            self.continuation = continuation
            lock.unlock()
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil
        finish(throwing: GoogleOAuthError.cancelled)
    }

    private func accept(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .userInitiated))
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] data, _, _, error in
            if let error {
                connection.cancel()
                self?.finish(throwing: error)
                return
            }
            guard let data, let request = String(data: data, encoding: .utf8) else {
                connection.cancel()
                self?.finish(throwing: GoogleOAuthError.missingCode)
                return
            }
            let parsed = Self.redirectURL(from: request)
            guard let parsed, Self.isOAuthCallback(parsed) else {
                self?.reply(on: connection) {
                    connection.cancel()
                }
                return
            }
            self?.reply(on: connection) {
                connection.cancel()
                self?.finish(returning: parsed)
            }
        }
    }

    private func reply(on connection: NWConnection, done: @escaping () -> Void) {
        let body = """
        <!doctype html><html><body style="font-family:system-ui;padding:2rem">
        <p>Zoomie is signed in with Google. You can close this window.</p>
        </body></html>
        """
        let response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(body.utf8.count)\r\nConnection: close\r\n\r\n\(body)"
        connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in
            done()
        })
    }

    private func finish(returning url: URL) {
        lock.lock()
        let pending = continuation
        continuation = nil
        lock.unlock()
        pending?.resume(returning: url)
    }

    private func finish(throwing error: Error) {
        lock.lock()
        let pending = continuation
        continuation = nil
        lock.unlock()
        pending?.resume(throwing: error)
    }

    static func redirectURL(from request: String) -> URL? {
        let firstLine = request.split(separator: "\r\n", maxSplits: 1).first ?? ""
        let parts = firstLine.split(separator: " ")
        guard parts.count >= 2 else { return nil }
        let path = String(parts[1])
        return URL(string: "http://127.0.0.1\(path)")
    }

    static func isOAuthCallback(_ url: URL) -> Bool {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return items.contains { $0.name == "code" || $0.name == "error" }
    }
}
