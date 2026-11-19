import SwiftUI

struct AppShellView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @EnvironmentObject private var pushNotifications: PushNotificationManager
    @State private var settingsConnection: HostConnection?

    var body: some View {
        ZStack {
            // Keep each WebView's navigation and editing state while switching servers.
            ForEach(connectionStore.connections) { connection in
                LoomioWebView(notificationSignal: pushNotifications.notificationSignal(for: connection.registrationID))
                    .environmentObject(connection)
                    .environment(\.nativeBridgeAction) { action in
                        await handleNativeBridgeAction(action, connection: connection)
                    }
                    .opacity(connectionStore.selectedHostID == connection.id ? 1 : 0)
                    .allowsHitTesting(connectionStore.selectedHostID == connection.id)
                    .accessibilityHidden(connectionStore.selectedHostID != connection.id)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Menu {
                    ForEach(connectionStore.connections) { connection in
                        Button {
                            connectionStore.select(connection)
                        } label: {
                            Label(connection.host.displayName, systemImage: connectionStore.selectedHostID == connection.id ? "checkmark" : "globe")
                        }
                        .accessibilityIdentifier("selectServer-\(connection.id.uuidString)")
                    }
                    Divider()
                    Button("Add a Loomio server", systemImage: "plus") { connectionStore.addHostPresented = true }
                } label: {
                    Label(connectionStore.connectedHost?.displayName ?? "Loomio servers", systemImage: "server.rack")
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                }
                .accessibilityIdentifier("serverSwitcher")
                Spacer()
                Button("Activity", systemImage: "bell") { connectionStore.activityPresented = true }
                    .labelStyle(.iconOnly)
                    .accessibilityIdentifier("combinedActivityButton")
                Button("Settings", systemImage: "gearshape") { settingsConnection = connectionStore.selectedConnection }
                    .labelStyle(.iconOnly)
                    .accessibilityIdentifier("mobileSettingsButton")
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)
        }
        .onChange(of: pushNotifications.activationCount) { _, _ in
            settingsConnection = nil
        }
        .sheet(item: $settingsConnection) { connection in
            SettingsView().environmentObject(connection)
        }
        .sheet(isPresented: $connectionStore.activityPresented) {
            CombinedActivityView()
        }
    }

    private func handleNativeBridgeAction(_ action: NativeBridgeAction, connection: HostConnection) async -> NativeBridgeResponse {
        // A page's bridge always addresses its own connection, including across awaits.
        if connectionStore.selectedConnection === connection {
            switch action {
            case .getCapabilities:
                break
            case .openActivity:
                connectionStore.activityPresented = true
            case .openSettings:
                settingsConnection = connection
            case .requestPushAuthorization:
                await pushNotifications.activate()
                if let token = pushNotifications.deviceToken {
                    await connectionStore.registerPushIfPossible(apnsToken: token, environment: pushNotifications.apnsEnvironment)
                }
            case .sendTestPush:
                await connection.sendTestPush()
            }
        }
        return NativeBridgeResponse(
            notificationAuthorization: pushNotifications.authorizationStatus.bridgeValue,
            pushRegistered: connection.pushRegistered
        )
    }
}

private struct CombinedActivityView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(connectionStore.connections) { connection in
                    if let error = connection.activityError {
                        Section(connection.host.displayName) {
                            Text(error).foregroundStyle(.secondary)
                        }
                    }
                }
                ForEach(connectionStore.combinedActivity) { entry in
                    Button {
                        connectionStore.openActivity(entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(entry.activity.displayTitle)
                                    .fontWeight(entry.activity.viewed ? .regular : .semibold)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(entry.activity.createdAt, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.connection.host.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let actor = entry.activity.actorName {
                                Text(actor).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                if connectionStore.connections.contains(where: \.isLoadingActivity) {
                    ProgressView().frame(maxWidth: .infinity)
                } else if connectionStore.connections.contains(where: \.canLoadMoreActivity) {
                    Button("Load more activity") { Task { await connectionStore.loadActivity(reset: false) } }
                } else if connectionStore.combinedActivity.isEmpty {
                    Text("No recent activity").foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
            .refreshable { await connectionStore.loadActivity() }
            .task { await connectionStore.loadActivity() }
        }
    }
}
