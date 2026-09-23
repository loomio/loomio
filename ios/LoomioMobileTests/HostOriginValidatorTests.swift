import Foundation
import XCTest
@testable import Loomio_Mobile

final class HostOriginValidatorTests: XCTestCase {
    func testAcceptsAndCanonicalizesHTTPSOrigin() throws {
        let host = try ConnectedHost(input: "  https://Community.Example.org/  ")
        XCTAssertEqual(host.origin.absoluteString, "https://community.example.org")
    }

    func testRejectsNonHTTPSOrigins() {
        for input in ["http://community.example.org", "ftp://community.example.org", "javascript:alert(1)"] {
            XCTAssertThrowsError(try ConnectedHost(input: input), input)
        }
    }

    func testDebugBuildAcceptsOnlyTheFixedLocalDevelopmentOrigin() throws {
#if DEBUG
        let host = try ConnectedHost(input: "http://localhost:8080")
        XCTAssertEqual(host.origin.absoluteString, "http://localhost:8080")
        XCTAssertThrowsError(try ConnectedHost(input: "http://localhost:3000"))
        XCTAssertThrowsError(try ConnectedHost(input: "http://127.0.0.1:8080"))
#endif
    }

    func testRejectsNonOriginInput() {
        let inputs = [
            "https://community.example.org/a/path",
            "https://community.example.org?next=evil",
            "https://community.example.org#fragment",
            "https://user:password@community.example.org"
        ]
        for input in inputs {
            XCTAssertThrowsError(try ConnectedHost(input: input), input)
        }
    }

    func testParsesWebsiteConnectionLink() throws {
        let link = try XCTUnwrap(URL(string:
            "loomio://connect?config=https%3A%2F%2Fcommunity.example.org%2Fapi%2Fv1%2Fmobile%2Fconfig"
        ))
        let proposal = try ConnectionLinkParser.parse(link)

        XCTAssertEqual(
            proposal.configURL.absoluteString,
            "https://community.example.org/api/v1/mobile/config"
        )
        XCTAssertEqual(proposal.origin.absoluteString, "https://community.example.org")
    }

    func testDebugBuildParsesLocalDevelopmentConnectionLink() throws {
#if DEBUG
        let link = try XCTUnwrap(URL(string:
            "loomio://connect?config=http%3A%2F%2Flocalhost%3A8080%2Fapi%2Fv1%2Fmobile%2Fconfig"
        ))
        let proposal = try ConnectionLinkParser.parse(link)

        XCTAssertEqual(proposal.origin.absoluteString, "http://localhost:8080")
#endif
    }

    func testRejectsMalformedConnectionLinks() {
        let links = [
            "loomio://connect?config=http%3A%2F%2Fcommunity.example.org%2Fapi%2Fv1%2Fmobile%2Fconfig",
            "loomio://connect?config=https%3A%2F%2Fcommunity.example.org%2Fwrong",
            "loomio://connect?config=https%3A%2F%2Fuser%3Apass%40community.example.org%2Fapi%2Fv1%2Fmobile%2Fconfig",
            "loomio://connect?config=https%3A%2F%2Fcommunity.example.org%2Fapi%2Fv1%2Fmobile%2Fconfig&extra=1",
            "loomio://disconnect"
        ]

        for link in links {
            XCTAssertThrowsError(try ConnectionLinkParser.parse(URL(string: link)!), link)
        }
    }

    func testRejectsCrossOriginHostConfiguration() throws {
        let proposal = try ConnectionLinkParser.proposal(forHostInput: "https://community.example.org")
        let configuration = MobileHostConfiguration(
            protocolVersion: 1,
            issuer: URL(string: "https://community.example.org")!,
            authorizationEndpoint: URL(string: "https://evil.example/mobile/authorize")!,
            tokenEndpoint: URL(string: "https://community.example.org/api/v1/mobile/token")!,
            webSessionTicketEndpoint: URL(string: "https://community.example.org/api/v1/mobile/web-session-tickets")!,
            webSessionBootstrapEndpoint: URL(string: "https://community.example.org/mobile/web-session")!,
            relayAuthorizationEndpoint: URL(string: "https://community.example.org/api/v1/mobile/relay-authorizations")!,
            pushRegistrationEndpoint: URL(string: "https://community.example.org/api/v1/mobile/push-registration")!,
            activityEndpoint: URL(string: "https://community.example.org/api/v1/mobile/activity")!,
            deviceEndpoint: URL(string: "https://community.example.org/api/v1/mobile/device")!
        )

        XCTAssertThrowsError(try configuration.validate(for: proposal))
    }

    func testActivityDestinationStaysOnConnectedHost() throws {
        let host = try ConnectedHost(input: "https://community.example.org")
        let item = ActivityItem(
            id: 1,
            kind: "discussion_edited",
            title: "A discussion changed",
            name: nil,
            actorName: "Taylor",
            url: "/d/abc/example",
            createdAt: Date(),
            viewed: false
        )

        XCTAssertEqual(item.destination(on: host)?.absoluteString, "https://community.example.org/d/abc/example")
    }

    func testActivityDestinationRejectsNetworkPathReference() throws {
        let host = try ConnectedHost(input: "https://community.example.org")
        let item = ActivityItem(
            id: 1,
            kind: "discussion_edited",
            title: nil,
            name: nil,
            actorName: nil,
            url: "//evil.example/steal",
            createdAt: Date(),
            viewed: false
        )

        XCTAssertNil(item.destination(on: host))
    }
}

final class KeychainCredentialStoreTests: XCTestCase {
    func testStoresAndLoadsDeviceCredential() throws {
        let hostID = UUID()
        let credential = StoredDeviceCredential(
            deviceID: UUID(),
            refreshToken: "local-test-refresh-token"
        )
        defer { KeychainCredentialStore.delete(for: hostID) }

        try KeychainCredentialStore.save(credential, for: hostID)

        XCTAssertEqual(try KeychainCredentialStore.load(for: hostID), credential)
    }
}
