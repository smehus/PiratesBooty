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
    
    init(graph: GKObstacleGraph<GKGraphNode2D>) {
        self.graph = graph
    }
    
    func addObstacles(_ obstacles: [GKPolygonObstacle]) {
        
    }
    
    func connectUsingObstacles(node: GKGraphNode2D) {
        
    }
    
    func remove(_ nodes: [GKGraphNode2D]) {
        
    }
    
    func findPath(from fromNode: GKGraphNode2D, to toNode: GKGraphNode2D) {
        
    }
    
}
