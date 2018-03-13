//
//  XCodeResultBundle.swift
//  XCodeResultBundle
//
//  Created by Patrik Sjöberg on 2018-03-12.
//  Copyright © 2018 Patrik Sjöberg. All rights reserved.
//

import Foundation

/// A bundle that xcoude outputs with results from build and test.
class XCodeResultBundle {
    // The path sent to `xcodebuild -resultBundlePath`
    let resultBundlePath: URL
    
    /// Parameter resultBundlePath: The resultBundlePath directory. See `xcodebuild -resultBundlePath`
    init(resultBundlePath: URL) throws {
        self.resultBundlePath = resultBundlePath
    }
    
    /// The path for the info.plist
    private var infoPlistPath: URL {
        return resultBundlePath.appendingPathComponent("Info.plist")
    }
    
    /// The information in Info.plist
    lazy var infoPlist: InformationPropertyList = {
        return try! read(file: infoPlistPath)
    }()
    
    /// The TestSummaries.plist file path
    lazy var testSummariesPlistPath: URL? = {
        let testActionResult = infoPlist.testActions.flatMap { $0.ActionResult }.first
        if let path = testActionResult?.TestSummaryPath ?? infoPlist.TestSummaryPath {
            return URL(fileURLWithPath: path, relativeTo: resultBundlePath)
        }
        return nil
    }()
    
    /// The TestSummaries.plist file contents
    lazy var testSummariesPlist: TestSummariesPropertyList? = {
        if let path = testSummariesPlistPath {
            return try! read(file: path)
        }
        return nil
    }()
    
    func readTestSummaryPlist(path: URL) throws -> TestSummariesPropertyList {
        return try read(file: path)
    }
    
    /// Decode a plist file
    private func read<T: Decodable>(file: URL) throws -> T {
        let data = try Data(contentsOf: file)
        return try PropertyListDecoder().decode(T.self, from: data)
    }
    
    func pathForResource(_ resource: String) -> URL {
        return URL(fileURLWithPath: resource, relativeTo: resultBundlePath)
    }
}

extension XCodeResultBundle {
    /// The Info.plist file
    struct InformationPropertyList: Codable {
        let Actions: [Action]
        let AnalyzerWarningCount: Int
        let CreatingWorkspaceFilePath: String
        let ErrorCount: Int
        let FormatVersion: String
        let Running: Bool
        let TestFailureSummaries: [TestFailureSummary]
        let TestSummaryPath: String?
        let TestsCount: Int
        let TestsFailedCount: Int
        let WarningCount: Int
        let WarningSummaries: [WarningSummary]
        
        struct WarningSummary: Codable {
            let DocumentLocationData: Data
            let IssueType: String
            let Message: String
            let Target: String
        }
        
        struct TestFailureSummary: Codable {
            let DocumentLocationData: Data
            let IssueType: String
            let Message: String
            let TestCase: String
        }
        
        struct Action: Codable {
            let Title: String
            let ActionResult: ActionResult?
            let BuildResult: ActionResult?
            let StartedTime: Date
            let EndedTime: Date
            let RunDestination: RunDestination
            let SchemeCommand: String
            let SchemeTask: String
        }
        
        struct RunDestination: Codable {
            
        }
        
        struct ActionResult: Codable {
            let AnalyzerWarningCount: Int
//            let AnalyzerWarningSummaries: [AnalyzerWarningSummary]
            let CodeCoveragePath: String?
            let ErrorCount: Int
//            let ErrorSummaries: [ErrorSummary]
            let LogPath: String
            let Status: String
//            let TestFailureSummaries: [TestFailureSummary]
            let TestSummaryPath: String?
            let TestsCount: Int
            let TestsFailedCount: Int
            let WarningCount: Int
//            let WarningSummaries: [WarningSummary]
        }
        
    }
}

extension XCodeResultBundle {
    // The TestSummaries.plist file
    struct TestSummariesPropertyList: Codable {
        let FormatVersion: String
        let RunDestination: RunDestination?
        let TestableSummaries: [TestableSummary]
        
        struct RunDestination: Codable {
            let LocalComputer: Computer
            let Name: String
            let TargetArchitecture: String
            let TargetDevice: Device
            let TargetSDK: SDK
        }
        
