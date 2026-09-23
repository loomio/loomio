import SwiftUI

struct ConnectHostView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @State private var hostAddress = ""
    @State private var errorMessage: String?
    @FocusState private var addressFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("https://community.example.org", text: $hostAddress)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($addressFocused)
                        .accessibilityIdentifier("hostAddress")
                } header: {
                    Text("Loomio host")
                } footer: {
                    Text("Connect to the secure address supplied by your Loomio administrator.")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }

                Button("Connect") { connect() }
                    .frame(maxWidth: .infinity)
                    .disabled(hostAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("connectButton")

#if DEBUG
                Button("Use local development server") {
                    hostAddress = "http://localhost:8080"
                    connect()
                }
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("localDevelopmentButton")
#endif
            }
            .navigationTitle("Connect to Loomio")
            .onAppear { addressFocused = true }
        }
    }

    private func connect() {
        do {
            try connectionStore.proposeConnection(to: hostAddress)
            errorMessage = nil
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

struct ConnectionProposalView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    let proposal: ConnectionProposal

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)

                VStack(spacing: 8) {
                    Text("Connect to this Loomio host?")
                        .font(.title2.bold())
                    Text(proposal.origin.absoluteString)
                        .font(.body.monospaced())
                        .multilineTextAlignment(.center)
                    Text(proposal.origin.scheme == "https"
                        ? "The app will verify this host and then open a secure system browser for sign-in."
                        : "The app will verify this local development server and then open the system browser for sign-in.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let error = connectionStore.connectionError {
                    Text(error)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("connectionError")
                }

                Button {
                    Task { await connectionStore.confirmConnection() }
                } label: {
                    if connectionStore.isConnecting {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Continue to Sign In").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(connectionStore.isConnecting)
                .accessibilityIdentifier("confirmConnectionButton")

                Spacer()
            }
            .padding()
            .navigationTitle("Loomio Mobile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { connectionStore.cancelConnectionProposal() }
                        .disabled(connectionStore.isConnecting)
                }
            }
        }
    }
}
