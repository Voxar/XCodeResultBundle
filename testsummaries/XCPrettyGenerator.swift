//
//  XCPrettyGenerator.swift
//  testsummaries
//
//  Created by Patrik Sjöberg on 2018-03-12.
//  Copyright © 2018 Patrik Sjöberg. All rights reserved.
//

import Foundation

struct XCPrettyGenerator: Generator {
    var outputDirectory: URL
    var onlyUserActivities: Bool
    
    class Doc {
        var lines: [String] = []
        var level: Int = 0
        
        var indent: String {
            return (0..<level).reduce("") { r, _ in r + "  " }
        }
        
        static func << (doc: Doc, str: String) {
            doc.lines.append(doc.indent + str)
        }
        func tag(_ name: String, args: [String: CustomStringConvertible?], block: ()->()) {
            let flatArgs = args.reduce(into: [:]){$0[$1.0] = $1.1}
            let args = flatArgs.reduce(into: [String]()) { r, kv in r.append(kv.key + "=\"" + kv.value.description + "\"") }.joined(separator: " ")
            let startTag = args.isEmpty ? name : name + " " + args
            self << "<\(startTag)>"
            level += 1
            block()
            level -= 1
            self << "</\(name)>"
        }
        
        func tag(_ name: String, class: String? = nil, visible: Bool = true, block: ()->()) {
            let style = visible ? nil : "display: none"
            tag(name, args: ["class": `class`, "style": style], block: block)
        }
        
        func tag(_ name: String, _ contents: String) {
            self << "<\(name)>\(contents)</\(name)>"
        }
        var string: String {
            return lines.joined(separator: "\n")
        }
    }
    
    var cssStyle: String {
        return [
            "body { font-family:Avenir Next, Helvetica Neue, sans-serif; color: #4A4A4A; background-color: #F0F3FB; margin:0;}",
            "h1 { font-weight: normal; font-size: 24px; margin: 10px 0 0 0;}",
            "h3 { font-weight: normal; margin: 2px; font-size: 1.1em;}",
            "header { position: fixed;width: 100%;background: rgba(249, 254, 255, 0.9);margin: 0;padding: 10px;}",
            "header:before, header:after { content:\"\"; display:table;}",
            "header:after { clear:both;}",
            ".Success { background-color: green }",
            ".Failure { background-color: red }",
            "a:link { color: #A1D761;}",
            "footer { clear: both;position: relative;z-index: 10;height: 40px;margin-top: -10px; margin-left:30px; font-size:12px;}",
            "table { width:100%; border-collapse: collapse;}",
            "tr td:first-child { width:7%}",
            ".left { float: left; margin-left:30px;}",
            ".right { float: right; margin-right: 40px; margin-top: 0; margin-bottom:0;}",
            ".test-suite { margin: 0 0 30px 0;}",
            ".test-suite > .heading { font-family:Menlo, Monaco, monospace; font-weight: bold; border-color: #A1D761; background-color: #B8E986; border-width: 1px;}",
            ".test-suite.failing > .heading { border-color: #C84F5E; background-color: #E58591;}",
            ".test-suite > .heading > .title { margin-top: 4px; margin-left: 10px;}",
            ".tests { overflow: scroll;margin: 0 30px 0 60px;}",
            ".test, .test-suite > .heading { height: 30px; overflow: hidden; margin: 0 30px;}",
            ".test, .test-suite > .heading { border-width: 1px; border-collapse: collapse; border-style: solid; }",
            ".test { margin-left: 30px; border-top:none;}",
            ".test.failing { border-color: #C84F5E; background-color: #F4DDE0;}",
            ".test.passing { border-color: #A1D761;}",
            ".test.failing { background-color: #E7A1AA;}",
            ".test.passing { background-color: #CAF59F;}",
            ".test.failing.odd { background-color: #EEC7CC;}",
            ".test.passing.odd { background-color: #E5FBCF;}",
            ".details.failing { background-color: #F4DDE0; border: 1px solid #C84F5E;}",
            ".details.passing { background-color: #E5F4DC; border: 1px solid #A1D761;}",
            ".test .test-detail:last-child { padding-bottom: 8px;}",
            ".test .title { float: left; font-size: 0.9em; margin-top: 8px; font-family: Menlo, Monaco, monospace;}",
            ".test .time { float: left;margin: 4px 10px 0 20px;}",
            ".test-detail { font-family:Menlo, Monaco, monospace; font-size: 0.9em; margin: 5px 0 5px 0px;}",
            ".screenshots { height: auto; overflow: hidden; padding: 4px 4px 0 4px; background-color: #B8E986; border: #A1D761; border-width: 0 1px; border-style: solid; }",
            ".screenshots.failing { border-color: #C84F5E; background-color: #E58591; }",
            ".screenshot { max-height: 60px; float: left; transition: max-height 0.2s; margin: 0 4px 4px 0 }",
            ".screenshot.selected { max-height: 568px; }",
            "#test-suites { display: inline-block; width: 100%;margin-top:100px;}",
            "#segment-bar { margin-top: 10px;margin-left: 14px;float:right;}",
            "#segment-bar a:first-child { border-radius: 9px 0 0 9px; border-right: none;}",
            "#segment-bar a:last-child { border-radius: 0 9px 9px 0; border-left: none;}",
            "#segment-bar > a { color: #565656; border: 2px solid  #7B7B7B; width: 80px; font-weight: bold; display:inline-block;text-align:center; font-weight: normal;}",
            "#segment-bar > a.selected { background-color: #979797; color: #F0F3FB;}",
            "#counters { float: left;margin: 10px;text-align: right;}",
            "#counters h2 { font-size: 16px; font-family: Avenir, sans-serif; font-weight: lighter; display:inline;}",
            "#counters .number { font-size: 20px;}",
            "#fail-count { color: #D0021B; margin-left:10px;}",
            "@media (max-width: 640px) {",
            "  h1, #counters, #segment-bar { margin: 5px auto; text-align:center;}",
            "  header, #segment-bar { width: 100%; position: relative; background:none;}",
            "  .left, .right { float:none; margin:0;}",
            "  #test-suites { margin-top: 0;}",
            "  #counters { float:none;}",
            "}"
            ].joined(separator: "\n")
    }
    
