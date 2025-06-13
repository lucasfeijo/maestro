import XCTest
@testable import maestro

final class ArgumentParserTests: XCTestCase {
    func testNoNotifyFlagDisablesNotifications() {
        let opts = parseArguments(["maestro", "--no-notify"]) 
        XCTAssertFalse(opts.notificationsEnabled)
    }

    func testNotificationsEnabledByDefault() {
        let opts = parseArguments(["maestro"]) 
        XCTAssertTrue(opts.notificationsEnabled)
    }
}
