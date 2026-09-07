import Foundation

enum NavigationDecision: Equatable {
    case allowInWebView
    case openExternally
    case reject
}

struct NavigationPolicy: Sendable {
    let hostOrigin: URL
    let authenticationOrigins: Set<URL>

    init(hostOrigin: URL, authenticationOrigins: Set<URL> = []) {
        self.hostOrigin = hostOrigin
        self.authenticationOrigins = authenticationOrigins
    }

    func decision(for destination: URL) -> NavigationDecision {
        guard let scheme = destination.scheme?.lowercased() else { return .reject }

        if destination.matchesOrigin(hostOrigin),
           let host = destination.host(),
           HostOriginValidator.permitsTransport(
               scheme: destination.scheme,
               host: host,
               port: destination.port
           ) {
            return .allowInWebView
        }
        guard scheme == "https" else { return .reject }
        if authenticationOrigins.contains(where: destination.matchesOrigin) { return .allowInWebView }
        return .openExternally
    }
}

extension URL {
    func matchesOrigin(_ other: URL) -> Bool {
        scheme?.lowercased() == other.scheme?.lowercased()
            && host()?.lowercased() == other.host()?.lowercased()
            && effectivePort == other.effectivePort
    }

    private var effectivePort: Int? {
        if let port { return port }
        switch scheme?.lowercased() {
        case "https": return 443
        case "http": return 80
        default: return nil
        }
    }
}
