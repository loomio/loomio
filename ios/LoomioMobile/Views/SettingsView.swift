import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @EnvironmentObject private var connection: HostConnection
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDisconnect = false

    var body: some View {
        NavigationStack {
            Form {
                let host = connection.host
                Group {
                    Section("Connected host") {
                        LabeledContent("Host", value: host.displayName)
                        LabeledContent("Secure connection", value: "HTTPS")
                    }
                }

                Section("Privacy") {
                    Text("Loomio login data stays in the isolated web container. This host can request the limited native actions shown in the app, but cannot access credentials or tokens.")
                }

                if let error = connection.pushRegistrationError {
                    Section("Notifications") {
                        Text(error).foregroundStyle(.secondary)
                    }
                }

                if connection.pushRegistered {
                    Section("Notifications") {
                        Button("Send test notification") {
                            Task { await connection.sendTestPush() }
                        }
                        .disabled(connection.isUpdatingPush)
                    }
                }

                Section {
                    Button("Disconnect", role: .destructive) { confirmDisconnect = true }
                        .disabled(connection.isDisconnecting)
                        .accessibilityIdentifier("disconnectButton")
                } footer: {
                    Text("Disconnecting removes this host's stored session, website data, and notifications from this device. Your other servers stay connected.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Disconnect from this Loomio host?",
                isPresented: $confirmDisconnect,
                titleVisibility: .visible
            ) {
                Button("Disconnect and remove data", role: .destructive) {
                    Task {
                        await connectionStore.disconnect(connection)
                        dismiss()
                    }
                }
            }
        }
    }
}
