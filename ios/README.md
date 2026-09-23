# Loomio Mobile

A native SwiftUI companion for a user-selected Loomio host. The existing Loomio web application runs in an isolated `WKWebView`; native code provides connection, activity, notification, privacy, and device controls.

## Development

Open `LoomioMobile.xcodeproj` in Xcode 26.2 or later. Project identity and deployment settings live in `Config/App.xcconfig`.

To run the app against the current local Rails and Vue source:

1. From the repository root, start Loomio with `bin/dev` and confirm that `http://localhost:8080` loads in a browser.
2. Run the `LoomioMobile` scheme using its Debug configuration in an iOS Simulator.
3. On the connection screen, tap **Use local development server**, then continue through the normal system-browser authorization flow using a user from the local development database.

The Debug build permits only the exact HTTP origin `http://localhost:8080`. Release builds continue to require HTTPS. A physical iPhone cannot use this loopback address; phone testing should use an HTTPS development host or tunnel whose certificate iOS trusts.

Run the current unit and UI suite with an installed iOS 26 simulator:

```sh
xcodebuild -project LoomioMobile.xcodeproj -scheme LoomioMobile -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

The current implementation includes strict HTTPS host validation, `loomio://` connection links, system-browser PKCE authentication, Keychain credential storage, one-time WebView session bootstrap, selected-host persistence, same-origin web navigation, external-link routing, native recent activity, host-scoped disconnect cleanup, APNs registration, a generic notification payload, and a versioned web-to-native action bridge.

The implementation contract for system-browser login, native device credentials, and safe WebView session bootstrapping is in [`docs/MOBILE_AUTH_PROTOCOL.md`](docs/MOBILE_AUTH_PROTOCOL.md).

The relay protocol and deployment boundary are documented in [`docs/PUSH_RELAY_PROTOCOL.md`](docs/PUSH_RELAY_PROTOCOL.md). The service itself is under [`../push-relay/`](../push-relay/).
