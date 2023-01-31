// Copyright 2022 Itty Bitty Apps Pty Ltd. See LICENSE file.

import Foundation

struct XcodeObject<Value: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case value = "_value"
    }

     let value: Value
}

struct XcodeArray<Value: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case values = "_values"
    }

     let values: [Value]
}

struct ActionsInvocationRecord: Decodable {
     let issues: ResultIssueSummaries
}

 struct ResultIssueSummaries: Decodable {
     var analyzerWarningSummaries: XcodeArray<IssueSummary>?
     var errorSummaries: XcodeArray<IssueSummary>?
     var testFailureSummaries: XcodeArray<TestFailureIssueSummary>?
     var warningSummaries: XcodeArray<IssueSummary>?
}

protocol IssueSummaryProtocol {
    var documentLocationInCreatingWorkspace: DocumentLocation? { get set }
    var message: XcodeObject<String> { get set }
    var issueType: XcodeObject<String> { get set }
    var producingTarget: XcodeObject<String>? { get set }
}

struct IssueSummary: Decodable, IssueSummaryProtocol {
     var documentLocationInCreatingWorkspace: DocumentLocation?
     var message: XcodeObject<String>
     var issueType: XcodeObject<String>
     var producingTarget: XcodeObject<String>?
}

 class TestFailureIssueSummary: Decodable, IssueSummaryProtocol {
     var documentLocationInCreatingWorkspace: DocumentLocation?
     var message: XcodeObject<String>
     var issueType: XcodeObject<String>
     var producingTarget: XcodeObject<String>?
     var testCaseName: XcodeObject<String>
}

 struct DocumentLocation: Decodable {
     let path: String
     let startingLineNumber: Int?
     let endingLineNumber: Int?
     let startingColumnNumber: Int?
     let endingColumnNumber: Int?

     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(XcodeObject<URL>.self, forKey: .url)
        guard var urlComponents = URLComponents(url: url.value, resolvingAgainstBaseURL: true) else {
            throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL")
        }

        urlComponents.query = urlComponents.fragment
        let fragmentQueryItem = { name in
            urlComponents
                .fragmentQueryItems?
                .last(where: { $0.name == name })?
                .value
        }

        self.path = urlComponents.path
        self.startingLineNumber = fragmentQueryItem("StartingLineNumber").flatMap(Int.init)
        self.endingLineNumber = fragmentQueryItem("EndingLineNumber").flatMap(Int.init)
        self.startingColumnNumber = fragmentQueryItem("StartingColumnNumber").flatMap(Int.init)
        self.endingColumnNumber = fragmentQueryItem("EndingColumnNumber").flatMap(Int.init)
    }

    enum CodingKeys: String, CodingKey {
        case url
    }
}

extension URLComponents {
    var fragmentQueryItems: [URLQueryItem]? {
        var newComponents = URLComponents()
        newComponents.query = fragment
        return newComponents.queryItems
    }
}
