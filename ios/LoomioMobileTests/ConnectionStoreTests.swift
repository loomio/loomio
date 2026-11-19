import Foundation
import WebKit
import XCTest
@testable import Loomio_Mobile

@MainActor
final class ConnectionStoreTests: XCTestCase {
    private func fixture() -> Fixture { Fixture() }

    func testAddingAndSwitchingServersPreservesCredentialsAndSelectedServerOnRelaunch() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let firstCredential = f.vault.values[first.id]
        let second = try await f.connect("https://two.example.org")
        XCTAssertEqual(f.store.connections.count, 2)
        XCTAssertEqual(f.vault.values[first.id], firstCredential)
        XCTAssertEqual(first.webSessionBootstrap?.endpoint.host(), "one.example.org")
        XCTAssertEqual(second.webSessionBootstrap?.endpoint.host(), "two.example.org")
        f.store.select(first)
        XCTAssertEqual(f.store.selectedHostID, first.id)
        let restored = f.makeStore()
        XCTAssertEqual(restored.connections.map(\.id), [first.id, second.id])
        XCTAssertEqual(restored.selectedHostID, first.id)
        XCTAssertEqual(f.vault.values.count, 2)
    }

    func testExistingServerIsSelectedWithoutAuthenticatingOrCreatingAnotherDevice() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        _ = try await f.connect("https://two.example.org")
        try f.store.proposeConnection(to: "https://ONE.example.org:443/")
        XCTAssertNil(f.store.connectionProposal)
        XCTAssertEqual(f.store.selectedHostID, first.id)
        XCTAssertEqual(f.service.connectCount, 2)
        XCTAssertEqual(f.store.connections.count, 2)
    }

    func testLegacyConnectionMigratesWithoutChangingItsKeychainIDOrWebSessionProfile() throws {
        let f = fixture()
        let id = UUID()
        let data = try JSONSerialization.data(withJSONObject: ["id": id.uuidString, "origin": "https://one.example.org"])
        f.defaults.set(data, forKey: "connectedHost")
        let credential = StoredDeviceCredential(deviceID: UUID(), refreshToken: "legacy-refresh")
        f.vault.values[id] = credential
        let migrated = f.makeStore()
        let host = try XCTUnwrap(migrated.connectedHost)
        XCTAssertEqual(host.id, id)
        XCTAssertTrue(host.usesLegacyDataStore)
        XCTAssertNil(HostDataCleaner.websiteDataStore(for: host).identifier)
        XCTAssertEqual(f.vault.values[id], credential)
        XCTAssertNil(f.defaults.data(forKey: "connectedHost"))
        XCTAssertNotNil(f.defaults.data(forKey: "connectedServers"))
        XCTAssertEqual(f.makeStore().connectedHost?.id, id)
    }

    func testPushRegistersEveryServerAndNotificationTapSelectsTheOwningServer() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        await f.store.registerPushIfPossible(apnsToken: "test-apns-token", environment: "sandbox")
        XCTAssertEqual(Set(f.service.pushOrigins), Set([first.host.origin, second.host.origin]))
        XCTAssertNotEqual(first.registrationID, second.registrationID)
        let restored = f.makeStore()
        restored.activityPresented = true
        restored.openNotification(registrationID: first.registrationID)
        XCTAssertEqual(restored.selectedHostID, first.id)
        XCTAssertFalse(restored.activityPresented)
        XCTAssertEqual(restored.selectedConnection?.webDestination, URL(string: "https://one.example.org/notifications"))
        XCTAssertEqual(f.vault.values[first.id]?.apnsToken, "test-apns-token")
        XCTAssertEqual(f.vault.values[second.id]?.apnsEnvironment, "sandbox")
    }

    func testPushFailureOnOneServerDoesNotBlockAnother() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        f.service.failingPushOrigin = first.host.origin
        await f.store.registerPushIfPossible(apnsToken: "test-apns-token", environment: "sandbox")
        XCTAssertNotNil(first.pushRegistrationError)
        XCTAssertFalse(first.pushRegistered)
        XCTAssertTrue(second.pushRegistered)
        XCTAssertNil(second.pushRegistrationError)
    }

    func testActivityIDsAreNamespacedAndOpeningAnItemKeepsItsServer() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        f.service.pages[first.host.origin] = ActivityPage(activity: [item(id: 7, seconds: 100)], nextBeforeID: nil)
        f.service.pages[second.host.origin] = ActivityPage(activity: [item(id: 7, seconds: 200)], nextBeforeID: nil)
        await f.store.loadActivity()
        let combined = f.store.combinedActivity
        XCTAssertEqual(combined.count, 2)
        XCTAssertEqual(Set(combined.map(\.id)).count, 2)
        XCTAssertEqual(combined.first?.connection.id, second.id)
        f.store.openActivity(try XCTUnwrap(combined.last))
        XCTAssertEqual(f.store.selectedHostID, first.id)
        XCTAssertEqual(first.webDestination, URL(string: "https://one.example.org/d/thread"))
        XCTAssertNil(second.webDestination)
    }

    func testActivityFailureOnOneServerKeepsAnotherServersFeedAvailable() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        f.service.failingActivityOrigin = first.host.origin
        f.service.pages[second.host.origin] = ActivityPage(activity: [item(id: 9, seconds: 100)], nextBeforeID: nil)
        await f.store.loadActivity()
        XCTAssertNotNil(first.activityError)
        XCTAssertEqual(f.store.combinedActivity.count, 1)
        XCTAssertEqual(f.store.combinedActivity.first?.connection.id, second.id)
    }

    func testConcurrentRefreshesCoalesceWithinOneServerAndStaySeparateAcrossServers() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        await f.store.registerPushIfPossible(apnsToken: "test-token", environment: "sandbox")
        f.service.refreshOrigins = []
        f.service.heldOrigin = first.host.origin
        let activity = Task { await first.loadActivity() }
        await waitUntil { f.service.refreshContinuation != nil }
        let testPush = Task { await first.sendTestPush() }
        let otherActivity = Task { await second.loadActivity() }
        await otherActivity.value
        f.service.releaseRefresh()
        await activity.value
        await testPush.value
        XCTAssertEqual(f.service.refreshOrigins.filter { $0 == first.host.origin }.count, 1)
        XCTAssertEqual(f.service.refreshOrigins.filter { $0 == second.host.origin }.count, 1)
        XCTAssertEqual(f.service.testPushOrigins, [first.host.origin])
    }

    func testDisconnectWaitsForRotationAndOnlyRemovesThatServersData() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        let secondCredential = f.vault.values[second.id]
        f.service.heldOrigin = first.host.origin
        let activity = Task { await first.loadActivity() }
        await waitUntil { f.service.refreshContinuation != nil }
        let removal = Task { await f.store.disconnect(first) }
        await waitUntil { first.isDisconnecting }
        XCTAssertEqual(f.store.connections.map(\.id), [second.id])
        f.service.releaseRefresh()
        await activity.value
        await removal.value
        XCTAssertNil(f.vault.values[first.id])
        XCTAssertEqual(f.vault.values[second.id], secondCredential)
        XCTAssertEqual(f.cleanedHostIDs, [first.id])
        XCTAssertEqual(f.store.connections.map(\.id), [second.id])
        XCTAssertEqual(f.service.disconnectedCredentials.first?.refreshToken, "rotated-one.example.org")
        await first.registerPushIfPossible(apnsToken: "late-token", environment: "sandbox")
        XCTAssertNil(f.vault.values[first.id])
    }

    func testUnknownAndDisconnectedNotificationRegistrationsOpenCombinedActivity() async throws {
        let f = fixture()
        let first = try await f.connect("https://one.example.org")
        let second = try await f.connect("https://two.example.org")
        await f.store.registerPushIfPossible(apnsToken: "test-token", environment: "sandbox")
        let oldRegistration = first.registrationID
        await f.store.disconnect(first)
        f.store.openNotification(registrationID: oldRegistration)
        XCTAssertTrue(f.store.activityPresented)
        XCTAssertEqual(f.store.selectedHostID, second.id)
        XCTAssertNil(second.webDestination)
        f.store.activityPresented = false
        f.store.openNotification(registrationID: nil)
        XCTAssertTrue(f.store.activityPresented)
    }

    func testPushSignalsAreScopedToTheirRegistration() {
        let manager = PushNotificationManager()
        let first = UUID()
        let second = UUID()
        manager.receivedNotification(registrationID: first.uuidString)
        XCTAssertEqual(manager.notificationSignal(for: first), 1)
        XCTAssertEqual(manager.notificationSignal(for: second), 0)
        manager.receivedNotificationResponse(registrationID: second.uuidString)
        XCTAssertEqual(manager.activatedRegistrationID, second)
        XCTAssertEqual(manager.notificationSignal(for: first), 1)
        XCTAssertEqual(manager.notificationSignal(for: second), 1)
    }

    func testRefreshPreservesRegistrationCompletedWhileItsRequestWasInFlight() async throws {
        let f = fixture()
        let connection = try await f.connect("https://one.example.org")
        f.service.heldPushOrigin = connection.host.origin
        let registration = Task { await connection.registerPushIfPossible(apnsToken: "new-token", environment: "production") }
        await waitUntil { f.service.pushContinuation != nil }
        f.service.heldOrigin = connection.host.origin
        let activity = Task { await connection.loadActivity() }
        await waitUntil { f.service.refreshContinuation != nil }
        f.service.releasePush()
        await registration.value
        f.service.releaseRefresh()
        await activity.value
        XCTAssertEqual(f.vault.values[connection.id]?.apnsToken, "new-token")
        XCTAssertEqual(f.vault.values[connection.id]?.registrationID, connection.registrationID)
        XCTAssertEqual(f.vault.values[connection.id]?.apnsEnvironment, "production")
    }

    func testNewServerWebsiteStoresDoNotShareParentDomainCookies() async throws {
        let first = try ConnectedHost(input: "https://one.example.org")
        let second = try ConnectedHost(input: "https://two.example.org")
        let firstStore = HostDataCleaner.websiteDataStore(for: first)
        let secondStore = HostDataCleaner.websiteDataStore(for: second)
        XCTAssertEqual(firstStore.identifier, first.id)
        XCTAssertEqual(secondStore.identifier, second.id)
        let cookie = try XCTUnwrap(HTTPCookie(properties: [.domain: ".example.org", .path: "/", .name: "session", .value: "private-first-session", .secure: "TRUE"]))
        await firstStore.httpCookieStore.setCookie(cookie)
        let firstCookies = await firstStore.httpCookieStore.allCookies()
        let secondCookies = await secondStore.httpCookieStore.allCookies()
        XCTAssertTrue(firstCookies.contains { $0.name == "session" })
        XCTAssertFalse(secondCookies.contains { $0.name == "session" })
        let secondCookie = try XCTUnwrap(HTTPCookie(properties: [.domain: ".example.org", .path: "/", .name: "session", .value: "private-second-session", .secure: "TRUE"]))
        await secondStore.httpCookieStore.setCookie(secondCookie)
        await HostDataCleaner.clearData(for: first, registrationID: nil)
        let remainingCookies = await secondStore.httpCookieStore.allCookies()
        XCTAssertTrue(remainingCookies.contains { $0.value == "private-second-session" })
        await HostDataCleaner.clearData(for: second, registrationID: nil)
    }

    private func item(id: Int, seconds: TimeInterval) -> ActivityItem {
        ActivityItem(id: id, kind: "discussion", title: "An update", name: nil, actorName: nil,
                     url: "/d/thread", createdAt: Date(timeIntervalSince1970: seconds), viewed: true)
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<1_000 {
            if condition() { return }
            await Task.yield()
        }
        XCTFail("Expected asynchronous operation to start")
    }
}

