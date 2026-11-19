import XCTest

@MainActor
final class LoomioMobileUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDefaultHostsRequireConfirmationBeforeConnecting() {
        let app = XCUIApplication()
        app.launchArguments = ["-connectedHost", "", "-connectedServers", ""]
        app.launch()

        for (name, origin) in [
            ("loomio.com", "https://www.loomio.com"),
            ("loomio.eu", "https://loomio.eu"),
            ("loomio.nz", "https://loomio.nz")
        ] {
            app.buttons["hostPreset-\(name)"].tap()
            XCTAssertTrue(app.staticTexts[origin].waitForExistence(timeout: 2))
            XCTAssertTrue(app.buttons["confirmConnectionButton"].exists)
            app.buttons["Cancel"].tap()
        }

        XCTAssertTrue(app.textFields["hostAddress"].exists)
    }

    func testSwitchingAndDisconnectingKeepsTheOtherServerConnected() throws {
        let firstID = "61787943-CFBB-4F14-A203-56C344A15451"
        let secondID = "4A8ED2F7-6EF9-4881-AE7F-18453EECE91B"
        let state: [String: Any] = [
            "hosts": [
                ["id": firstID, "origin": "https://one.example.invalid", "usesLegacyDataStore": false],
                ["id": secondID, "origin": "https://two.example.invalid", "usesLegacyDataStore": false]
            ],
            "selectedHostID": secondID
        ]
        addUIInterruptionMonitor(withDescription: "Notification permission") { alert in
            if alert.buttons["Don’t Allow"].exists { alert.buttons["Don’t Allow"].tap(); return true }
            if alert.buttons["Don't Allow"].exists { alert.buttons["Don't Allow"].tap(); return true }
            return false
        }
        let data = try JSONSerialization.data(withJSONObject: state)
        let app = XCUIApplication()
        app.launchArguments = ["-connectedServers", String(decoding: data, as: UTF8.self)]
        app.launch()
        let switcher = app.buttons["serverSwitcher"]
        XCTAssertTrue(switcher.waitForExistence(timeout: 5), app.debugDescription)
        switcher.tap()
        app.buttons["selectServer-\(firstID)"].tap()
        app.buttons["combinedActivityButton"].tap()
        XCTAssertTrue(app.navigationBars["Activity"].waitForExistence(timeout: 3))
        app.buttons["Done"].tap()
        switcher.tap()
        app.buttons["Add a Loomio server"].tap()
        XCTAssertTrue(app.navigationBars["Connect to Loomio"].waitForExistence(timeout: 3))
        app.buttons["hostPreset-loomio.eu"].tap()
        XCTAssertTrue(app.buttons["confirmConnectionButton"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Connect to Loomio"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()
        app.buttons["mobileSettingsButton"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
        app.buttons["disconnectButton"].tap()
        app.buttons["Disconnect and remove data"].tap()
        XCTAssertTrue(switcher.waitForExistence(timeout: 5), app.debugDescription)
        switcher.tap()
        XCTAssertFalse(app.buttons["selectServer-\(firstID)"].exists)
        XCTAssertTrue(app.buttons["selectServer-\(secondID)"].exists)
        app.buttons["selectServer-\(secondID)"].tap()
        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(switcher.waitForExistence(timeout: 5), app.debugDescription)
        switcher.tap()
        XCTAssertFalse(app.buttons["selectServer-\(firstID)"].exists)
        XCTAssertTrue(app.buttons["selectServer-\(secondID)"].exists)
    }

    func testRejectsInsecureHost() {
        let app = XCUIApplication()
        app.launchArguments = ["-connectedHost", "", "-connectedServers", ""]
        app.launch()

        let field = app.textFields["hostAddress"]
        field.tap()
        field.typeText("http://example.org")
        app.buttons["connectButton"].tap()

        XCTAssertTrue(app.staticTexts["Loomio hosts must use HTTPS."].waitForExistence(timeout: 2))
    }
}
