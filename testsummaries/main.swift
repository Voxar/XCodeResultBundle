
//
//  main.swift
//  testsummaries
//
//  Created by Patrik Sjöberg on 2018-03-09.
//  Copyright © 2018 Patrik Sjöberg. All rights reserved.
//

import Foundation

do {
    func help() {
        print([
            "usage: testsummaries [options] inputfile",
            "--color                 Use colorcul output",
            "--only-user-activities  Only print custom activities (see XCContext.runActivity)",
            "--html                  Generate html report to --output-dir",
            "--output-dir            The directory to store files"
        ].joined(separator: "\n"))
        exit(1)
    }
    
    let args = ProcessInfo.processInfo.arguments
    if args.filter({!$0.starts(with:"--")}).count == 1 {
        // no file given
        print("No input file given")
        help()
    }
    
    var generateHtml: Bool = false
    var useConsoleColor: Bool = false
    var outputDir: String = "."
    var onlyUserActivities: Bool = false
    var iterator = args.dropFirst().makeIterator()
    while let arg = iterator.next() {
        switch arg {
        case "--color": useConsoleColor = true
        case "--html": generateHtml = true
        case "--output-dir":
            if let dir = iterator.next() {
                outputDir = dir
            } else {
                print("--output-dir needs an argument")
                help()
            }
        case "--only-user-activities": onlyUserActivities = true
        default:
            break
        }
    }
    
    if let file = ProcessInfo.processInfo.arguments.last {
        let url = URL(fileURLWithPath: file)
        let resultBundle = try XCodeResultBundle(resultBundlePath: url)
        
        try ConsoleGenerator(
            useColors: useConsoleColor,
            onlyUserActivities: onlyUserActivities
        ).generate(from: resultBundle)
        
        if generateHtml {
            try XCPrettyGenerator(
                outputDirectory: URL(fileURLWithPath: outputDir),
                onlyUserActivities: onlyUserActivities
            ).generate(from: resultBundle)
        }
    }
} catch let error {
    print(error)
}