@MainActor
private final class Fixture {
    let suite = "ConnectionStoreTests-\(UUID())"
    let defaults: UserDefaults
    let service = FakeAuthenticationService()
    let vault = FakeCredentials()
    var cleanedHostIDs: [UUID] = []
    lazy var store = makeStore()

    init() { defaults = UserDefaults(suiteName: suite)! }
    deinit { UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite) }

    func makeStore() -> ConnectionStore {
        ConnectionStore(defaults: defaults, authentication: service, credentials: vault.access) { [weak self] host, _ in
            self?.cleanedHostIDs.append(host.id)
        }
    }

    func connect(_ input: String) async throws -> HostConnection {
        try store.proposeConnection(to: input)
        await store.confirmConnection()
        XCTAssertNil(store.connectionError)
        return try XCTUnwrap(store.selectedConnection)
    }
}

@MainActor
private final class FakeCredentials {
    var values: [UUID: StoredDeviceCredential] = [:]
    var access: DeviceCredentialAccess {
        DeviceCredentialAccess(load: { self.values[$0] }, save: { self.values[$1] = $0 }, delete: { self.values.removeValue(forKey: $0) })
    }
}

@MainActor
private final class FakeAuthenticationService: MobileAuthenticationProviding {
    var connectCount = 0
    var refreshOrigins: [URL] = []
    var pushOrigins: [URL] = []
    var testPushOrigins: [URL] = []
    var disconnectedCredentials: [StoredDeviceCredential] = []
    var pages: [URL: ActivityPage] = [:]
    var failingPushOrigin: URL?
    var failingActivityOrigin: URL?
    var heldPushOrigin: URL?
    var pushContinuation: CheckedContinuation<Void, Never>?
    var heldOrigin: URL?
    var refreshContinuation: CheckedContinuation<Void, Never>?
    private var deviceIDs: [URL: UUID] = [:]
    private var registrations: [URL: UUID] = [:]

