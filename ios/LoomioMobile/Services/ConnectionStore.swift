import Foundation
import Combine

@MainActor
protocol MobileAuthenticationProviding {
    func connect(using proposal: ConnectionProposal) async throws -> AuthenticatedConnection
    func configuration(for host: ConnectedHost) async throws -> MobileHostConfiguration
    func refresh(host: ConnectedHost, credential: StoredDeviceCredential) async throws -> MobileTokenResponse
    func registerPush(apnsToken: String, environment: String, accessToken: String, configuration: MobileHostConfiguration) async throws -> UUID
    func sendTestPush(accessToken: String, configuration: MobileHostConfiguration) async throws
    func activity(accessToken: String, configuration: MobileHostConfiguration, beforeID: Int?) async throws -> ActivityPage
    func markActivityViewed(id: Int, accessToken: String, configuration: MobileHostConfiguration) async throws
    func disconnect(host: ConnectedHost, credential: StoredDeviceCredential) async throws
}

@MainActor
struct DeviceCredentialAccess {
    var load: (UUID) throws -> StoredDeviceCredential?
    var save: (StoredDeviceCredential, UUID) throws -> Void
    var delete: (UUID) -> Void

    static let keychain = DeviceCredentialAccess(
        load: { try KeychainCredentialStore.load(for: $0) },
        save: { try KeychainCredentialStore.save($0, for: $1) },
        delete: { KeychainCredentialStore.delete(for: $0) }
    )
}

/// Owns credentials, token rotation and UI state for exactly one server.
@MainActor
final class HostConnection: ObservableObject, Identifiable {
    let host: ConnectedHost
    nonisolated var id: UUID { host.id }
    @Published private(set) var isDisconnecting = false
    @Published private(set) var webSessionBootstrap: WebSessionBootstrap?
    @Published private(set) var pushRegistrationError: String?
    @Published private(set) var pushRegistered = false
    @Published private(set) var registrationID: UUID?
    @Published private(set) var isUpdatingPush = false
    @Published private(set) var activity: [ActivityItem] = []
    @Published private(set) var isLoadingActivity = false
    @Published private(set) var activityError: String?
    @Published private(set) var webDestination: URL?
    private let authentication: any MobileAuthenticationProviding
    private let credentials: DeviceCredentialAccess
    private let clearHostData: (ConnectedHost, UUID?) async -> Void
    private var isRegisteringPush = false
    private var isRemoved = false
    private var nextActivityBeforeID: Int?
    private var accessRefreshTask: Task<(MobileHostConfiguration, MobileTokenResponse), Error>?

    init(host: ConnectedHost, authentication: any MobileAuthenticationProviding, credentials: DeviceCredentialAccess,
         clearHostData: @escaping (ConnectedHost, UUID?) async -> Void, bootstrap: WebSessionBootstrap? = nil) {
        self.host = host
        self.authentication = authentication
        self.credentials = credentials
        self.clearHostData = clearHostData
        webSessionBootstrap = bootstrap
        if let credential = try? credentials.load(host.id) {
            registrationID = credential.registrationID
            pushRegistered = credential.apnsToken != nil
        }
    }

    func consumeWebSessionBootstrap() {
        webSessionBootstrap = nil
    }

