//
//  ConsoleGenerator.swift
//  testsummaries
//
//  Created by Patrik Sjöberg on 2018-03-12.
//  Copyright © 2018 Patrik Sjöberg. All rights reserved.
//

import Foundation

struct ConsoleGenerator: Generator {
    typealias Test = XCodeResultBundle.TestSummariesPropertyList.Test
    typealias Activity = XCodeResultBundle.TestSummariesPropertyList.ActivitySummary
    typealias Attachment = XCodeResultBundle.TestSummariesPropertyList.Attachment
    
    var useColors: Bool
    var onlyUserActivities: Bool
    
    func walk(plist: XCodeResultBundle.TestSummariesPropertyList, block: (Test, [Test])->()) {
        for summary in plist.TestableSummaries {
            for test in summary.Tests {
                Tree.walkDepthFirst(from: test) { item, parents in
                    block(item, parents)
                    return item.Subtests ?? []
                }
            }
        }
    }
    
    func walk(_ activities: [Activity], block: (Activity, [Activity])->()) {
        for activity in activities {
            Tree.walkDepthFirst(from: activity) { item, parents in
                block(item, parents)
                return item.SubActivities ?? []
            }
        }
    }
    enum Color: String {
        case none
        case reset = "\u{001B}[0m"
        case black = "\u{001B}[0;30m"
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case magenta = "\u{001B}[0;35m"
        case cyan = "\u{001B}[0;36m"
        case white = "\u{001B}[0;37m"
    }
    
    func print(_ message: String, color: Color) {
        let withColor = useColors && color != .none
        if withColor {
            Swift.print(color.rawValue, message, Color.reset.rawValue)
        } else {
            Swift.print(message)
        }
    }
    
    
    func generate(from resultBundle: XCodeResultBundle) throws {
        for testAction in resultBundle.infoPlist.testActions {
            if let result = testAction.ActionResult, let summaryPath = result.TestSummaryPath {
                let summaryPath = resultBundle.pathForResource(summaryPath)
                let plist = try resultBundle.readTestSummaryPlist(path: summaryPath)
                try generate(from: plist)
            }
        }
    }
    
    func generate(from plist: XCodeResultBundle.TestSummariesPropertyList) throws {
        
        // Walk the tree of tests
        walk(plist: plist) { summary, parents in
            // only care about failing tests
            if summary.isTest && !summary.didSucceed {
                
                // print the failing test title
                print(parents.map{$0.TestName}.joined(separator: ".") + " " + summary.TestName, color: .none)
                
                // Print the fail location
                if let failures = summary.FailureSummaries {
                    for fail in failures {
                        print("\(fail.FileName):\(fail.LineNumber) - \(fail.Message)", color: .red)
                    }
                }
                
                // Print the activities leading to the failure
                if let activities = summary.ActivitySummaries {
                    walk(activities) { summary, parents in
                        if onlyUserActivities && summary.isInternalActivityType { return }
                        
                        let indent = (0..<parents.count).reduce("") { r, _ in r + "  " }
                        let color: Color = summary.Title.starts(with: "Assertion Failure:") ? .red : .none
                        print(indent + summary.Title, color: color)
                    }
                }
                
            }
        }
    }
}

