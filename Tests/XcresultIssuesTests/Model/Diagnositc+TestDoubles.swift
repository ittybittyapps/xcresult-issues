// Copyright 2023 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation
@testable import XcresultIssues

extension Diagnostic.Position {
    static let testStub = Self.init(line: 100, column: 0)
}

extension Diagnostic.Range {
    static let testStub = Self.init(start: .testStub)
}

extension Diagnostic.Location {
    static let testStub = Diagnostic.Location(path: "Test.swift", range: .testStub)
}