    var javascript: String {
        return [
            "<script type='text/javascript'>",
            "function toggle(element) { element.style.display = element.style.display == 'none' ? '' : 'none' }",
            "</script>",
            ].joined(separator: "\n")
    }
    
    func write(string: String, toFile: String) throws {
        let file = outputDirectory.appendingPathComponent(toFile)
        print("writing to " + file.absoluteString)
        
        try! string.data(using: .utf8)?.write(to: file)
    }
    
    typealias Attachment = XCodeResultBundle.TestSummariesPropertyList.Attachment
    
    func generate(from resultBundle: XCodeResultBundle) throws {
        for testAction in resultBundle.infoPlist.testActions {
            if let result = testAction.ActionResult, let summaryPath = result.TestSummaryPath {
                let summaryPath = resultBundle.pathForResource(summaryPath)
                let attachmentsDirectory = summaryPath.deletingLastPathComponent().appendingPathComponent("Attachments")
                let plist = try resultBundle.readTestSummaryPlist(path: summaryPath)
                try generate(from: plist, attachmentsDirectory: attachmentsDirectory)
            }
        }
    }
    
    func generate(from plist: XCodeResultBundle.TestSummariesPropertyList, attachmentsDirectory: URL) throws {
        func save(attachment: Attachment) {
            let sourcePath = attachmentsDirectory.appendingPathComponent(attachment.Filename)
            let destinationPath = outputDirectory.appendingPathComponent(attachment.Filename)
            try? FileManager.default.createDirectory(
                at: attachmentsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try? FileManager.default.removeItem(at: destinationPath)
            try! FileManager.default.copyItem(at: sourcePath, to: destinationPath)
        }
        
        let doc = Doc()
        doc << "<html><head>"
        doc.tag("style", cssStyle)
        doc << javascript
        doc << "</head>"
        doc.tag("header") {
            doc.tag("section") {
                doc.tag("h1", "Test Results")
            }
        }
        
        doc << "<section id=\"test-suites\">"
        
        typealias Activity = XCodeResultBundle.TestSummariesPropertyList.ActivitySummary
        func walk(activities: [Activity], block: (Activity, [Activity])->()) {
            for activity in activities {
                Tree.walkDepthFirst(from: activity) { item, parents in
                    block(item, parents)
                    return item.SubActivities ?? []
                }
            }
        }

        
        func gen(group: XCodeResultBundle.TestSummariesPropertyList.Test, name: String) {
            if group.hasTests {
                doc.tag("section", class: "test-suite " + (group.containsFailingTests ? "failing" : "passing")) {
                    doc.tag("section onClick='toggle(this.parentNode.children[1]);'", class: "heading") {
                        doc.tag("h3 class='title'", name)
                    }
                    
                    doc.tag("section", class: "tests", visible: group.containsFailingTests) {
                        doc.tag("table") {
                            for test in group.tests {
                                doc.tag("tr", class: "test " + (test.didSucceed ? "passing" : "failing")) {
                                    doc.tag("td", class: "time") {
                                        doc.tag("h3", String(format: "%.3fs", test.Duration))
                                    }
                                    doc.tag("td", class: "title") {
                                        doc.tag("h3", test.TestName)
                                    }
                                }
                                
                                walk(activities: test.ActivitySummaries ?? []) { activity, parents in
                                    let indent = parents.count
                                    if onlyUserActivities && activity.isInternalActivityType { return }
                                    doc.tag("tr") {
                                        doc.tag("td style=\"padding-left: \(indent*20)px\"", class: activity.isAssertFailureActivityType ? "failing" : nil) {
                                            doc.tag("h3", activity.Title)
                                            for attachment in activity.Attachments ?? [] {
                                                save(attachment: attachment)
                                                doc.tag("img", args: ["src": attachment.Filename], block: {})
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                    }
                }
            }
            
            func nameFor(groupName: String) -> String {
                if groupName == "All tests" { return name }
                if groupName.contains(".xctest") {
                    return name
                }
                return name + "." + groupName
            }
            
            for subgroup in group.groups {
                gen(group: subgroup, name: nameFor(groupName: subgroup.TestName))
            }
        }
        
        for summary in plist.TestableSummaries {
            
            for test in summary.Tests {
                gen(group: test, name: summary.TargetName)
            }
            
        }
        doc << "</section>"
        doc << "</body></html>"
        
        try! write(string: doc.string, toFile: "index.html")
    }
}

