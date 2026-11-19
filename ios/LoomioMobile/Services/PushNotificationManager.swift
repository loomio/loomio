import UIKit
import UserNotifications

@MainActor
final class PushNotificationManager: ObservableObject {
    static let shared = PushNotificationManager()

    @Published private(set) var deviceToken: String?
    @Published private(set) var authorizationStatus = UNAuthorizationStatus.notDetermined
    @Published private(set) var activatedRegistrationID: UUID?
    @Published private(set) var activationCount = 0
    @Published private(set) var deliveryCount = 0
    @Published private var registrationSignals: [UUID: Int] = [:]

    func notificationSignal(for registrationID: UUID?) -> Int {
        guard let registrationID else { return 0 }
        return registrationSignals[registrationID, default: 0]
    }

    private func recordSignal(registrationID: String?) {
        guard let value = registrationID, let id = UUID(uuidString: value) else { return }
        registrationSignals[id, default: 0] += 1
    }

    var apnsEnvironment: String {
        #if DEBUG
        "sandbox"
        #else
        "production"
        #endif
    }

    func activate() async {
        let center = UNUserNotificationCenter.current()
        authorizationStatus = await center.notificationSettings().authorizationStatus
        if authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            authorizationStatus = await center.notificationSettings().authorizationStatus
        }
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else { return }
        UIApplication.shared.registerForRemoteNotifications()
    }

    func received(deviceToken data: Data) {
        deviceToken = data.map { String(format: "%02x", $0) }.joined()
    }

    func receivedNotificationResponse(registrationID: String?) {
        activatedRegistrationID = registrationID.flatMap(UUID.init(uuidString:))
        recordSignal(registrationID: registrationID)
        activationCount += 1
    }

    func receivedNotification(registrationID: String?) {
        recordSignal(registrationID: registrationID)
        deliveryCount += 1
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Task { @MainActor in PushNotificationManager.shared.received(deviceToken: deviceToken) }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let registrationID = notification.request.content.userInfo["registration_id"] as? String
        await MainActor.run { PushNotificationManager.shared.receivedNotification(registrationID: registrationID) }
        return [.banner, .badge, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let registrationID = response.notification.request.content.userInfo["registration_id"] as? String
        await MainActor.run { PushNotificationManager.shared.receivedNotificationResponse(registrationID: registrationID) }
    }
}

extension UNAuthorizationStatus {
    var bridgeValue: String {
        switch self {
        case .notDetermined: "not_determined"
        case .denied: "denied"
        case .authorized: "authorized"
        case .provisional: "provisional"
        case .ephemeral: "ephemeral"
        @unknown default: "unknown"
        }
    }
}
