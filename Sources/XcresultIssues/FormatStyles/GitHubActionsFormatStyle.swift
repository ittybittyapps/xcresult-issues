// Copyright 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation

private struct GitHubActionsLocationFormatStyle: FormatStyle {
    let pathsRelativeTo: String

    init(pathsRelativeTo: String?) {
        self.pathsRelativeTo = pathsRelativeTo ?? ""
    }

    func format(_ value: Diagnostic.Location) -> String {
        let parameters: [(String, String)] = [
            ("file", value.file(relativeTo: pathsRelativeTo)),
            ("line", "\(value.line)"),
            ("endLine", "\(value.endLine.map { String($0) } ?? "")"),
            ("col", "\(value.column)"),
            ("endColumn", "\(value.endColumn.map { String($0) } ?? "")"),
        ].filter { _, value in
            value.isEmpty == false
        }

        return parameters.map { "\($0)=\($1)" }.joined(separator: ",")
    }
}

private extension FormatStyle where Self == GitHubActionsLocationFormatStyle {
    static func githubActions(pathsRelativeTo: String? = nil) -> Self {
        Self(pathsRelativeTo: pathsRelativeTo)
    }
}

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

        let formattedLocation = value.location?.formatted(.githubActions(pathsRelativeTo: pathsRelativeTo))
        return "::\([severity, formattedLocation].compactMap { $0 }.joined(separator: " "))::\(value.message)"
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
