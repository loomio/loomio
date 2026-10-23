# Loomio for iOS

A native SwiftUI companion for a user-selected Loomio host. The existing Loomio web application runs in an isolated `WKWebView`; native code provides connection, activity, notification, privacy, and device controls.

The connection screen offers **loomio.com**, **loomio.eu**, and **loomio.nz**, plus a custom host address. Each choice shows the exact HTTPS origin for confirmation before sign-in; loomio.com connects to its application origin, `https://www.loomio.com`.

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

## TestFlight

The name shown on the phone is **Loomio**, bundle ID `org.loomio.mobile`, version `0.1.0`, build `1`. The App Store Connect record is temporarily named **Loomio Mobile** while Apple investigates availability of the **Loomio** listing name. Use the existing [app record 6823402785](https://appstoreconnect.apple.com/apps/6823402785) for uploads under the **Loomio Limited** team (`ZGWX579DKV`); changing the listing name does not require a new record or bundle ID. `APP_DISPLAY_NAME` in `Config/App.xcconfig` sets the phone's display name; the internal product and project names remain unchanged. The app requires iOS 26 or later. The shared `LoomioMobile` scheme archives using the Release configuration, which requires HTTPS hosts and uses the production APNs environment.

### Apple account setup

1. Add the Apple Account with access to Loomio's paid developer team in **Xcode → Settings → Accounts**. Complete sign-in and two-factor authentication in Xcode.
2. Open `LoomioMobile.xcodeproj`, select the **LoomioMobile** app target, and choose the Loomio team under **Signing & Capabilities** with automatic signing enabled. Register the explicit bundle ID `org.loomio.mobile` on that team and enable its **Push Notifications** capability. The project already includes the APNs entitlement.
3. In [App Store Connect](https://appstoreconnect.apple.com/), use the existing **Loomio Mobile** iOS app record with **English (U.S.)** as its primary language, bundle ID `org.loomio.mobile`, and SKU `loomio-mobile`. Its public developer name is **Loomio Limited**. The account holder must accept any outstanding Apple Developer agreements before uploading.

Keep this bundle ID for subsequent builds; it also identifies the APNs topic. The mobile OAuth client ID `org.loomio.mobile.ios` and callback URL `org.loomio.mobile:/oauth/callback` are separate protocol values and must continue to match the Loomio server.

### Build and upload

1. Run the unit and UI tests with an available iOS 26 or later simulator. Use `xcrun simctl list devices available` to find its name or identifier and pass that destination to the test command above.
2. Select **Any iOS Device (arm64)** in Xcode and choose **Product → Archive**. To archive from the repository root instead, substitute Loomio's Team ID in this command:

   ```sh
   xcodebuild -project ios/LoomioMobile.xcodeproj -scheme LoomioMobile -configuration Release -destination 'generic/platform=iOS' -archivePath tmp/ios-testflight/LoomioMobile.xcarchive -allowProvisioningUpdates DEVELOPMENT_TEAM=YOUR_TEAM_ID archive
   ```

3. Open the archive in Xcode's Organizer, choose **Distribute App → App Store Connect**, and upload it. A command-line archive under `tmp/` can be opened in Xcode by opening the `.xcarchive` in Finder. Use App Store Connect distribution if the build may later be offered to external testers; **TestFlight Internal Only** restricts it to the team's internal testers.
4. After Apple processes the build, open the app's **TestFlight** tab, complete its export-compliance questions, and add the build to an internal testing group. App Store release is a separate submission. External testing also requires beta test information and Apple's beta review.
5. Increase `CURRENT_PROJECT_VERSION` in `Config/App.xcconfig` before the next upload. Keep certificates, provisioning profiles, APNs keys, and Apple account credentials out of Git.

The icon source is [`Artwork/AppIcon.svg`](Artwork/AppIcon.svg), using the existing Loomio mark. Regenerate its opaque 1024-pixel PNG after editing the vector:

```sh
rsvg-convert --output ios/LoomioMobile/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png ios/Artwork/AppIcon.svg
```

TestFlight installation does not configure the push relay. Push testing also needs a deployed relay with an APNs key for the same Apple team and `org.loomio.mobile` topic, plus relay configuration on the connected Loomio host. Use the production APNs environment for TestFlight builds; the Debug simulator's local development server shortcut is absent from Release builds.

### Push notification setup

1. In Apple Developer's **Certificates, Identifiers & Profiles → Keys**, create separate **Production** and **Sandbox** APNs signing keys for team `ZGWX579DKV`. Prefer topic-specific keys restricted to `org.loomio.mobile`. Record each Key ID and store its downloaded `.p8` file securely. Apple's related-key feature rotates a key within the same environment; it does not replace the separate key for the other environment.
2. Deploy the [push relay stack](../push-relay/deploy/README.md), verify HTTPS and request limits, and arrange private backups for the database and encryption/signing keys. Configure `PUSH_RELAY_URL` on each participating Loomio host only after the relay is ready.
3. Connect the app, allow notifications, and send a test from native Settings. Verify a background notification and its tap destination. Repeat with a Debug installation (Sandbox) and TestFlight (Production), and on each supported Loomio host.

The host defaults and environment-specific relay key support are implemented and tested. Production relay deployment, Apple key provisioning, and physical-device delivery verification remain pending.

Apple's [app record instructions](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/), [build upload guide](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/), and [internal testing guide](https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/) describe the account-side steps.
