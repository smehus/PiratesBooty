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
    
    private struct ActionKeys {
        static let currentAction = "currentAction"
    }
    
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
    
    var shouldAction = true
    func createNodes() {
        guard shouldAction else { return }
        shipEntity.sprite()?.removeAction(forKey: ActionKeys.currentAction)
        
        let playerNode = GKGraphNode2D(point: vector_float2(Float(player.sprite()!.position.x), Float(player.sprite()!.position.y)))
        guard let graph = scene.obstacleGraph else { fatalError() }
        graph.connectUsingObstacles(node: playerNode)
        
        let enemyNode = GKGraphNode2D(point: vector_float2(Float(shipEntity.sprite()!.position.x), Float(shipEntity.sprite()!.position.y)))
        graph.connectUsingObstacles(node: enemyNode)
        
        let pathNodes = graph.findPath(from: enemyNode, to: playerNode)

        var actions: [SKAction] = []
        for node in pathNodes {
            actions.append(SKAction.move(to: CGPoint(node.position), duration: 1.0))
        }
        
        
        let sequence = SKAction.sequence(actions)
        shipEntity.sprite()!.run(sequence, withKey: ActionKeys.currentAction)
        shouldAction = false
        defer {
            graph.remove([playerNode, enemyNode])
        }
    }
}
