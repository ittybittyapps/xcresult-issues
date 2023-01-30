// Copyright 2023 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation

private struct VSOLogIssueFormatStyle: FormatStyle {
    let pathsRelativeTo: String

    init(pathsRelativeTo: String?) {
        self.pathsRelativeTo = pathsRelativeTo ?? ""
    }

    func format(_ value: Diagnostic.Location) -> String {
        let parameters: [(String, String)] = [
            ("sourcepath", value.file(relativeTo: pathsRelativeTo)),
            ("linenumber", "\(value.line)"),
            ("columnnumber", "\(value.column)"),
        ]

        return parameters.map { "\($0)=\($1);" }.joined()
    }
}

private extension FormatStyle where Self == VSOLogIssueFormatStyle {
    static func vsoLogIssue(pathsRelativeTo: String? = nil) -> Self {
        Self(pathsRelativeTo: pathsRelativeTo)
    }
}

private struct VSODebugFormatStyle: FormatStyle {
    let pathsRelativeTo: String

    init(pathsRelativeTo: String?) {
        self.pathsRelativeTo = pathsRelativeTo ?? ""
    }

    func format(_ value: Diagnostic.Location) -> String {
        return "\(value.file(relativeTo: pathsRelativeTo)):\(value.line):\(value.column): "
    }
}

private extension FormatStyle where Self == VSODebugFormatStyle {
    static func vsoDebug(pathsRelativeTo: String? = nil) -> Self {
        Self(pathsRelativeTo: pathsRelativeTo)
    }
}

struct AzureDevOpsFormatStyle: FormatStyle {
    let pathsRelativeTo: String

    init(pathsRelativeTo: String?) {
        self.pathsRelativeTo = pathsRelativeTo ?? ""
    }

    /// Creates a `FormatOutput` instance from `value`.
    func format(_ value: Diagnostic) -> String {
        switch value.severity {
        case .error:
            return logIssue(severity: "error", location: value.location, message: value.message)
        case .warning:
            return logIssue(severity: "warning", location: value.location, message: value.message)
        default:
            let formattedLocation = value.location?.formatted(.vsoDebug(pathsRelativeTo: pathsRelativeTo)) ?? ""
            return "##[debug]\(formattedLocation)\(value.message)"
        }
    }

    func logIssue(severity: String, location: Diagnostic.Location?, message: String) -> String {
        let formattedLocation = location?.formatted(.vsoLogIssue(pathsRelativeTo: pathsRelativeTo)) ?? ""
        return "##vso[task.logissue type=\(severity);\(formattedLocation)]\(message)"
    }

    /// If the format allows selecting a locale, returns a copy of this format with the new locale set. Default implementation returns an unmodified self.
    func locale(_ locale: Locale) -> Self {
        self
    }
}

extension FormatStyle where Self == AzureDevOpsFormatStyle {
    static func azureDevOps(pathsRelativeTo: String? = nil) -> Self {
        Self(pathsRelativeTo: pathsRelativeTo)
    }
}

extension Diagnostic.Location {
    func file(relativeTo: String) -> String {
        String(path.hasPrefix(relativeTo) ? path.dropFirst(relativeTo.count) : path.suffix(from: path.startIndex))
    }

    var line: Int {
        range.start.line
    }

    var endLine: Int? {
        range.end?.line
    }

    var column: Int {
        range.start.column
    }

    var endColumn: Int? {
        range.end?.column
    }
}
