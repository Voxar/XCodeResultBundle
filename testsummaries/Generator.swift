//
//  Generator.swift
//  testsummaries
//
//  Created by Patrik Sjöberg on 2018-03-12.
//  Copyright © 2018 Patrik Sjöberg. All rights reserved.
//

import Foundation

protocol Generator {
    /// Generate
    func generate(from resultBundle: XCodeResultBundle) throws
}
