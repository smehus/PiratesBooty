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
    private let movePointsPerSec: CGFloat = 5000
    private var currentDT: TimeInterval = 0
    private var hasCreatedNodes = false
    private var currentPaths: [CGPoint] = [] {
        didSet {
//            print("CURRENT PATHS COUNT: \(currentPaths.count)")
        }
    }
    
    private let radius = CGPoint(x: 50, y: 50)
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        currentDT = seconds
        if let _ = entity, !hasCreatedNodes {
            hasCreatedNodes = true
            createNodes()
        }
        
        move()
    }
    
    private func checkProximity(dt: TimeInterval) {
        if let currentPath = currentPaths.first, (currentPath - shipEntity.position!) < radius {
            currentPaths.removeFirst()
        }
    }
    
    private func findNextPath() -> CGPoint? {
        
        guard let firstPath = currentPaths.first else {
            return nil
        }
        if shipEntity.position!.withInRange(range: -100...100, matchingPoint: firstPath) {
            currentPaths.removeFirst()
            return findNextPath()
        } else {
            return firstPath
        }
    }
    
    private func move() {
        guard let path = findNextPath() else { return }

        let offset = path - self.shipEntity.sprite()!.position
        let direction = offset.normalized()
        let velocity = direction * self.movePointsPerSec
        shipEntity.sprite()!.physicsBody!.velocity = CGVector(point: velocity * CGFloat(currentDT))
        shipEntity.sprite()!.zRotation = direction.angle
    }
    
    private func createNodes() {
        DispatchQueue.global().async {
            
            print("CONNECTING NODES")
            let playerNode = GKGraphNode2D.node(withPoint: vector_float2(Float(self.player.sprite()!.position.x), Float(self.player.sprite()!.position.y)))
            guard let graph = self.scene.obstacleGraph else { fatalError() }
            graph.connectUsingObstacles(node: playerNode)
            
            let enemyNode = GKGraphNode2D.node(withPoint: vector_float2(Float(self.shipEntity.sprite()!.position.x), Float(self.shipEntity.sprite()!.position.y)))
            
            graph.connectUsingObstacles(node: enemyNode)
            
            print("CREATING NODES")
            let pathNodes = graph.findPath(from: enemyNode, to: playerNode)

            let newPaths = pathNodes.flatMap ({ $0.position }).map { CGPoint($0) }
            self.currentPaths = newPaths
            
            // Using SKActions - meh
//            if newPaths.isEmpty {
//                self.createNodes()
//                return
//            }
//
//            var actions: [SKAction] = []
//            for path in newPaths {
//                let offset = path - self.shipEntity.sprite()!.position
//                let time = offset.length() / self.movePointsPerSec
//                let action = SKAction.move(to: path, duration: Double(time / 100))
//                actions.append(action)
//            }
//
//            DispatchQueue.main.async {
//
//                self.shipEntity.sprite()!.run(SKAction.sequence(actions), completion: {
//                    print("ACTIONS COMPLETED")
//                    self.createNodes()
//                })
//            }
        }
    }
}
