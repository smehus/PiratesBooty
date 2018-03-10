//
//  EnemyPathfindingComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 3/10/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

final class EnemyPathfindingComponent: GKComponent {
    
    private var player: Ship {
        return scene.playerShip
    }
    
    private var shipEntity: Ship! {
        return entity as! Ship
    }
    
    private unowned let scene: GameScene
    private var currentActions: [SKAction] = []
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        checkProximity()
    }
    
    func checkProximity() {
        createNodes()
    }
    
    func createNodes() {
        
        let playerNode = GKGraphNode2D(point: vector_float2(Float(player.sprite()!.position.x), Float(player.sprite()!.position.y)))
        guard let graph = scene.obstacleGraph else { fatalError() }
        graph.connectUsingObstacles(node: playerNode)
        
        let enemyNode = GKGraphNode2D(point: vector_float2(Float(shipEntity.sprite()!.position.x), Float(shipEntity.sprite()!.position.y)))
        graph.connectUsingObstacles(node: enemyNode)
        
        let pathNodes = graph.findPath(from: enemyNode, to: playerNode)

        var actions: [SKAction] = []
        for node in pathNodes {
            let act = SKAction.move(to: CGPoint(node.position), duration: 1.0)
        }
        
        
        defer {
            graph.remove([playerNode, enemyNode])
        }
    }
}
