import Foundation
import XCTest
@testable import Loomio_Mobile

final class NavigationPolicyTests: XCTestCase {
    private let policy = NavigationPolicy(hostOrigin: URL(string: "https://loomio.example.org")!)

    func testAllowsConnectedOriginAtAnyPath() {
        XCTAssertEqual(policy.decision(for: URL(string: "https://loomio.example.org/d/abc")!), .allowInWebView)
    }

    func testDoesNotConfuseHostSuffixForOrigin() {
        XCTAssertEqual(policy.decision(for: URL(string: "https://loomio.example.org.evil.test")!), .openExternally)
    }

    func testOpensOtherHTTPSOriginsExternally() {
        XCTAssertEqual(policy.decision(for: URL(string: "https://example.com")!), .openExternally)
    }

    func testRejectsUnsafeSchemes() {
        for input in ["http://loomio.example.org", "javascript:alert(1)", "file:///etc/passwd"] {
            XCTAssertEqual(policy.decision(for: URL(string: input)!), .reject, input)
        }
    }

    func testPermitsExplicitAuthenticationOrigin() {
        let authOrigin = URL(string: "https://login.example.org")!
        let authPolicy = NavigationPolicy(
            hostOrigin: URL(string: "https://loomio.example.org")!,
            authenticationOrigins: [authOrigin]
        )
        XCTAssertEqual(authPolicy.decision(for: URL(string: "https://login.example.org/oauth/start")!), .allowInWebView)
    }

    func testDebugBuildAllowsFixedLocalDevelopmentOrigin() {
#if DEBUG
        let localPolicy = NavigationPolicy(hostOrigin: URL(string: "http://localhost:8080")!)
        XCTAssertEqual(
            localPolicy.decision(for: URL(string: "http://localhost:8080/dashboard")!),
            .allowInWebView
        )
        XCTAssertEqual(
            localPolicy.decision(for: URL(string: "http://localhost:3000/dashboard")!),
            .reject
        )
#endif
    }
}
