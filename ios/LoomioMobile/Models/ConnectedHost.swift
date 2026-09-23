import Foundation

struct ConnectedHost: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let origin: URL

    init(id: UUID = UUID(), origin: URL) throws {
        self.id = id
        self.origin = try HostOriginValidator.canonicalOrigin(from: origin)
    }

    init(id: UUID = UUID(), input: String) throws {
        guard let url = URL(string: input.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw HostOriginError.invalidURL
        }
        try self.init(id: id, origin: url)
    }

    var displayName: String { origin.host() ?? origin.absoluteString }
}

enum HostOriginError: LocalizedError, Equatable {
    case invalidURL
    case httpsRequired
    case credentialsNotAllowed
    case originOnly

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Enter a valid Loomio host, such as https://example.org."
        case .httpsRequired: "Loomio hosts must use HTTPS."
        case .credentialsNotAllowed: "The host address cannot contain a username or password."
        case .originOnly: "Enter only the host origin, without a path, query, or fragment."
        }
    }
}

enum HostOriginValidator {
    static func canonicalOrigin(from url: URL) throws -> URL {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host, !host.isEmpty else {
            throw HostOriginError.invalidURL
        }
        guard permitsTransport(scheme: components.scheme, host: host, port: components.port) else {
            throw HostOriginError.httpsRequired
        }
        guard components.user == nil, components.password == nil else {
            throw HostOriginError.credentialsNotAllowed
        }
        guard components.path.isEmpty || components.path == "/",
              components.query == nil,
              components.fragment == nil else {
            throw HostOriginError.originOnly
        }

        var origin = URLComponents()
        origin.scheme = components.scheme?.lowercased()
        origin.host = host.lowercased()
        origin.port = components.port
        guard let result = origin.url else { throw HostOriginError.invalidURL }
        return result
    }

    // Local HTTP is confined to a Debug build and the fixed Vite development origin.
    static func permitsTransport(scheme: String?, host: String, port: Int?) -> Bool {
        if scheme?.lowercased() == "https" { return true }
#if DEBUG
        return scheme?.lowercased() == "http"
            && host.lowercased() == "localhost"
            && port == 8080
#else
        return false
#endif
    }
}
