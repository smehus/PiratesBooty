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
    private var currentDT: TimeInterval = 0
    private var currentPaths: [CGPoint] = [] {
        didSet {
//            print("CURRENT PATHS COUNT: \(currentPaths.count)")
        }
    }
    
    private let radius = CGPoint(x: 50, y: 50)
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
        createNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
//        currentDT = seconds
//        checkProximity(dt: seconds)
//        move()
    }
    
    private func checkProximity(dt: TimeInterval) {
        if let currentPath = currentPaths.first, (currentPath - shipEntity.position!) < radius {
            currentPaths.removeFirst()
        }
    }
    
    private func move() {
        
        guard let nextPath = currentPaths.first else { return }
        let offset = nextPath - self.shipEntity.sprite()!.position
        let direction = offset.normalized()
        let velocity = direction * self.movePointsPerSec
        
        self.shipEntity.sprite()!.position += velocity
        self.shipEntity.sprite()!.zRotation = direction.angle
    }
    
    private func createNodes() {
        
        DispatchQueue.global().async {
            
            print("CONNECTING NODES")
            let playerNode = GKGraphNode2D(point: vector_float2(Float(self.player.sprite()!.position.x), Float(self.player.sprite()!.position.y)))
            guard let graph = self.scene.obstacleGraph else { fatalError() }
            graph.connectUsingObstacles(node: playerNode)
            
            let enemyNode = GKGraphNode2D(point: vector_float2(Float(self.shipEntity.sprite()!.position.x), Float(self.shipEntity.sprite()!.position.y)))
            
            graph.connectUsingObstacles(node: enemyNode)
            
            print("CREATING NODES")
            let pathNodes = graph.findPath(from: enemyNode, to: playerNode)
//            graph.remove([playerNode, enemyNode])
            
            
            let newPaths = pathNodes.flatMap ({ $0.position }).map { CGPoint($0) }
            self.currentPaths.append(contentsOf: newPaths)
            
            if newPaths.isEmpty {
                self.createNodes()
            }
            
            var actions: [SKAction] = []
            for path in newPaths {
                let offset = path - self.shipEntity.sprite()!.position
                let time = offset.length() / self.movePointsPerSec
//                print("Time it takes to get anywhere \(time)")
                let action = SKAction.move(to: path, duration: Double(time / 100))
                actions.append(action)
            }
            
            DispatchQueue.main.async {
                
                self.shipEntity.sprite()!.run(SKAction.sequence(actions), completion: {
                    print("ACTIONS COMPLETED")
                    self.createNodes()
                })
            }
        }
    }
}
