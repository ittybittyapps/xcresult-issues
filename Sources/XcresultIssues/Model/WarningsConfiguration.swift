// Copyright 2023 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation
import os

struct WarningsConfiguration: Decodable {
    struct Rule: Decodable {
        enum Action: String, Decodable {
            case suppress
            case error
        }

        typealias Matcher = (String) -> Action?

        var regex: String
        var action: Action

        func matcher() throws -> Matcher {
            let r = try Regex(regex)
            return { (string: String) -> Action? in
                let matches = string.firstMatch(of: r)
                return matches.map { _ in action }
            }
        }
    }

    var rules: [Rule]
}

extension WarningsConfiguration {
    func ruleMatchers() throws -> [Rule.Matcher] {
        try rules.map({ try $0.matcher() })
    }
}

extension Diagnostic {
    func isSuppressed(by matchers: [WarningsConfiguration.Rule.Matcher]) -> Bool {
        matchers.contains(where: { $0(message) == .suppress })
    }

    func isConsideredError(by matchers: [WarningsConfiguration.Rule.Matcher]) -> Bool {
        matchers.contains(where: { $0(message) == .error })
    }
}
