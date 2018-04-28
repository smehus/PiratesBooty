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
    private let addLock = NSRecursiveLock()
    private let queue = DispatchQueue(label: "what", attributes: .concurrent)
    
    init(graph: GKObstacleGraph<GKGraphNode2D>) {
        self.graph = graph
    }
    
    func addNodes(_ obstacles: [SKNode], fromSource name: String) {
        print("ADDING \(obstacles.count) OBSTACLES FOR SOURCE: \(name)")
        queue.async(qos: .userInitiated,flags: .barrier) {
            
            let nodes = SKNode.obstacles(fromNodePhysicsBodies: obstacles)
            self.graph.addObstacles(nodes)
            print("OBSTACLES ADDED FOR SOURCE \(name)")
        }
    }
    
    func addNodes(_ obstacles: [[float2]], fromSource name: String) {
        print("ADDING \(obstacles.count) OBSTACLES FOR SOURCE: \(name)")
        
        queue.async(qos: .userInitiated,flags: .barrier) {
            
            let nodes = obstacles.map { GKPolygonObstacle(points: $0) }
            self.graph.addObstacles(nodes)
            print("OBSTACLES ADDED FOR SOURCE \(name)")
        }
    }

    //TODO: This logic is wrong
    func obstacle(at point: CGPoint) -> GKPolygonObstacle? {
        return graph.obstacles.first(where: { (obstacle) -> Bool in
            for i in 0..<obstacle.vertexCount {
                let vertex = CGPoint(obstacle.vertex(at: i))
                
                return point < vertex
            }
            
            return false
        })
    }
    
    func addObstacles(_ obstacles: [GKPolygonObstacle]) {
        queue.async(flags: .barrier) {
            self.graph.addObstacles(obstacles)
        }
    }
    
    func connectUsingObstacles(node: GKGraphNode2D) {
        graph.connectUsingObstacles(node: node)
    }
    
    func remove(_ nodes: [GKGraphNode2D]) {
        graph.remove(nodes)
    }
    
    func findPath(from fromNode: GKGraphNode2D, to toNode: GKGraphNode2D) -> [GKGraphNode2D] {
        return graph.findPath(from: fromNode, to: toNode) as! [GKGraphNode2D]
    }
}
