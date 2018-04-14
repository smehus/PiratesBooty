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
    
    private var currentPaths: [CGPoint] = []
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    override func didEnter(from previousState: GKState?) {
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        move()
    }
    
    override func willExit(to nextState: GKState) {
        
    }

    private func findNextPath() -> CGPoint? {
        guard !withInRangeOfPlayer else { return nil }
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
            stateMachine!.enter(WithinRangeState.self)
            currentPaths.removeAll()
            return
        }
        
        guard let path = findNextPath() else { return }
        entity.sprite()!.physicsBody!.velocity = normalizedVelocity(velocity: CGVector(point: velocityToPlayer(path: path)))
    }

}

final class UpdatingState: EnemyState {
    
    override func didEnter(from previousState: GKState?) {
        createNodes()
    }
    
    private func createNodes(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {

            print("CONNECTING NODES")
            let playerNode = GKGraphNode2D.node(withPoint: vector_float2(Float(self.player.sprite()!.position.x), Float(self.player.sprite()!.position.y)))
            guard let graph = self.scene.obstacleGraph else { fatalError() }
            graph.connectUsingObstacles(node: playerNode)

            let enemyNode = GKGraphNode2D.node(withPoint: vector_float2(Float(self.entity.sprite()!.position.x), Float(self.entity.sprite()!.position.y)))

            graph.connectUsingObstacles(node: enemyNode)

            print("CREATING NODES")
            let pathNodes = graph.findPath(from: enemyNode, to: playerNode)

            let newPaths = pathNodes.flatMap ({ $0.position }).map { CGPoint($0) }
            self.currentPaths = newPaths
            self.stateMachine!.enter(EnRouteState.self)
            completion?()
        }
    }
}

final class WithinRangeState: EnemyState {
    
    private func orientTowardsPlayer() {
        entity.sprite()!.physicsBody?.velocity = .zero
        let angle = shortestAngleBetween(entity.sprite()!.zRotation, angle2: velocityToPlayer(path: player.position!).angle)
        entity.sprite()!.zRotation = angle
    }
}

final class EnemyPathfindingComponent: GKComponent {
    
    private unowned let scene: GameScene
    private let radius = CGPoint(x: 50, y: 50)
    private var stateMachine: GKStateMachine!
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
        
        guard let ship = entity as? Ship else {
            fatalError("Failed to cast entity as Ship object")
        }
        
        stateMachine = GKStateMachine(states: [
            EnRouteState(entity: ship, scene: scene),
            WithinRangeState(entity: ship, scene: scene),
            UpdatingState(entity: ship, scene: scene)])
        
        
        stateMachine.enter(EnRouteState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        stateMachine.update(deltaTime: seconds)
    }
}
