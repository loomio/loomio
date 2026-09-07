import Foundation

struct ConnectionProposal: Identifiable, Equatable, Sendable {
    let configURL: URL
    var id: String { configURL.absoluteString }
    var origin: URL {
        var components = URLComponents()
        components.scheme = configURL.scheme
        components.host = configURL.host()
        components.port = configURL.port
        return components.url!
    }
}

enum ConnectionLinkError: LocalizedError, Equatable {
    case invalidLink
    case invalidConfigURL

    var errorDescription: String? {
        switch self {
        case .invalidLink: "This Loomio connection link is invalid."
        case .invalidConfigURL: "The connection link does not contain a valid Loomio configuration URL."
        }
    }
}

enum ConnectionLinkParser {
    static let configPath = "/api/v1/mobile/config"
    private static let maximumLinkLength = 2_048

    static func parse(_ url: URL) throws -> ConnectionProposal {
        guard url.absoluteString.utf8.count <= maximumLinkLength,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "loomio",
              components.host?.lowercased() == "connect",
              components.path.isEmpty,
              components.fragment == nil,
              components.queryItems?.count == 1,
              components.queryItems?.first?.name == "config",
              let value = components.queryItems?.first?.value,
              value.utf8.count <= maximumLinkLength,
              let configURL = URL(string: value) else {
            throw ConnectionLinkError.invalidLink
        }

        try validateConfigURL(configURL)
        return ConnectionProposal(configURL: configURL)
    }

    static func proposal(forHostInput input: String) throws -> ConnectionProposal {
        let host = try ConnectedHost(input: input)
        return ConnectionProposal(configURL: host.origin.appending(path: "api/v1/mobile/config"))
    }

    static func validateConfigURL(_ url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host, !host.isEmpty,
              HostOriginValidator.permitsTransport(
                  scheme: components.scheme,
                  host: host,
                  port: components.port
              ),
              components.user == nil,
              components.password == nil,
              components.path == configPath,
              components.query == nil,
              components.fragment == nil else {
            throw ConnectionLinkError.invalidConfigURL
        }
    }
}

struct MobileHostConfiguration: Decodable, Equatable, Sendable {
    let protocolVersion: Int
    let issuer: URL
    let authorizationEndpoint: URL
    let tokenEndpoint: URL
    let webSessionTicketEndpoint: URL
    let webSessionBootstrapEndpoint: URL
    let relayAuthorizationEndpoint: URL
    let pushRegistrationEndpoint: URL
    let activityEndpoint: URL
    let deviceEndpoint: URL

    enum CodingKeys: String, CodingKey {
        case protocolVersion = "protocol_version"
        case issuer
        case authorizationEndpoint = "authorization_endpoint"
        case tokenEndpoint = "token_endpoint"
        case webSessionTicketEndpoint = "web_session_ticket_endpoint"
        case webSessionBootstrapEndpoint = "web_session_bootstrap_endpoint"
        case relayAuthorizationEndpoint = "relay_authorization_endpoint"
        case pushRegistrationEndpoint = "push_registration_endpoint"
        case activityEndpoint = "activity_endpoint"
        case deviceEndpoint = "device_endpoint"
    }

    func validate(for proposal: ConnectionProposal) throws {
        guard protocolVersion == 1 else { throw MobileAuthenticationError.unsupportedProtocol }
        let expectedOrigin = proposal.origin
        let endpoints = [
            issuer,
            authorizationEndpoint,
            tokenEndpoint,
            webSessionTicketEndpoint,
            webSessionBootstrapEndpoint,
            relayAuthorizationEndpoint,
            pushRegistrationEndpoint,
            activityEndpoint,
            deviceEndpoint
        ]
        guard endpoints.allSatisfy({ endpoint in
            endpoint.matchesOrigin(expectedOrigin)
                && endpoint.user == nil
                && endpoint.password == nil
                && endpoint.query == nil
                && endpoint.fragment == nil
        }), issuer.path.isEmpty || issuer.path == "/" else {
            throw MobileAuthenticationError.crossOriginConfiguration
        }
    }
}

struct ActivityPage: Decodable, Sendable {
    let activity: [ActivityItem]
    let nextBeforeID: Int?

    enum CodingKeys: String, CodingKey {
        case activity
        case nextBeforeID = "next_before_id"
    }
}

struct ActivityItem: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let kind: String
    let title: String?
    let name: String?
    let actorName: String?
    let url: String
    let createdAt: Date
    var viewed: Bool

    enum CodingKeys: String, CodingKey {
        case id, kind, title, name, url, viewed
        case actorName = "actor_name"
        case createdAt = "created_at"
    }

    var displayTitle: String {
        title?.nonEmpty ?? name?.nonEmpty ?? kind.replacingOccurrences(of: "_", with: " ").capitalized
    }

    func destination(on host: ConnectedHost) -> URL? {
        guard url.hasPrefix("/"), !url.hasPrefix("//"),
              let destination = URL(string: url, relativeTo: host.origin)?.absoluteURL,
              destination.matchesOrigin(host.origin) else { return nil }
        return destination
    }
}

private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}

struct MobileTokenResponse: Decodable, Sendable {
    struct Device: Decodable, Sendable {
        let id: UUID
        let name: String
    }

    let tokenType: String
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String
    let refreshTokenExpiresIn: Int
    let device: Device
    let scope: String

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case refreshTokenExpiresIn = "refresh_token_expires_in"
        case device, scope
    }
}

struct WebSessionTicketResponse: Decodable, Sendable {
    let ticket: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case ticket
        case expiresIn = "expires_in"
    }
}

struct WebSessionBootstrap: Equatable, Sendable {
    let endpoint: URL
    let ticket: String
}

struct AuthenticatedConnection: Sendable {
    let host: ConnectedHost
    let token: MobileTokenResponse
    let bootstrap: WebSessionBootstrap
    let configuration: MobileHostConfiguration
}

struct RelayAuthorizationResponse: Decodable, Sendable {
    let authorization: String
    let expiresIn: Int
    let relayRegistrationEndpoint: URL

    enum CodingKeys: String, CodingKey {
        case authorization
        case expiresIn = "expires_in"
        case relayRegistrationEndpoint = "relay_registration_endpoint"
    }
}

struct RelayRegistrationResponse: Decodable, Sendable {
    let registrationID: UUID

    enum CodingKeys: String, CodingKey {
        case registrationID = "registration_id"
    }
}

enum MobileAuthenticationError: LocalizedError, Equatable {
    case unsupportedHost
    case invalidResponse
    case unsupportedProtocol
    case crossOriginConfiguration
    case invalidCallback
    case stateMismatch
    case authenticationCancelled
    case server(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedHost: "This Loomio host does not support the mobile app."
        case .invalidResponse: "The Loomio host returned an invalid mobile authentication response."
        case .unsupportedProtocol: "This Loomio host uses an unsupported mobile protocol version."
        case .crossOriginConfiguration: "The Loomio host advertised an unsafe authentication endpoint."
        case .invalidCallback: "The authentication callback was invalid."
        case .stateMismatch: "The authentication response did not match this sign-in attempt."
        case .authenticationCancelled: "Sign-in was cancelled."
        case .server(let message): message
        }
    }
}
