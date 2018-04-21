//
//  EnemyPathfindingComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 3/10/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

class EnemyState: GKState {
    unowned var scene: GameScene
    var entity: Ship
    
    var player: Ship {
        return scene.playerShip
    }
    
    var withInRangeOfPlayer: Bool {
        return entity.position!.withInRange(range: -500...500, matchingPoint: player.position!)
    }
    
    init(entity: Ship, scene: GameScene) {
        self.entity = entity
        self.scene = scene
    }
    
    func velocityToPlayer(path: CGPoint) -> CGPoint {
        let offset = path - entity.sprite()!.position
        let direction = offset.normalized()
        return direction * 200.0
    }
}

final class EnRouteState: EnemyState {
    
    var currentPaths: [CGPoint] = [] {
        didSet {
            shouldMove = !currentPaths.isEmpty
        }
    }
    private var shouldMove = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        print("ENTERING ENROUTE STATE")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if shouldMove {
            move()
        }
    }
    
    override func willExit(to nextState: GKState) {
        
    }

    private func findNextPath() -> CGPoint? {
        guard let firstPath = currentPaths.first else {
            stateMachine!.enter(UpdatingState.self)
            return nil
        }
        
        if entity.position!.withInRange(range: -100...100, matchingPoint: firstPath) {
            currentPaths.removeFirst()
            return findNextPath()
        } else {
            return firstPath
        }
    }
    
    private func move() {
        guard !withInRangeOfPlayer else {
            currentPaths.removeAll()
            stateMachine!.enter(WithinRangeState.self)
            return
        }
        
        guard let path = findNextPath() else { return }
        entity.sprite()!.physicsBody!.velocity = normalizedVelocity(velocity: CGVector(point: velocityToPlayer(path: path)))
    }
}

final class HoldingState: EnemyState {
    private var accumalatedTime: TimeInterval = 0
    
    override func didEnter(from previousState: GKState?) {
        print("ENTERING HOLDING STATE")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        accumalatedTime += seconds
        
        if accumalatedTime > 2.0 {
            accumalatedTime = 0
            stateMachine!.enter(UpdatingState.self)
        }
    }
}

final class UpdatingState: EnemyState {
    
    var currentPaths: [CGPoint] = []
    
    override func didEnter(from previousState: GKState?) {
        print("ENTERING UPDATING STATE")
        createNodes()
    }
    
    override func willExit(to nextState: GKState) {
        if let enrouteState = nextState as? EnRouteState {
            enrouteState.currentPaths = currentPaths
        }
    }
    
    private func createNodes() {
        DispatchQueue.global().async {

            print("CONNECTING NODES")
            let playerNode = GKGraphNode2D.node(withPoint: vector_float2(Float(self.player.sprite()!.position.x), Float(self.player.sprite()!.position.y)))
            guard let graph = self.scene.obstacleGraph else { fatalError() }
            graph.connectUsingObstacles(node: playerNode)

            let enemyNode = GKGraphNode2D.node(withPoint: vector_float2(Float(self.entity.sprite()!.position.x), Float(self.entity.sprite()!.position.y)))

            graph.connectUsingObstacles(node: enemyNode)

            print("CREATING NODES")
            let pathNodes = graph.findPath(from: enemyNode, to: playerNode)

            let newPaths = pathNodes.compactMap ({ $0.position }).map { CGPoint($0) }
            self.currentPaths = newPaths
            self.stateMachine!.enter(EnRouteState.self)
        }
    }
}

final class WithinRangeState: EnemyState {
    
    private var firingGate: Double = 2
    
    override func didEnter(from previousState: GKState?) {
        print("ENTERING WITHINRANGE STATE")
        orientTowardsPlayer()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if !withInRangeOfPlayer {
            stateMachine!.enter(HoldingState.self)
        }
        
        firingGate += seconds
        
        if firingGate >= 2, let pos = player.position {
            firingGate = 0
            
            let x = CGFloat.random(min: pos.x - 250, max: pos.x + 250)
            let y = CGFloat.random(min: pos.y - 250, max: pos.y + 250)
            entity.fireCannon(at: CGPoint(x: x, y: y))
        }
        
        orientTowardsPlayer()
    }
    
    private func orientTowardsPlayer() {
        entity.sprite()!.physicsBody?.velocity = .zero
        let direction = velocityToPlayer(path: player.position!)
        rotate(sprite: entity.sprite()!, direction: direction)
    }
    
    private func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = atan2(direction.y, direction.x)
    }
}

final class OutOfRangeState: EnemyState {
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let position = entity.position, let playerPos = player.position else {
            return
        }
        
        if position.withInRange(range: -2000...2000, matchingPoint: playerPos) {
            stateMachine?.enter(UpdatingState.self)
        }
    }
}


final class EnemyPathfindingComponent: GKComponent {
    
    private unowned let scene: GameScene
    private let radius = CGPoint(x: 50, y: 50)
    private var stateMachine: GKStateMachine?
    private var createdStateMachine = false
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willRemoveFromEntity() {
        super.willRemoveFromEntity()
        stateMachine = nil
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if !createdStateMachine, let ship = entity as? Ship {
            stateMachine = GKStateMachine(states: [
                EnRouteState(entity: ship, scene: scene),
                WithinRangeState(entity: ship, scene: scene),
                UpdatingState(entity: ship, scene: scene),
                HoldingState(entity: ship, scene: scene),
                OutOfRangeState(entity: ship, scene: scene)])
            
            
            stateMachine?.enter(UpdatingState.self)
            createdStateMachine = true
        } else {
            
            if let spriteComponent = entity?.component(ofType: SpriteComponent.self), let playerPos = scene.playerShip.position {
                if !spriteComponent.node.position.withInRange(range: -2000...2000, matchingPoint: playerPos) {
                    stateMachine?.enter(OutOfRangeState.self)
                }
            }
            
            stateMachine?.update(deltaTime: seconds)
        }
    }
}