    func registerPushIfPossible(apnsToken: String, environment: String) async {
        guard !isDisconnecting, !isRemoved, !isRegisteringPush else { return }
        isRegisteringPush = true
        pushRegistrationError = nil
        defer { isRegisteringPush = false }

        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            guard !isRemoved, !isDisconnecting else { return }
            let accessToken = token.accessToken
            let registrationID = try await authentication.registerPush(
                apnsToken: apnsToken,
                environment: environment,
                accessToken: accessToken,
                configuration: configuration
            )
            guard !isRemoved, !isDisconnecting else { return }
            pushRegistered = true
            self.registrationID = registrationID
            let currentCredential = try credentials.load(host.id)
            if let currentCredential {
                try credentials.save(
                    StoredDeviceCredential(
                        deviceID: currentCredential.deviceID,
                        refreshToken: currentCredential.refreshToken,
                        apnsToken: apnsToken,
                        apnsEnvironment: environment,
                        registrationID: registrationID
                    ),
                    host.id
                )
            }
        } catch {
            pushRegistrationError = error.localizedDescription
        }
    }

    func sendTestPush() async {
        guard !isDisconnecting, !isRemoved, pushRegistered, !isUpdatingPush else { return }
        isUpdatingPush = true
        pushRegistrationError = nil
        defer { isUpdatingPush = false }

        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            guard !isRemoved, !isDisconnecting else { return }
            try await authentication.sendTestPush(
                accessToken: token.accessToken,
                configuration: configuration
            )
        } catch {
            pushRegistrationError = error.localizedDescription
        }
    }

    func loadActivity(reset: Bool = true) async {
        guard !isDisconnecting, !isRemoved, !isLoadingActivity else { return }
        guard reset || nextActivityBeforeID != nil else { return }
        isLoadingActivity = true
        activityError = nil
        defer { isLoadingActivity = false }

        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            guard !isRemoved, !isDisconnecting else { return }
            let page = try await authentication.activity(
                accessToken: token.accessToken,
                configuration: configuration,
                beforeID: reset ? nil : nextActivityBeforeID
            )
            guard !isRemoved else { return }
            if reset {
                activity = page.activity
            } else {
                let existingIDs = Set(activity.map(\.id))
                activity.append(contentsOf: page.activity.filter { !existingIDs.contains($0.id) })
            }
            nextActivityBeforeID = page.nextBeforeID
        } catch {
            activityError = error.localizedDescription
        }
    }

    var canLoadMoreActivity: Bool { nextActivityBeforeID != nil }

    func clearActivityError() {
        activityError = nil
    }

    func openActivity(_ item: ActivityItem) {
        guard !isRemoved, let destination = item.destination(on: host) else {
            activityError = "This activity item has an invalid destination."
            return
        }
        webDestination = destination
        guard !item.viewed else { return }
        if let index = activity.firstIndex(where: { $0.id == item.id }) {
            activity[index].viewed = true
        }
        Task { await markActivityViewed(item.id, host: host) }
    }

    func consumeWebDestination() {
        webDestination = nil
    }

    func openNotifications() {
        guard !isRemoved else { return }
        webDestination = host.origin.appendingPathComponent("notifications")
    }

    private func markActivityViewed(_ id: Int, host: ConnectedHost) async {
        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            guard !isRemoved, !isDisconnecting else { return }
            try await authentication.markActivityViewed(
                id: id,
                accessToken: token.accessToken,
                configuration: configuration
            )
        } catch {
            if let index = activity.firstIndex(where: { $0.id == id }) {
                activity[index].viewed = false
            }
            activityError = error.localizedDescription
        }
    }

    private func refreshedAccess(for host: ConnectedHost) async throws -> (MobileHostConfiguration, MobileTokenResponse) {
        guard !isRemoved, !isDisconnecting else { throw CancellationError() }
        if let accessRefreshTask { return try await accessRefreshTask.value }
        let task = Task { @MainActor in
            guard let credential = try credentials.load(host.id) else {
                throw MobileAuthenticationError.invalidResponse
            }
            let configuration = try await authentication.configuration(for: host)
            let token = try await authentication.refresh(host: host, credential: credential)
            guard !isRemoved else { throw CancellationError() }
            // Registration may have completed while the refresh request was in flight.
            guard let currentCredential = try credentials.load(host.id) else { throw CancellationError() }
            try credentials.save(
                StoredDeviceCredential(
                    deviceID: token.device.id,
                    refreshToken: token.refreshToken,
                    apnsToken: currentCredential.apnsToken,
                    apnsEnvironment: currentCredential.apnsEnvironment,
                    registrationID: currentCredential.registrationID
                ),
                host.id
            )
            return (configuration, token)
        }
        accessRefreshTask = task
        defer { accessRefreshTask = nil }
        return try await task.value
    }

    func disconnect() async {
        guard !isDisconnecting, !isRemoved else { return }
        isDisconnecting = true
        // Finish an in-flight rotation before revoking with the newest credential.
        _ = try? await accessRefreshTask?.value
        isRemoved = true
        if let credential = try? credentials.load(host.id) {
            try? await authentication.disconnect(host: host, credential: credential)
        }
        credentials.delete(host.id)
        await clearHostData(host, registrationID)
        webSessionBootstrap = nil
        webDestination = nil
        activity = []
        pushRegistered = false
        registrationID = nil
        isDisconnecting = false
    }
}

