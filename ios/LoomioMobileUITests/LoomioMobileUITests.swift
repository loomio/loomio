import XCTest

@MainActor
final class LoomioMobileUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
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
