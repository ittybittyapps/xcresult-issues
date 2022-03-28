// Copyright © 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation

struct DiagnosticResult: Codable, Hashable {
    var diagnostics: [Diagnostic]
}

struct Diagnostic: Codable, Hashable {
    struct Position: Codable, Hashable {
        var line: Int
        var column: Int
    }

    struct Range: Codable, Hashable {
        var start: Position
        var end: Position?
    }

    struct Location: Codable, Hashable {
        var path: String
        var range: Range
    }

    enum Severity: String, Codable, Hashable {
        case unknown = "UNKNOWN_SEVERITY"
        case error = "ERROR"
        case info = "INFO"
        case warning = "WARNING"
    }

    var message: String
    var location: Location
    var severity: Severity
}