struct ServerActivityItem: Identifiable {
    struct ID: Hashable { let hostID: UUID; let activityID: Int }
    let connection: HostConnection
    let activity: ActivityItem
    var id: ID { ID(hostID: connection.id, activityID: activity.id) }
}

/// Keeps server membership separate from the server currently shown on screen.
@MainActor
final class ConnectionStore: ObservableObject {
    @Published private(set) var connections: [HostConnection] = []
    @Published private(set) var selectedHostID: UUID?
    @Published var connectionProposal: ConnectionProposal?
    @Published var connectionError: String?
    @Published private(set) var isConnecting = false
    @Published var activityPresented = false
    @Published var addHostPresented = false

    var selectedConnection: HostConnection? { connections.first { $0.id == selectedHostID } }
    var connectedHost: ConnectedHost? { selectedConnection?.host }
    var combinedActivity: [ServerActivityItem] {
        connections.flatMap { connection in
            connection.activity.map { ServerActivityItem(connection: connection, activity: $0) }
        }.sorted {
            if $0.activity.createdAt != $1.activity.createdAt { return $0.activity.createdAt > $1.activity.createdAt }
            if $0.connection.id != $1.connection.id { return $0.connection.id.uuidString < $1.connection.id.uuidString }
            return $0.activity.id > $1.activity.id
        }
    }

    private let defaults: UserDefaults
    private let authentication: any MobileAuthenticationProviding
    private let credentials: DeviceCredentialAccess
    private let clearHostData: (ConnectedHost, UUID?) async -> Void
    private var subscriptions: [UUID: AnyCancellable] = [:]
    private struct SavedConnections: Codable {
        let hosts: [ConnectedHost]
        let selectedHostID: UUID?
    }

