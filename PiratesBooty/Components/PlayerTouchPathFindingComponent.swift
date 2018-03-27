//
//  PlayerTouchPathFindingComponent.swift
//  PiratesBooty
//
//  Created by Scott Mehus on 3/26/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

final class PlayerTouchPathFindingComponent: GKComponent {
    
    private unowned let scene: GameScene
    private var playerPaths: [GKGraphNode] = []
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        movePlayer()
    }
    
    private func nextPath() -> CGPoint? {
        guard let ship = entity as? Ship else { return nil }
        guard let firstPath = playerPaths.first, let path = firstPath as? GKGraphNode2D else { return nil }
        if ship.position!.withInRange(range: -100...100, matchingPoint: CGPoint(path.position)) {
            playerPaths.removeFirst()
            return nextPath()
        } else {
            return CGPoint(path.position)
        }
    }
    
    private func movePlayer() {
        guard let playerShip = entity as? Ship else { return }
        guard let path = nextPath() else { return }
        let offset = path - playerShip.position!
        let direction = offset.normalized()
        let velocity = direction * 200.0
        playerShip.sprite()?.physicsBody?.velocity = normalizedVelocity(velocity: CGVector(point: velocity))
    }
    
    
    private func normalizedVelocity(velocity: CGVector) -> CGVector {
        var y: CGFloat
        var x: CGFloat
        if velocity.dx < -Ship.MAX_VELOCITY {
            x = -Ship.MAX_VELOCITY
        } else if velocity.dx > Ship.MAX_VELOCITY {
            x = Ship.MAX_VELOCITY
        } else {
            x = velocity.dx
        }
        
        if velocity.dy < -Ship.MAX_VELOCITY {
            y = -Ship.MAX_VELOCITY
        } else if velocity.dy > Ship.MAX_VELOCITY {
            y = Ship.MAX_VELOCITY
        } else {
            y = velocity.dy
        }
        
        return CGVector(dx: x, dy: y)
    }
}

extension PlayerTouchPathFindingComponent: ToucheDetector {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let graph = scene.obstacleGraph else { return }
        
        guard let playerShip = entity as? Ship else { return }
        guard let touch = touches.first?.location(in: scene) else { return }
        guard let playerVector = playerShip.position?.vector_float() else { return }
        
        let playerNode = GKGraphNode2D.node(withPoint: playerVector)
        let touchNode = GKGraphNode2D.node(withPoint: touch.vector_float())
        graph.connectUsingObstacles(node: touchNode)
        graph.connectUsingObstacles(node: playerNode)
        
        playerPaths = graph.graph.findPath(from: playerNode, to: touchNode)
    }
}

extension PlayerTouchPathFindingComponent {
    private func runPlayerActions(with paths: [GKGraphNode]) {
        guard let playerShip = entity as? Ship else { return }
        let actions = paths.enumerated().flatMap { (index, node) -> SKAction? in
            guard let graphNode = node as? GKGraphNode2D else { fatalError() }
            let point = CGPoint(graphNode.position)
            
            let offset = playerShip.position! - point
            let time = offset.length() / 5.0
            return SKAction.move(to: point, duration: Double(time / 100))
        }
        
        playerShip.sprite()!.run(SKAction.sequence(actions))
    }
    
    func printDebugInfo(with touch: CGPoint) {
        guard let obstacleGraph = scene.obstacleGraph else { return }
        let filter = obstacleGraph.graph.obstacles.sorted(by: { (first, second) -> Bool in
            return first.vertex(at: 0).x > second.vertex(at: 0).x
        })
        
        for _ in filter {
            //            print("\(v.vertex(at: 0)) \n")
        }
        
        //        print("TOUCH \(touch)")
        let _ = filter.first { (obstacle) -> Bool in
            let range: CountableClosedRange<Int> = -100...100
            let matchX = range ~= Int((obstacle.vertex(at: 0).x - Float(touch.x)))
            let matchY = range ~= Int((obstacle.vertex(at: 0).y - Float(touch.y)))
            return matchX && matchY
        }
        
        
    }
}
