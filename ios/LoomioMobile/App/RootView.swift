import SwiftUI

struct RootView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @EnvironmentObject private var pushNotifications: PushNotificationManager

    var body: some View {
        Group {
            if connectionStore.connectedHost == nil {
                ConnectHostView()
            } else {
                AppShellView()
            }
        }
        .onOpenURL { connectionStore.handleIncomingURL($0) }
        .task(id: connectionStore.connections.map(\.id)) {
            guard connectionStore.connectedHost != nil else { return }
            await pushNotifications.activate()
            if let token = pushNotifications.deviceToken {
                await connectionStore.registerPushIfPossible(
                    apnsToken: token,
                    environment: pushNotifications.apnsEnvironment
                )
            }
        }
        .onChange(of: pushNotifications.deviceToken) { _, token in
            guard let token else { return }
            Task {
                await connectionStore.registerPushIfPossible(
                    apnsToken: token,
                    environment: pushNotifications.apnsEnvironment
                )
            }
        }
        .onChange(of: pushNotifications.activationCount, initial: true) { _, count in
            guard count > 0 else { return }
            connectionStore.openNotification(registrationID: pushNotifications.activatedRegistrationID)
        }
        .sheet(isPresented: Binding(
            get: { connectionStore.addHostPresented || connectionStore.connectionProposal != nil },
            set: { if !$0 { connectionStore.cancelConnectionProposal(); connectionStore.addHostPresented = false } }
        )) {
            Group {
                if let proposal = connectionStore.connectionProposal {
                    ConnectionProposalView(proposal: proposal)
                } else {
                    ConnectHostView()
                }
            }
            .interactiveDismissDisabled(connectionStore.isConnecting)
        }
        .alert(
            "Unable to open connection link",
            isPresented: Binding(
                get: { connectionStore.connectionProposal == nil && connectionStore.connectionError != nil },
                set: { if !$0 { connectionStore.connectionError = nil } }
            )
        ) {
            Button("OK") { connectionStore.connectionError = nil }
        } message: {
            Text(connectionStore.connectionError ?? "Unknown error")
        }
    }
}
