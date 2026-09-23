import SwiftUI
import UIKit
import WebKit

enum NativeBridgeAction: String, CaseIterable {
    case getCapabilities
    case openActivity
    case openSettings
    case requestPushAuthorization
    case sendTestPush
}

struct NativeBridgeResponse {
    let notificationAuthorization: String
    let pushRegistered: Bool

    var dictionary: [String: Any] {
        [
            "version": 1,
            "platform": "ios",
            "actions": NativeBridgeAction.allCases.map(\.rawValue),
            "notification_authorization": notificationAuthorization,
            "push_registered": pushRegistered
        ]
    }
}

private struct NativeBridgeActionKey: EnvironmentKey {
    static let defaultValue: @MainActor (NativeBridgeAction) async -> NativeBridgeResponse = { _ in
        NativeBridgeResponse(notificationAuthorization: "unknown", pushRegistered: false)
    }
}

extension EnvironmentValues {
    var nativeBridgeAction: @MainActor (NativeBridgeAction) async -> NativeBridgeResponse {
        get { self[NativeBridgeActionKey.self] }
        set { self[NativeBridgeActionKey.self] = newValue }
    }
}

struct LoomioWebView: View {
    @EnvironmentObject private var connectionStore: ConnectionStore
    @Environment(\.nativeBridgeAction) private var nativeBridgeAction
    @StateObject private var state = WebViewState()
    let notificationSignal: Int

    init(notificationSignal: Int = 0) {
        self.notificationSignal = notificationSignal
    }

    var body: some View {
        if let host = connectionStore.connectedHost {
            ZStack {
                WebContainer(
                    host: host,
                    bootstrap: connectionStore.webSessionBootstrap,
                    destination: connectionStore.webDestination,
                    notificationSignal: notificationSignal,
                    state: state,
                    didStartBootstrap: connectionStore.consumeWebSessionBootstrap,
                    didStartDestination: connectionStore.consumeWebDestination,
                    nativeBridgeAction: nativeBridgeAction
                )
                    .ignoresSafeArea(edges: .bottom)

                if let message = state.errorMessage {
                    ContentUnavailableView {
                        Label("Unable to open Loomio", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try Again") { state.reload() }
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                }
            }
        }
    }
}

@MainActor
private final class WebViewState: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    weak var webView: WKWebView?

    func reload() {
        errorMessage = nil
        webView?.reload()
    }

    func update(from webView: WKWebView) {
        isLoading = webView.isLoading
    }
}

private struct WebContainer: UIViewRepresentable {
    let host: ConnectedHost
    let bootstrap: WebSessionBootstrap?
    let destination: URL?
    let notificationSignal: Int
    @ObservedObject var state: WebViewState
    let didStartBootstrap: () -> Void
    let didStartDestination: () -> Void
    let nativeBridgeAction: @MainActor (NativeBridgeAction) async -> NativeBridgeResponse

    func makeCoordinator() -> Coordinator {
        Coordinator(host: host, state: state, nativeBridgeAction: nativeBridgeAction)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.isElementFullscreenEnabled = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        configuration.userContentController.addScriptMessageHandler(
            context.coordinator,
            contentWorld: .page,
            name: Coordinator.bridgeName
        )
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.keyboardDismissMode = .interactive
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.refresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        webView.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: "Back", target: context.coordinator, selector: #selector(Coordinator.accessibilityGoBack)),
            UIAccessibilityCustomAction(name: "Reload", target: context.coordinator, selector: #selector(Coordinator.accessibilityReload))
        ]
        state.webView = webView
        if let bootstrap {
            var request = URLRequest(url: bootstrap.endpoint)
            request.httpMethod = "POST"
            request.httpBody = formBody(ticket: bootstrap.ticket)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            webView.load(request)
            Task { @MainActor in didStartBootstrap() }
        } else {
            webView.load(URLRequest(url: host.origin))
        }
        return webView
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController.removeScriptMessageHandler(
            forName: Coordinator.bridgeName,
            contentWorld: .page
        )
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if bootstrap == nil, let destination {
            if webView.url != destination {
                webView.load(URLRequest(url: destination))
            }
            Task { @MainActor in didStartDestination() }
        }

        context.coordinator.deliverNotificationSignal(notificationSignal, to: webView)
    }

