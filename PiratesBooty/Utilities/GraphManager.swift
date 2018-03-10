//
//  GraphManager.swift
//  PiratesBooty
//
//  Created by scott mehus on 3/10/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

final class GraphManager {
    
    private let graph: GKObstacleGraph<GKGraphNode2D>
    private let lock = NSRecursiveLock()
    
    init(graph: GKObstacleGraph<GKGraphNode2D>) {
        self.graph = graph
    }
    
    func addObstacles(_ obstacles: [GKPolygonObstacle]) {
        lockedProcedure { [weak self] in
            self?.graph.addObstacles(obstacles)
        }
    }
    
    func connectUsingObstacles(node: GKGraphNode2D) {
        lockedProcedure { [weak self] in
            self?.graph.connectUsingObstacles(node: node)
        }
    }
    
    func remove(_ nodes: [GKGraphNode2D]) {
        lockedProcedure { [weak self] in
            self?.graph.remove(nodes)
        }
    }
    
    func findPath(from fromNode: GKGraphNode2D, to toNode: GKGraphNode2D) -> [GKGraphNode2D] {
        var paths: [GKGraphNode] = []
        lock.lock()
        paths = graph.findPath(from: fromNode, to: toNode)
        lock.unlock()
        return paths as! [GKGraphNode2D]
    }
    
    private func lockedProcedure(procedure: () -> ()) {
        defer {
            lock.unlock()
        }
        
        lock.lock()
        procedure()
    }
}
