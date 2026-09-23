import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

@MainActor
final class MobileAuthenticationService: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = MobileAuthenticationService()

    private static let clientID = "org.loomio.mobile.ios"
    private static let callbackScheme = "org.loomio.mobile"
    private static let callbackPath = "/oauth/callback"
    private static let maximumResponseBytes = 65_536

    private var webAuthenticationSession: ASWebAuthenticationSession?

    func connect(using proposal: ConnectionProposal) async throws -> AuthenticatedConnection {
        let configuration = try await fetchConfiguration(for: proposal)
        let verifier = try randomBase64URL(byteCount: 32)
        let state = try randomBase64URL(byteCount: 32)
        let challenge = Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncodedString()
        let callback = try await authorize(
            configuration: configuration,
            challenge: challenge,
            state: state
        )
        let code = try validateCallback(callback, expectedState: state)
        let token = try await exchange(
            code: code,
            verifier: verifier,
            configuration: configuration
        )
        guard token.tokenType.caseInsensitiveCompare("Bearer") == .orderedSame,
              !token.accessToken.isEmpty,
              token.accessToken.utf8.count <= 4_096,
              !token.accessToken.contains(where: { $0.isWhitespace }),
              !token.refreshToken.isEmpty,
              token.refreshToken.utf8.count <= 4_096,
              token.expiresIn > 0,
              token.refreshTokenExpiresIn > 0 else {
            throw MobileAuthenticationError.invalidResponse
        }
        let ticket = try await createWebSessionTicket(
            accessToken: token.accessToken,
            configuration: configuration
        )
        guard !ticket.ticket.isEmpty,
              ticket.ticket.utf8.count <= 4_096,
              !ticket.ticket.contains(where: { $0.isWhitespace }),
              ticket.expiresIn > 0,
              ticket.expiresIn <= 60 else {
            throw MobileAuthenticationError.invalidResponse
        }
        let host = try ConnectedHost(origin: configuration.issuer)
        return AuthenticatedConnection(
            host: host,
            token: token,
            bootstrap: WebSessionBootstrap(
                endpoint: configuration.webSessionBootstrapEndpoint,
                ticket: ticket.ticket
            ),
            configuration: configuration
        )
    }

    func configuration(for host: ConnectedHost) async throws -> MobileHostConfiguration {
        let proposal = ConnectionProposal(configURL: host.origin.appending(path: "api/v1/mobile/config"))
        return try await fetchConfiguration(for: proposal)
    }

    func refresh(host: ConnectedHost, credential: StoredDeviceCredential) async throws -> MobileTokenResponse {
        let tokenEndpoint = host.origin.appending(path: "/api/v1/mobile/token")
        let tokenBody = formEncoded([
            ("grant_type", "refresh_token"),
            ("client_id", Self.clientID),
            ("refresh_token", credential.refreshToken)
        ])
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.httpBody = tokenBody.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        return try await decode(MobileTokenResponse.self, request: request)
    }

    func registerPush(
        apnsToken: String,
        environment: String,
        accessToken: String,
        configuration: MobileHostConfiguration
    ) async throws {
        var authorizationRequest = URLRequest(url: configuration.relayAuthorizationEndpoint)
        authorizationRequest.httpMethod = "POST"
        authorizationRequest.httpBody = Data("{}".utf8)
        authorizationRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        authorizationRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authorizationRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        authorizationRequest.timeoutInterval = 20
        let authorization = try await decode(RelayAuthorizationResponse.self, request: authorizationRequest)
        try validateRelayAuthorization(authorization)

        let body = try JSONSerialization.data(withJSONObject: [
            "host_origin": configuration.issuer.absoluteString,
            "authorization": authorization.authorization,
            "apns_token": apnsToken,
            "environment": environment
        ], options: [.sortedKeys])
        var relayRequest = URLRequest(url: authorization.relayRegistrationEndpoint)
        relayRequest.httpMethod = "POST"
        relayRequest.httpBody = body
        relayRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        relayRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        relayRequest.timeoutInterval = 20
        _ = try await decode(RelayRegistrationResponse.self, request: relayRequest)
    }

    func sendTestPush(accessToken: String, configuration: MobileHostConfiguration) async throws {
        var request = URLRequest(url: configuration.pushRegistrationEndpoint.appending(path: "test"))
        request.httpMethod = "POST"
        request.httpBody = Data("{}".utf8)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        let (data, response) = try await noRedirectSession().data(for: request)
        guard data.count <= Self.maximumResponseBytes,
              let http = response as? HTTPURLResponse,
              http.statusCode == 202 else {
            throw MobileAuthenticationError.invalidResponse
        }
    }

    func activity(
        accessToken: String,
        configuration: MobileHostConfiguration,
        beforeID: Int? = nil
    ) async throws -> ActivityPage {
        guard var components = URLComponents(
            url: configuration.activityEndpoint,
            resolvingAgainstBaseURL: false
        ) else { throw MobileAuthenticationError.invalidResponse }
        if let beforeID {
            components.queryItems = [URLQueryItem(name: "before_id", value: String(beforeID))]
        }
        guard let url = components.url else { throw MobileAuthenticationError.invalidResponse }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        return try await decode(ActivityPage.self, request: request, decodeISO8601Dates: true)
    }

    func markActivityViewed(
        id: Int,
        accessToken: String,
        configuration: MobileHostConfiguration
    ) async throws {
        var request = URLRequest(url: configuration.activityEndpoint.appending(path: String(id)))
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        let (data, response) = try await noRedirectSession().data(for: request)
        guard data.count <= Self.maximumResponseBytes,
              let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw MobileAuthenticationError.invalidResponse
        }
    }

    func disconnect(host: ConnectedHost, credential: StoredDeviceCredential) async throws {
        let token = try await refresh(host: host, credential: credential)

        var deleteRequest = URLRequest(url: host.origin.appending(path: "/api/v1/mobile/device"))
        deleteRequest.httpMethod = "DELETE"
        deleteRequest.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        deleteRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        deleteRequest.timeoutInterval = 20
        let (data, response) = try await noRedirectSession().data(for: deleteRequest)
        guard data.count <= Self.maximumResponseBytes,
              let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw MobileAuthenticationError.invalidResponse
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
                ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else {
            preconditionFailure("Authentication requires an active window scene")
        }
        guard let window = windowScene.windows.first(where: \.isKeyWindow)
            ?? windowScene.windows.first else {
            preconditionFailure("Authentication requires a presentation window")
        }
        return window
    }

    private func fetchConfiguration(for proposal: ConnectionProposal) async throws -> MobileHostConfiguration {
        var request = URLRequest(url: proposal.configURL)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 15

        let (data, response) = try await noRedirectSession().data(for: request)
        guard data.count <= Self.maximumResponseBytes,
              let http = response as? HTTPURLResponse,
              http.statusCode == 200,
              http.mimeType?.lowercased() == "application/json" else {
            throw MobileAuthenticationError.unsupportedHost
        }
        let configuration = try JSONDecoder().decode(MobileHostConfiguration.self, from: data)
        try configuration.validate(for: proposal)
        return configuration
    }

    private func authorize(
        configuration: MobileHostConfiguration,
        challenge: String,
        state: String
    ) async throws -> URL {
        guard var components = URLComponents(
            url: configuration.authorizationEndpoint,
            resolvingAgainstBaseURL: false
        ) else { throw MobileAuthenticationError.invalidResponse }
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: Self.clientID),
            URLQueryItem(name: "redirect_uri", value: "\(Self.callbackScheme):\(Self.callbackPath)"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state)
        ]
        guard let authorizationURL = components.url else {
            throw MobileAuthenticationError.invalidResponse
        }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authorizationURL,
                callbackURLScheme: Self.callbackScheme
            ) { [weak self] callback, error in
                self?.webAuthenticationSession = nil
                if let callback {
                    continuation.resume(returning: callback)
                } else if let authenticationError = error as? ASWebAuthenticationSessionError,
                          authenticationError.code == .canceledLogin {
                    continuation.resume(throwing: MobileAuthenticationError.authenticationCancelled)
                } else {
                    continuation.resume(throwing: error ?? MobileAuthenticationError.invalidCallback)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            webAuthenticationSession = session
            guard session.start() else {
                webAuthenticationSession = nil
                continuation.resume(throwing: MobileAuthenticationError.invalidResponse)
                return
            }
        }
    }

    private func validateCallback(_ url: URL, expectedState: String) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == Self.callbackScheme,
              components.host == nil,
              components.path == Self.callbackPath,
              components.fragment == nil else {
            throw MobileAuthenticationError.invalidCallback
        }
        let values = Dictionary(grouping: components.queryItems ?? [], by: \.name)
        guard values["state"]?.count == 1,
              values["state"]?.first?.value == expectedState else {
            throw MobileAuthenticationError.stateMismatch
        }
        guard values["code"]?.count == 1,
              let code = values["code"]?.first?.value,
              !code.isEmpty,
              code.utf8.count <= 1_024 else {
            throw MobileAuthenticationError.invalidCallback
        }
        return code
    }

    private func exchange(
        code: String,
        verifier: String,
        configuration: MobileHostConfiguration
    ) async throws -> MobileTokenResponse {
        let body = formEncoded([
            ("grant_type", "authorization_code"),
            ("client_id", Self.clientID),
            ("redirect_uri", "\(Self.callbackScheme):\(Self.callbackPath)"),
            ("code", code),
            ("code_verifier", verifier),
            ("device_name", UIDevice.current.name)
        ])
        var request = URLRequest(url: configuration.tokenEndpoint)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        return try await decode(MobileTokenResponse.self, request: request)
    }

    private func createWebSessionTicket(
        accessToken: String,
        configuration: MobileHostConfiguration
    ) async throws -> WebSessionTicketResponse {
        var request = URLRequest(url: configuration.webSessionTicketEndpoint)
        request.httpMethod = "POST"
        request.httpBody = Data("{}".utf8)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20
        return try await decode(WebSessionTicketResponse.self, request: request)
    }

    private func validateRelayAuthorization(_ response: RelayAuthorizationResponse) throws {
        guard response.expiresIn > 0,
              response.expiresIn <= 60,
              response.authorization.range(of: #"\Alm_ra_[A-Za-z0-9_-]{43}\z"#, options: .regularExpression) != nil,
              let components = URLComponents(url: response.relayRegistrationEndpoint, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "https",
              components.host?.isEmpty == false,
              components.user == nil,
              components.password == nil,
              components.path == "/v1/registrations",
              components.query == nil,
              components.fragment == nil else {
            throw MobileAuthenticationError.invalidResponse
        }
    }

    private func decode<T: Decodable>(
        _ type: T.Type,
        request: URLRequest,
        decodeISO8601Dates: Bool = false
    ) async throws -> T {
        let (data, response) = try await noRedirectSession().data(for: request)
        guard data.count <= Self.maximumResponseBytes,
              let http = response as? HTTPURLResponse else {
            throw MobileAuthenticationError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let error = try? JSONDecoder().decode(ServerError.self, from: data)
            throw MobileAuthenticationError.server(
                error?.errorDescription ?? "The Loomio host rejected the authentication request."
            )
        }
        let decoder = JSONDecoder()
        if decodeISO8601Dates { decoder.dateDecodingStrategy = .iso8601 }
        return try decoder.decode(type, from: data)
    }

    private func noRedirectSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        return URLSession(configuration: configuration, delegate: NoRedirectDelegate.shared, delegateQueue: nil)
    }

    private func randomBase64URL(byteCount: Int) throws -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else { throw KeychainError.unhandled(status) }
        return Data(bytes).base64URLEncodedString()
    }

    private func formEncoded(_ items: [(String, String)]) -> String {
        var components = URLComponents()
        components.queryItems = items.map(URLQueryItem.init)
        return components.percentEncodedQuery ?? ""
    }
}

private struct ServerError: Decodable {
    let error: String
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

private final class NoRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    static let shared = NoRedirectDelegate()

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping @Sendable (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
