// Copyright 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Algorithms
import ArgumentParser
import Foundation
import Yams

public struct XcresultIssues: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "xcresult-issues",
        abstract: "A utility for reporting issues found in xcresult bundles."
    )

    @Argument(help: "The path of the xcresult JSON file to process. If omitted, stdin is used instead.")
    var input: String?

    enum Format: String, Decodable, ExpressibleByArgument {
        case reviewdogJSON = "reviewdog-json"
        case githubActions = "github-actions-logging"
        case azureDevOps = "azure-devops-logging"
    }

    @Option(
        name: [.long, .short],
        help: "The format to write issues out with.")
    var format: Format = .githubActions

    @Option(
        name: [.long, .short],
        help: "Make reported paths relative to the given path."
    )
    var pathsRelativeTo: String?

    @Option(
        name: [.long, .short],
        help: "A path to a YAML configuration for warnings."
    )
    var warningsConfig: String?

    public init() {
    }

    public func run() throws {
        let warningsConfiguration = try loadWarningsConfiguration(path: warningsConfig)

        let outputFileHandle = FileHandle.standardOutput

        let fileHandle = input.flatMap(FileHandle.init(forReadingAtPath:)) ?? .standardInput

        guard let fileData = try fileHandle.readToEnd() else {
            return // TODO: throw an error?
        }

        let invocationRecord = try JSONDecoder().decode(ActionsInvocationRecord.self, from: fileData)
        var errorDiagnostics = invocationRecord.issues.errorSummaries?.values.compactMap {
            Diagnostic(issueSummary: $0, severity: .error)
        } ?? []

        var warningDiagnostics = invocationRecord.issues.warningSummaries?.values.compactMap {
            Diagnostic(issueSummary: $0, severity: .warning)
        } ?? []

        if let warningsMatchers = try warningsConfiguration?.ruleMatchers() {
            warningDiagnostics.removeAll { $0.isSuppressed(by: warningsMatchers) }

            let warningsAsErrors = warningDiagnostics
                .filter { $0.isConsideredError(by: warningsMatchers) }
                .map { $0.asError() }

            errorDiagnostics.append(contentsOf: warningsAsErrors)

            warningDiagnostics.removeAll { $0.isConsideredError(by: warningsMatchers) }
        }

        let allDiagnostics = chain(errorDiagnostics, warningDiagnostics)

        switch format {
        case .reviewdogJSON:
            let result = DiagnosticResult(diagnostics: Array(allDiagnostics))
            let jsonData = try JSONEncoder().encode(result)
            try outputFileHandle.write(contentsOf: jsonData)

        case .githubActions:
            var outputstream = FileHandleOutputStream(outputFileHandle)
            for diagnostic in allDiagnostics {
                print(diagnostic.formatted(.githubActions(pathsRelativeTo: pathsRelativeTo)), to: &outputstream)
            }
        case .azureDevOps:
            var outputstream = FileHandleOutputStream(outputFileHandle)
            for diagnostic in allDiagnostics {
                print(diagnostic.formatted(.azureDevOps(pathsRelativeTo: pathsRelativeTo)), to: &outputstream)
            }
        }
    }

    private func loadWarningsConfiguration(path: String?) throws -> WarningsConfiguration? {
        guard let warningsConfiguration = path else {
            return nil
        }

        let url = URL(fileURLWithPath: warningsConfiguration)
        let data = try Data(contentsOf: url)
        let decoder = YAMLDecoder()

        return try decoder.decode(WarningsConfiguration.self, from: data)
    }
}

extension Diagnostic {
    init?(issueSummary: IssueSummary, severity: Severity) {
        self.init(
            message: issueSummary.message.value,
            location: .init(issueSummary.documentLocationInCreatingWorkspace),
            severity: severity
        )
    }

    func asError() -> Self {
        var copy = self
        copy.severity = .error
        return copy
    }
}

extension Diagnostic.Location {
    init?(_ value: DocumentLocation?) {
        guard let documentLocation = value, let startingLineNumber = documentLocation.startingLineNumber, let startingColumnNumber = documentLocation.startingColumnNumber else {
            return nil
        }

        // `DocumentLocation` uses zero-indexed line/column numbers, while rdjson uses 1-indexed line/column numbers.
        // Add 1 to each of the line/column numbers here to account for this.
        let endPosition: Diagnostic.Position?
        if let endingLineNumber = documentLocation.endingLineNumber,
           let endingColumnNumber = documentLocation.endingColumnNumber {
            endPosition = .init(
                line: endingLineNumber + 1,
                column: endingColumnNumber + 1
            )
        } else {
            endPosition = nil
        }

        self.init(
            path: documentLocation.path,
            range: .init(
                start: .init(
                    line: startingLineNumber + 1,
                    column: startingColumnNumber + 1
                ),
                end: endPosition
            )
        )
    }
}
