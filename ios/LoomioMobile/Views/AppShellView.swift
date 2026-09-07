import SwiftUI

struct AppShellView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @EnvironmentObject private var pushNotifications: PushNotificationManager
    @State private var settingsPresented = false

    var body: some View {
        LoomioWebView(notificationSignal: pushNotifications.deliveryCount + pushNotifications.activationCount)
            .environment(\.nativeBridgeAction) { action in
                await handleNativeBridgeAction(action)
            }
            .sheet(isPresented: $settingsPresented) {
                SettingsView()
            }
            .onChange(of: pushNotifications.activationCount) { _, _ in
                connectionStore.openNotifications()
            }
    }

    private func handleNativeBridgeAction(_ action: NativeBridgeAction) async -> NativeBridgeResponse {
        switch action {
        case .getCapabilities:
            break
        case .openActivity:
            connectionStore.openNotifications()
        case .openSettings:
            settingsPresented = true
        case .requestPushAuthorization:
            await pushNotifications.activate()
            if let token = pushNotifications.deviceToken {
                await connectionStore.registerPushIfPossible(
                    apnsToken: token,
                    environment: pushNotifications.apnsEnvironment
                )
            }
        case .sendTestPush:
            await connectionStore.sendTestPush()
        }

        return NativeBridgeResponse(
            notificationAuthorization: pushNotifications.authorizationStatus.bridgeValue,
            pushRegistered: connectionStore.pushRegistered
        )
    }
}