        struct Computer: Codable {
        }
        
        struct Device: Codable {
            let Identifier: String
            let IsConcreteDevice: Bool
            let ModelCode: String
            let ModelName: String
            let ModelUTI: String
            let Name: String
            let NativeArchitecture: String
            let OperatingSystemVersion: String
            let OperatingSystemVersionWithBuildNumber: String
            let Platform: Platform
        }
        
        struct Platform: Codable {
            let Identifier: String
            let Name: String
        }
        
        struct SDK: Codable {
        }
        
        struct TestableSummary: Codable {
            let ProjectPath: String
            let TargetName: String
            let TestName: String
            let TestObjectClass: String
            let Tests: [Test]
        }
        
        struct Test: Codable {
            let Subtests: [Test]?
            let Duration: TimeInterval
            let TestIdentifier: String
            let TestName: String
            let TestObjectClass: String
            
            let TestStatus: String?
            let TestSummaryGUID: String?
            
            let ActivitySummaries: [ActivitySummary]?
            let FailureSummaries: [FailureSummary]?
        }
        
        struct FailureSummary: Codable {
            let FileName: String
            let LineNumber: Int
            let Message: String
//            let PerformanceFailure: Bool
        }
        
        struct ActivitySummary: Codable {
            let ActivityType: String
            let FinishTimeInterval: TimeInterval
            let StartTimeInterval: TimeInterval
            let Title: String
            let UUID: String
            
            let SubActivities: [ActivitySummary]?
            let Attachments: [Attachment]?
        }
        
        struct Attachment: Codable {
            let Filename: String
            let HasPayload: Bool
            let InActivityIdentifier: Int
            let Lifetime: Int
            let Name: String
            let Timestamp: Double
            let UniformTypeIdentifier: String
        }
    }
}

extension XCodeResultBundle.InformationPropertyList.Action {
    var isTestAction: Bool {
        return SchemeCommand == "Test"
    }
}

extension XCodeResultBundle.InformationPropertyList {
    var testActions: [Action] {
        return Actions.filter { $0.isTestAction }
    }
}

extension XCodeResultBundle.TestSummariesPropertyList.Test {
    typealias Test = XCodeResultBundle.TestSummariesPropertyList.Test
    
    // flatmap all descending subtesets
    var descendants: [Test] {
        let subtests = Subtests ?? []
        return subtests + subtests.flatMap { $0.descendants }
    }
    
    /// TestObjectClass is 'IDESchemeActionTestSummaryGroup'
    var isGroup: Bool {
        return TestObjectClass == "IDESchemeActionTestSummaryGroup"
    }
    
    /// TestObjectClass is "IDESchemeActionTestSummary"
    var isTest: Bool {
        return TestObjectClass == "IDESchemeActionTestSummary"
    }
    
    /// Subtests contains at least one Test where isTest is true
    var hasTests: Bool {
        return Subtests?.contains(where: {$0.isTest}) ?? false
    }
    
    /// Subtests where isTest is true
    var tests: [Test] {
        return Subtests?.filter({$0.isTest}) ?? []
    }
    
    /// Subtests where isGroup is true
    var groups: [Test] {
        return Subtests?.filter({$0.isGroup}) ?? []
    }
    
    /// TestStatus is "Success"
    var didSucceed: Bool {
        return TestStatus == "Success"
    }
    
    /// At least one of descendants has a failing test
    var containsFailingTests: Bool {
        return descendants.contains(where: {$0.isTest && !$0.didSucceed })
    }
}

extension XCodeResultBundle.TestSummariesPropertyList.ActivitySummary {
    var isUserCreatedActivityType: Bool {
        return ActivityType == "com.apple.dt.xctest.activity-type.userCreated"
    }
    
    var isAssertFailureActivityType: Bool {
        return ActivityType == "com.apple.dt.xctest.activity-type.testAssertionFailure"
    }
    
    var isInternalActivityType: Bool {
        return ActivityType == "com.apple.dt.xctest.activity-type.internal"
    }
}

extension XCodeResultBundle.TestSummariesPropertyList.Attachment {
    var isScreenshot: Bool {
        return Name == "kXCTAttachmentLegacyScreenImageData"
    }
}
