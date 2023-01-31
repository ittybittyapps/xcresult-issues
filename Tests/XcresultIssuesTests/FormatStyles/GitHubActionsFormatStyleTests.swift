// Copyright 2023 Itty Bitty Apps Pty Ltd. See LICENSE file.

@testable import XcresultIssues
import XCTest

final class GitHubActionsFormatStyleTests: XCTestCase {

    func testFormatted() throws {
        let diagnostic = Diagnostic(message: "Message", location: .testStub, severity: .error)

        XCTAssertEqual(diagnostic.formatted(.githubActions()), "::error file=Test.swift,line=100,col=0::Message")
    }

    func testFormatted_NilLocation() throws {
        let diagnostic = Diagnostic(message: "Message", location: nil, severity: .error)

        XCTAssertEqual(diagnostic.formatted(.githubActions()), "::error::Message")
    }

}
