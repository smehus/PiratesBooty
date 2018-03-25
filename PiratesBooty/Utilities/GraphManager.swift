//
//  GraphManager.swift
//  PiratesBooty
//
//  Created by scott mehus on 3/10/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit



/// I put stuff in locks because accessing the graph was crashing the game.
/// However, when i did that, it seemed like obstacles weren't being added
final class GraphManager {
    
    let graph: GKObstacleGraph<GKGraphNode2D>
    private let lock = NSRecursiveLock()
    
    init(graph: GKObstacleGraph<GKGraphNode2D>) {
        self.graph = graph
    }
    
    func addObstacles(_ obstacles: [GKPolygonObstacle]) {
        graph.addObstacles(obstacles)
        
//        lockedProcedure { [weak self] in
//
//        }
    }
    
    func connectUsingObstacles(node: GKGraphNode2D) {
        
        graph.connectUsingObstacles(node: node)
//        lockedProcedure { [weak self] in
//            self?.graph.connectUsingObstacles(node: node)
//        }
    }
    
    func remove(_ nodes: [GKGraphNode2D]) {
        graph.remove(nodes)
        
//        lockedProcedure { [weak self] in
//            self?.graph.remove(nodes)
//        }
    }
    
    func findPath(from fromNode: GKGraphNode2D, to toNode: GKGraphNode2D) -> [GKGraphNode2D] {
        
        return graph.findPath(from: fromNode, to: toNode) as! [GKGraphNode2D]
//        var paths: [GKGraphNode] = []
//        lock.lock()
//        paths = graph.findPath(from: fromNode, to: toNode)
//        lock.unlock()
//        return paths as! [GKGraphNode2D]
    }
    
    private func lockedProcedure(procedure: () -> ()) {
        defer {
            lock.unlock()
        }
        
        lock.lock()
        procedure()
    }
}