    func connect(using proposal: ConnectionProposal) async throws -> AuthenticatedConnection {
        connectCount += 1
        let host = try ConnectedHost(origin: proposal.origin)
        let config = try await configuration(for: host)
        return AuthenticatedConnection(host: host, token: token(for: host.origin, rotated: false),
                                       bootstrap: WebSessionBootstrap(endpoint: config.webSessionBootstrapEndpoint, ticket: "test-ticket"), configuration: config)
    }

    func configuration(for host: ConnectedHost) async throws -> MobileHostConfiguration {
        let origin = host.origin
        return MobileHostConfiguration(protocolVersion: 1, issuer: origin,
            authorizationEndpoint: origin.appending(path: "mobile/authorize"), tokenEndpoint: origin.appending(path: "api/v1/mobile/token"),
            webSessionTicketEndpoint: origin.appending(path: "api/v1/mobile/web-session-tickets"), webSessionBootstrapEndpoint: origin.appending(path: "mobile/web-session"),
            relayAuthorizationEndpoint: origin.appending(path: "api/v1/mobile/relay-authorizations"), pushRegistrationEndpoint: origin.appending(path: "api/v1/mobile/push-registration"),
            activityEndpoint: origin.appending(path: "api/v1/mobile/activity"), deviceEndpoint: origin.appending(path: "api/v1/mobile/device"))
    }

