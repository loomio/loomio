import Foundation
import Combine

@MainActor
final class ConnectionStore: ObservableObject {
    @Published private(set) var connectedHost: ConnectedHost?
    @Published var isDisconnecting = false
    @Published var connectionProposal: ConnectionProposal?
    @Published var connectionError: String?
    @Published var isConnecting = false
    @Published private(set) var webSessionBootstrap: WebSessionBootstrap?
    @Published private(set) var pushRegistrationError: String?
    @Published private(set) var pushRegistered = false
    @Published private(set) var isUpdatingPush = false
    @Published private(set) var activity: [ActivityItem] = []
    @Published private(set) var isLoadingActivity = false
    @Published private(set) var activityError: String?
    @Published private(set) var webDestination: URL?

    private let defaults: UserDefaults
    private let storageKey = "connectedHost"
    private let pushRegisteredKey = "pushRegistered"
    private var transientAccessToken: String?
    private var transientConfiguration: MobileHostConfiguration?
    private var isRegisteringPush = false
    private var nextActivityBeforeID: Int?
    private var accessRefreshTask: Task<(MobileHostConfiguration, MobileTokenResponse), Error>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey) {
            connectedHost = try? JSONDecoder().decode(ConnectedHost.self, from: data)
            pushRegistered = defaults.bool(forKey: pushRegisteredKey)
        }
    }

    func proposeConnection(to input: String) throws {
        connectionError = nil
        connectionProposal = try ConnectionLinkParser.proposal(forHostInput: input)
    }

    func handleIncomingURL(_ url: URL) {
        do {
            connectionError = nil
            connectionProposal = try ConnectionLinkParser.parse(url)
        } catch {
            connectionError = error.localizedDescription
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

        do {
            let result = try await MobileAuthenticationService.shared.connect(using: proposal)
            let credential = StoredDeviceCredential(
                deviceID: result.token.device.id,
                refreshToken: result.token.refreshToken
            )
            try KeychainCredentialStore.save(credential, for: result.host.id)

            if let previousHost = connectedHost, previousHost.id != result.host.id {
                KeychainCredentialStore.delete(for: previousHost.id)
                await HostDataCleaner.clearData(for: previousHost)
            }

            connectedHost = result.host
            webSessionBootstrap = result.bootstrap
            transientAccessToken = result.token.accessToken
            transientConfiguration = result.configuration
            defaults.set(try JSONEncoder().encode(result.host), forKey: storageKey)
            connectionProposal = nil
        } catch {
            connectionError = error.localizedDescription
        }
        isConnecting = false
    }

    func consumeWebSessionBootstrap() {
        webSessionBootstrap = nil
    }

    func registerPushIfPossible(apnsToken: String, environment: String) async {
        guard let host = connectedHost, !isRegisteringPush else { return }
        isRegisteringPush = true
        pushRegistrationError = nil
        defer { isRegisteringPush = false }

        do {
            let storedCredential = try KeychainCredentialStore.load(for: host.id)
            let configuration: MobileHostConfiguration
            let accessToken: String
            if let currentConfiguration = transientConfiguration,
               let currentAccessToken = transientAccessToken,
               currentConfiguration.issuer.matchesOrigin(host.origin) {
                configuration = currentConfiguration
                accessToken = currentAccessToken
            } else {
                guard let credential = storedCredential else { return }
                configuration = try await MobileAuthenticationService.shared.configuration(for: host)
                let token = try await MobileAuthenticationService.shared.refresh(host: host, credential: credential)
                try KeychainCredentialStore.save(
                    StoredDeviceCredential(deviceID: token.device.id, refreshToken: token.refreshToken),
                    for: host.id
                )
                accessToken = token.accessToken
            }
            try await MobileAuthenticationService.shared.registerPush(
                apnsToken: apnsToken,
                environment: environment,
                accessToken: accessToken,
                configuration: configuration
            )
            pushRegistered = true
            defaults.set(true, forKey: pushRegisteredKey)
            let currentCredential = try KeychainCredentialStore.load(for: host.id)
            if let currentCredential {
                try KeychainCredentialStore.save(
                    StoredDeviceCredential(
                        deviceID: currentCredential.deviceID,
                        refreshToken: currentCredential.refreshToken,
                        apnsToken: apnsToken,
                        apnsEnvironment: environment
                    ),
                    for: host.id
                )
            }
            transientAccessToken = nil
            transientConfiguration = nil
        } catch {
            pushRegistrationError = error.localizedDescription
        }
    }

    func sendTestPush() async {
        guard let host = connectedHost, pushRegistered, !isUpdatingPush else { return }
        isUpdatingPush = true
        pushRegistrationError = nil
        defer { isUpdatingPush = false }

        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            try await MobileAuthenticationService.shared.sendTestPush(
                accessToken: token.accessToken,
                configuration: configuration
            )
        } catch {
            pushRegistrationError = error.localizedDescription
        }
    }

    func loadActivity(reset: Bool = true) async {
        guard let host = connectedHost, !isLoadingActivity else { return }
        isLoadingActivity = true
        activityError = nil
        defer { isLoadingActivity = false }

        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            let page = try await MobileAuthenticationService.shared.activity(
                accessToken: token.accessToken,
                configuration: configuration,
                beforeID: reset ? nil : nextActivityBeforeID
            )
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
        guard let host = connectedHost, let destination = item.destination(on: host) else {
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
        guard let host = connectedHost else { return }
        webDestination = host.origin.appendingPathComponent("notifications")
    }

    private func markActivityViewed(_ id: Int, host: ConnectedHost) async {
        do {
            let (configuration, token) = try await refreshedAccess(for: host)
            try await MobileAuthenticationService.shared.markActivityViewed(
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
        if let accessRefreshTask { return try await accessRefreshTask.value }
        let task = Task { @MainActor in
            guard let credential = try KeychainCredentialStore.load(for: host.id) else {
                throw MobileAuthenticationError.invalidResponse
            }
            let configuration = try await MobileAuthenticationService.shared.configuration(for: host)
            let token = try await MobileAuthenticationService.shared.refresh(host: host, credential: credential)
            try KeychainCredentialStore.save(
                StoredDeviceCredential(
                    deviceID: token.device.id,
                    refreshToken: token.refreshToken,
                    apnsToken: credential.apnsToken,
                    apnsEnvironment: credential.apnsEnvironment
                ),
                for: host.id
            )
            return (configuration, token)
        }
        accessRefreshTask = task
        defer { accessRefreshTask = nil }
        return try await task.value
    }

    func disconnect() async {
        guard let host = connectedHost else { return }
        isDisconnecting = true
        if let credential = try? KeychainCredentialStore.load(for: host.id) {
            try? await MobileAuthenticationService.shared.disconnect(host: host, credential: credential)
        }
        KeychainCredentialStore.delete(for: host.id)
        await HostDataCleaner.clearData(for: host)
        defaults.removeObject(forKey: storageKey)
        connectedHost = nil
        webSessionBootstrap = nil
        transientAccessToken = nil
        transientConfiguration = nil
        accessRefreshTask?.cancel()
        accessRefreshTask = nil
        activity = []
        activityError = nil
        nextActivityBeforeID = nil
        webDestination = nil
        pushRegistrationError = nil
        pushRegistered = false
        defaults.removeObject(forKey: pushRegisteredKey)
        isDisconnecting = false
    }
}