    private func formBody(ticket: String) -> Data? {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "ticket", value: ticket)]
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandlerWithReply {
        static let bridgeName = "loomioNative"
        private let policy: NavigationPolicy
        private let state: WebViewState
        private let nativeBridgeAction: @MainActor (NativeBridgeAction) async -> NativeBridgeResponse
        private var lastNotificationSignal = 0

        init(
            host: ConnectedHost,
            state: WebViewState,
            nativeBridgeAction: @escaping @MainActor (NativeBridgeAction) async -> NativeBridgeResponse
        ) {
            policy = NavigationPolicy(hostOrigin: host.origin)
            self.state = state
            self.nativeBridgeAction = nativeBridgeAction
        }

        func deliverNotificationSignal(_ signal: Int, to webView: WKWebView) {
            guard signal != lastNotificationSignal else { return }
            lastNotificationSignal = signal
            webView.evaluateJavaScript("window.dispatchEvent(new CustomEvent('loomio:native-notification'))")
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) async -> (Any?, String?) {
            guard message.name == Self.bridgeName,
                  message.frameInfo.isMainFrame,
                  let frameURL = message.frameInfo.request.url,
                  policy.decision(for: frameURL) == .allowInWebView else {
                return (nil, "Native bridge access denied")
            }
            guard let body = message.body as? [String: Any],
                  let version = body["version"] as? NSNumber,
                  version.intValue == 1,
                  let actionName = body["action"] as? String,
                  let action = NativeBridgeAction(rawValue: actionName) else {
                return (nil, "Unsupported native bridge request")
            }

            let response = await nativeBridgeAction(action)
            return (response.dictionary, nil)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation?) {
            state.errorMessage = nil
            state.update(from: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
            webView.scrollView.refreshControl?.endRefreshing()
            state.errorMessage = nil
            state.update(from: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation?, withError error: Error) {
            handleFailure(error, webView: webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: Error) {
            handleFailure(error, webView: webView)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            state.errorMessage = "The web content process stopped unexpectedly. Reload to continue."
            state.update(from: webView)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            switch policy.decision(for: url) {
            case .allowInWebView:
                decisionHandler(.allow)
            case .openExternally:
                decisionHandler(.cancel)
                if navigationAction.navigationType == .linkActivated,
                   navigationAction.targetFrame?.isMainFrame != false {
                    UIApplication.shared.open(url)
                }
            case .reject:
                decisionHandler(.cancel)
            }
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            guard navigationAction.targetFrame == nil,
                  let url = navigationAction.request.url else { return nil }
            switch policy.decision(for: url) {
            case .allowInWebView: webView.load(navigationAction.request)
            case .openExternally:
                if navigationAction.navigationType == .linkActivated {
                    UIApplication.shared.open(url)
                }
            case .reject: break
            }
            return nil
        }

        private func handleFailure(_ error: Error, webView: WKWebView) {
            webView.scrollView.refreshControl?.endRefreshing()
            let nsError = error as NSError
            guard nsError.code != NSURLErrorCancelled else { return }
            state.errorMessage = nsError.localizedDescription
            state.update(from: webView)
        }

        @objc func refresh(_ sender: UIRefreshControl) {
            guard let webView = state.webView else {
                sender.endRefreshing()
                return
            }
            state.errorMessage = nil
            webView.reload()
        }

        @objc func accessibilityGoBack() -> Bool {
            guard let webView = state.webView, webView.canGoBack else { return false }
            webView.goBack()
            return true
        }

        @objc func accessibilityReload() -> Bool {
            state.reload()
            return state.webView != nil
        }
    }
}