    func refresh(host: ConnectedHost, credential: StoredDeviceCredential) async throws -> MobileTokenResponse {
        XCTAssertEqual(credential.deviceID, deviceIDs[host.origin], "A server must never receive another server's credential")
        refreshOrigins.append(host.origin)
        if heldOrigin == host.origin { await withCheckedContinuation { refreshContinuation = $0 } }
        return token(for: host.origin, rotated: true)
    }

    func releaseRefresh() {
        heldOrigin = nil
        refreshContinuation?.resume()
        refreshContinuation = nil
    }

    func releasePush() {
        heldPushOrigin = nil
        pushContinuation?.resume()
        pushContinuation = nil
    }

    func registerPush(apnsToken: String, environment: String, accessToken: String, configuration: MobileHostConfiguration) async throws -> UUID {
        XCTAssertEqual(accessToken, "access-\(configuration.issuer.host()!)")
        pushOrigins.append(configuration.issuer)
        if heldPushOrigin == configuration.issuer { await withCheckedContinuation { pushContinuation = $0 } }
        if configuration.issuer == failingPushOrigin { throw MobileAuthenticationError.server("Relay unavailable") }
        let registration = registrations[configuration.issuer] ?? UUID()
        registrations[configuration.issuer] = registration
        return registration
    }

    func sendTestPush(accessToken: String, configuration: MobileHostConfiguration) async throws {
        XCTAssertEqual(accessToken, "access-\(configuration.issuer.host()!)")
        testPushOrigins.append(configuration.issuer)
    }

    func activity(accessToken: String, configuration: MobileHostConfiguration, beforeID: Int?) async throws -> ActivityPage {
        XCTAssertEqual(accessToken, "access-\(configuration.issuer.host()!)")
        if configuration.issuer == failingActivityOrigin { throw MobileAuthenticationError.server("Host unavailable") }
        return pages[configuration.issuer] ?? ActivityPage(activity: [], nextBeforeID: nil)
    }

    func markActivityViewed(id: Int, accessToken: String, configuration: MobileHostConfiguration) async throws {
        XCTAssertEqual(accessToken, "access-\(configuration.issuer.host()!)")
    }

    func disconnect(host: ConnectedHost, credential: StoredDeviceCredential) async throws {
        XCTAssertEqual(credential.deviceID, deviceIDs[host.origin])
        disconnectedCredentials.append(credential)
    }

    private func token(for origin: URL, rotated: Bool) -> MobileTokenResponse {
        let deviceID = deviceIDs[origin] ?? UUID()
        deviceIDs[origin] = deviceID
        return MobileTokenResponse(tokenType: "Bearer", accessToken: "access-\(origin.host()!)", expiresIn: 600,
            refreshToken: "\(rotated ? "rotated" : "initial")-\(origin.host()!)", refreshTokenExpiresIn: 86400,
            device: MobileTokenResponse.Device(id: deviceID, name: "Test phone"), scope: "activity:read notifications:manage")
    }
}
