//
//  Tree.swift
//
//  Created by Patrik Sjöberg on 2018-03-12.
//  Copyright © 2018 Patrik Sjöberg. All rights reserved.
//

import Foundation


public struct Tree<T> {
    // receives the current `node` and the nodes that led to it. Return the nodes children
    public typealias Walkfunc = (_ node: T, _ parents: [T])->[T]
    
    // the root node of the tree
    public let root: T
}

/// Depth first
extension Tree {
    public func walkDepthFirst(block: Walkfunc) {
        Tree.walkDepthFirst(from: root, block: block)
    }
    
    public static func walkDepthFirst(from node: T, block: Walkfunc) {
        _walkDepthFirst(node, parents: [], block: block)
    }
    
    private static func _walkDepthFirst(_ node: T, parents: [T], block: Walkfunc) {
        let children = block(node, parents)
        
        let parents = parents + [node]
        for child in children {
            _walkDepthFirst(child, parents: parents, block: block)
        }
    }
}