    init(defaults: UserDefaults = .standard,
         authentication: any MobileAuthenticationProviding = MobileAuthenticationService.shared,
         credentials: DeviceCredentialAccess = .keychain,
         clearHostData: @escaping (ConnectedHost, UUID?) async -> Void = { await HostDataCleaner.clearData(for: $0, registrationID: $1) }) {
        self.defaults = defaults
        self.authentication = authentication
        self.credentials = credentials
        self.clearHostData = clearHostData
        var savedData = defaults.data(forKey: "connectedServers")
#if DEBUG
        // UI fixtures contain only server metadata, never credentials or tokens.
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-connectedServers"), arguments.indices.contains(index + 1) {
            savedData = arguments[index + 1].data(using: .utf8)
        }
#endif
        if let data = savedData,
           let saved = try? JSONDecoder().decode(SavedConnections.self, from: data) {
            for host in saved.hosts where !connections.contains(where: { $0.id == host.id || $0.host.origin.matchesOrigin(host.origin) }) {
                appendConnection(host: host)
            }
            selectedHostID = connections.first { $0.id == saved.selectedHostID }?.id ?? connections.first?.id
        } else if let data = defaults.data(forKey: "connectedHost"),
                  let host = try? JSONDecoder().decode(ConnectedHost.self, from: data) {
            // Preserve the old UUID/Keychain item and its existing default WebKit profile.
            appendConnection(host: host)
            selectedHostID = host.id
            persist()
            defaults.removeObject(forKey: "connectedHost")
            defaults.removeObject(forKey: "pushRegistered")
        }
    }

    func select(_ connection: HostConnection) {
        guard connections.contains(where: { $0 === connection }) else { return }
        selectedHostID = connection.id
        persist()
    }

    func proposeConnection(to input: String) throws {
        connectionError = nil
        propose(try ConnectionLinkParser.proposal(forHostInput: input))
    }

    func handleIncomingURL(_ url: URL) {
        do {
            connectionError = nil
            propose(try ConnectionLinkParser.parse(url))
        } catch { connectionError = error.localizedDescription }
    }

    private func propose(_ proposal: ConnectionProposal) {
        guard !isConnecting else { return }
        if let existing = connections.first(where: { $0.host.origin.matchesOrigin(proposal.origin) }) {
            select(existing)
            connectionProposal = nil
            addHostPresented = false
        } else {
            connectionProposal = proposal
        }
    }

    func cancelConnectionProposal() {
        guard !isConnecting else { return }
        connectionProposal = nil
        connectionError = nil
    }

    func confirmConnection() async {
        guard let proposal = connectionProposal, !isConnecting else { return }
        isConnecting = true
        connectionError = nil
        defer { isConnecting = false }
        do {
            let result = try await authentication.connect(using: proposal)
            try credentials.save(StoredDeviceCredential(deviceID: result.token.device.id, refreshToken: result.token.refreshToken), result.host.id)
            appendConnection(host: result.host, bootstrap: result.bootstrap)
            selectedHostID = result.host.id
            persist()
            connectionProposal = nil
            addHostPresented = false
        } catch { connectionError = error.localizedDescription }
    }

    func registerPushIfPossible(apnsToken: String, environment: String) async {
        // One unavailable server must not prevent registration on the others.
        await withTaskGroup(of: Void.self) { group in
            for connection in connections {
                group.addTask { await connection.registerPushIfPossible(apnsToken: apnsToken, environment: environment) }
            }
        }
    }

    func loadActivity(reset: Bool = true) async {
        await withTaskGroup(of: Void.self) { group in
            for connection in connections {
                group.addTask { await connection.loadActivity(reset: reset) }
            }
        }
    }

    func openActivity(_ item: ServerActivityItem) {
        guard connections.contains(where: { $0 === item.connection }) else { return }
        select(item.connection)
        item.connection.openActivity(item.activity)
        activityPresented = false
    }

    func openNotification(registrationID: UUID?) {
        // Unknown/old/disconnected registrations can only open the combined activity view.
        guard let registrationID,
              let connection = connections.first(where: { $0.registrationID == registrationID }) else {
            activityPresented = true
            return
        }
        select(connection)
        connection.openNotifications()
        activityPresented = false
    }

    func disconnect(_ connection: HostConnection) async {
        guard connections.contains(where: { $0 === connection }), !connection.isDisconnecting else { return }
        // Remove the page before clearing its website data so it cannot refill the store.
        connections.removeAll { $0 === connection }
        subscriptions.removeValue(forKey: connection.id)
        if selectedHostID == connection.id { selectedHostID = connections.first?.id }
        persist()
        await connection.disconnect()
    }

    private func appendConnection(host: ConnectedHost, bootstrap: WebSessionBootstrap? = nil) {
        let connection = HostConnection(host: host, authentication: authentication, credentials: credentials,
                                        clearHostData: clearHostData, bootstrap: bootstrap)
        subscriptions[host.id] = connection.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
        connections.append(connection)
    }

    private func persist() {
        let saved = SavedConnections(hosts: connections.map(\.host), selectedHostID: selectedHostID)
        defaults.set(try? JSONEncoder().encode(saved), forKey: "connectedServers")
    }
}
