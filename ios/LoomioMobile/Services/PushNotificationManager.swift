import UIKit
import UserNotifications

@MainActor
final class PushNotificationManager: ObservableObject {
    static let shared = PushNotificationManager()

    @Published private(set) var deviceToken: String?
    @Published private(set) var authorizationStatus = UNAuthorizationStatus.notDetermined
    @Published private(set) var activationCount = 0
    @Published private(set) var deliveryCount = 0

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

    func receivedNotificationResponse() {
        activationCount += 1
    }

    func receivedNotification() {
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
        await MainActor.run { PushNotificationManager.shared.receivedNotification() }
        return [.banner, .badge, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run { PushNotificationManager.shared.receivedNotificationResponse() }
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
