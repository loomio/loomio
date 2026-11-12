# Loomio Desktop

This client is in early development. It is not released, and its design may change.

A Qt 6 desktop client that connects to several Loomio hosts at once. Native code handles connecting to each host, signing in, the combined activity list, notifications and the Dock badge. Each host's Loomio web app runs in its own `WebEngineView` with an isolated profile, so cookies and storage never mix between hosts.

Sign-in follows the [mobile authentication protocol](../ios/docs/MOBILE_AUTH_PROTOCOL.md) with the desktop client registration (`org.loomio.desktop`, loopback callback). The app opens the host's sign-in page in the default browser and never sees the user's password. Refresh tokens are stored in the system keychain; access tokens stay in memory.

## Build

Requires Qt 6.8 or later with Qt WebEngine, and QtKeychain. On macOS with Homebrew:

```sh
brew install qt qtkeychain cmake ninja
cmake -S desktop -B desktop/build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build desktop/build
open desktop/build/Loomio.app
```

Run the protocol and parsing tests with `ctest --test-dir desktop/build --output-on-failure`.

## Developing against a local server

Debug builds accept plain HTTP for `localhost` and `127.0.0.1`. Release builds require HTTPS.

1. From the repository root, start Loomio with `bin/dev` and confirm that `http://localhost:8080` loads in a browser.
2. Open the Debug build, choose **Add a Loomio host**, and enter `http://localhost:8080`.
3. Choose **Continue in browser**, sign in, and approve the connection.

## Layout

- `src/pkce`, `src/hostorigin`, `src/hostconfig`, `src/loopbackcallback`: protocol helpers with no UI, covered by `tests/tst_core.cpp`.
- `src/loopbackauthorizer`: the one-shot loopback listener for the sign-in callback.
- `src/server`: one connected host: discovery, tokens, web-session bootstrap, activity.
- `src/serverlist`, `src/activityfeed`, `src/notifier`: app-wide models and notifications.
- `qml/`: the window, host rail, activity pane, host page and add-host page.
