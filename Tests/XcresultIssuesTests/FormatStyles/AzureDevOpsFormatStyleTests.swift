// Copyright 2023 Itty Bitty Apps Pty Ltd. See LICENSE file.

@testable import XcresultIssues
import XCTest

final class AzureDevOpsFormatStyleTests: XCTestCase {

    func testFormatted_Error() throws {
        let diagnostic = Diagnostic(message: "Message", location: .testStub, severity: .error)

        XCTAssertEqual(diagnostic.formatted(.azureDevOps()), "##vso[task.logissue type=error;sourcepath=Test.swift;linenumber=100;columnnumber=0;]Message")
    }

    func testFormatted_Warning() throws {
        let diagnostic = Diagnostic(message: "Message", location: .testStub, severity: .warning)

        XCTAssertEqual(diagnostic.formatted(.azureDevOps()), "##vso[task.logissue type=warning;sourcepath=Test.swift;linenumber=100;columnnumber=0;]Message")
    }

    func testFormatted_Info() throws {
        let diagnostic = Diagnostic(message: "Message", location: .testStub, severity: .info)

        XCTAssertEqual(diagnostic.formatted(.azureDevOps()), "##[debug]Test.swift:100:0: Message")
    }

    func testFormatted_Info_NilLocation() throws {
        let diagnostic = Diagnostic(message: "Message", location: nil, severity: .info)

        XCTAssertEqual(diagnostic.formatted(.azureDevOps()), "##[debug]Message")
    }


    func testFormatted_NilLocation() throws {
        let diagnostic = Diagnostic(message: "Message", location: nil, severity: .error)

        XCTAssertEqual(diagnostic.formatted(.azureDevOps()), "##vso[task.logissue type=error;]Message")
    }

}
