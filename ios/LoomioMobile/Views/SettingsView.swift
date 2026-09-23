import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDisconnect = false

    var body: some View {
        NavigationStack {
            Form {
                if let host = connectionStore.connectedHost {
                    Section("Connected host") {
                        LabeledContent("Host", value: host.displayName)
                        LabeledContent("Secure connection", value: "HTTPS")
                    }
                }

                Section("Privacy") {
                    Text("Loomio login data stays in the isolated web container. This host can request the limited native actions shown in the app, but cannot access credentials or tokens.")
                }

                if let error = connectionStore.pushRegistrationError {
                    Section("Notifications") {
                        Text(error).foregroundStyle(.secondary)
                    }
                }

                if connectionStore.pushRegistered {
                    Section("Notifications") {
                        Button("Send test notification") {
                            Task { await connectionStore.sendTestPush() }
                        }
                        .disabled(connectionStore.isUpdatingPush)
                    }
                }

                Section {
                    Button("Disconnect", role: .destructive) { confirmDisconnect = true }
                        .disabled(connectionStore.isDisconnecting)
                        .accessibilityIdentifier("disconnectButton")
                } footer: {
                    Text("Disconnecting removes this host's stored session, website data, and notifications from this device.")
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
                        await connectionStore.disconnect()
                        dismiss()
                    }
                }
            }
        }
    }
}
