// Copyright 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation

struct GitHubActionsFormatStyle: FormatStyle {
    let pathsRelativeTo: String

    init(pathsRelativeTo: String?) {
        self.pathsRelativeTo = pathsRelativeTo ?? ""
    }

    /// Creates a `FormatOutput` instance from `value`.
    func format(_ value: Diagnostic) -> String {
        let severity: String
        switch value.severity {
        case .error:
            severity = "error"
        case .warning:
            severity = "warning"
        case .info:
            severity = "notice"
        default:
            severity = "debug"
        }

        let file = value.location.path.hasPrefix(pathsRelativeTo)
            ? value.location.path.dropFirst(pathsRelativeTo.count)
            : value.location.path.suffix(from: value.location.path.startIndex)
        let line = value.location.range.start.line
        let column = value.location.range.start.column

        return "::\(severity) file=\(file),line=\(line),col=\(column)::\(value.message)"
    }

    /// If the format allows selecting a locale, returns a copy of this format with the new locale set. Default implementation returns an unmodified self.
    func locale(_ locale: Locale) -> Self {
        self
    }
}

extension FormatStyle where Self == GitHubActionsFormatStyle {
    static func githubActions(pathsRelativeTo: String? = nil) -> Self {
        Self(pathsRelativeTo: pathsRelativeTo)
    }
}
