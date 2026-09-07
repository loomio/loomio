import SwiftUI

@main
struct LoomioMobileApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var connectionStore = ConnectionStore()
    @StateObject private var pushNotifications = PushNotificationManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(connectionStore)
                .environmentObject(pushNotifications)
        }
    }
}
