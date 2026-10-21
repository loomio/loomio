import XCTest

@MainActor
final class LoomioMobileUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDefaultHostsRequireConfirmationBeforeConnecting() {
        let app = XCUIApplication()
        app.launchArguments = ["-connectedHost", ""]
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

    func testRejectsInsecureHost() {
        let app = XCUIApplication()
        app.launchArguments = ["-connectedHost", ""]
        app.launch()

        let field = app.textFields["hostAddress"]
        field.tap()
        field.typeText("http://example.org")
        app.buttons["connectButton"].tap()

        XCTAssertTrue(app.staticTexts["Loomio hosts must use HTTPS."].waitForExistence(timeout: 2))
    }
}
