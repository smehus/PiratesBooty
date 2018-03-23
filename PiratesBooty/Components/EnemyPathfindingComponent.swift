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
    private let movePointsPerSec: CGFloat = 5.0
    private var currentPaths: [CGPoint] = []
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        checkProximity(dt: seconds)
        

    }
    
    func checkProximity(dt: TimeInterval) {
        createNodes(dt: dt)
    }
    
    var shouldAction = true
    func createNodes(dt: TimeInterval) {
        shipEntity.sprite()?.removeAction(forKey: ActionKeys.currentAction)
        
        DispatchQueue.global().async {
            
            let playerNode = GKGraphNode2D(point: vector_float2(Float(self.player.sprite()!.position.x), Float(self.player.sprite()!.position.y)))
            guard let graph = self.scene.obstacleGraph else { fatalError() }
            graph.connectUsingObstacles(node: playerNode)
            
            let enemyNode = GKGraphNode2D(point: vector_float2(Float(self.shipEntity.sprite()!.position.x), Float(self.shipEntity.sprite()!.position.y)))
            graph.connectUsingObstacles(node: enemyNode)
            
            let pathNodes = graph.findPath(from: enemyNode, to: playerNode)
            graph.remove([playerNode, enemyNode])
            
            let newPaths = pathNodes.flatMap ({ $0.position }).map { CGPoint($0) }
            self.currentPaths.append(contentsOf: newPaths)
            
            DispatchQueue.main.async {
                if pathNodes.count >= 2 {
                    let offset = CGPoint(pathNodes[1].position) - self.shipEntity.sprite()!.position
                    let direction = offset.normalized()
                    let velocity = direction * self.movePointsPerSec
                    
                    self.shipEntity.sprite()!.position += velocity
                    self.shipEntity.sprite()!.zRotation = direction.angle
                }
            }
        }
    }
}
