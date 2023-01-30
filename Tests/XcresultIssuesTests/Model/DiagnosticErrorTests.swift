// Copyright 2023 Itty Bitty Apps Pty Ltd. See LICENSE file.

@testable import XcresultIssues
import XCTest

final class DiagnosticErrorTests: XCTestCase {

    func testIsError() throws {
        let rule = WarningsConfiguration.Rule(
            regex: #"^Main actor-isolated static property '(_previews|_platform)' cannot be used to satisfy nonisolated protocol requirement$"#,
            action: .error
        )

        let diagnostic = Diagnostic(
            message: "Main actor-isolated static property '_platform' cannot be used to satisfy nonisolated protocol requirement",
            location: .testStub,
            severity: .warning
        )

        XCTAssertTrue(diagnostic.isConsideredError(by: [try rule.matcher()]))
    }

    func testIsNotError() throws {
        let rule = WarningsConfiguration.Rule(
            regex: #"^Main actor-isolated static property '(_previews|_platform)' cannot be used to satisfy nonisolated protocol requirement$"#,
            action: .error
        )

        let diagnostic = Diagnostic(
            message: "Main actor-isolated static property 'something' cannot be used to satisfy nonisolated protocol requirement",
            location: .testStub,
            severity: .warning
        )

        XCTAssertFalse(diagnostic.isConsideredError(by: [try rule.matcher()]))
    }

}
