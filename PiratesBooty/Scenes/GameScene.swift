//
//  GameScene.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit


/// NOTES
/// use GKGraphNode2D for enemy path finding around obstacles (islands)


final class GameScene: SKScene {
    
    var playerShip: Ship!
    var obstacleGraph: GraphManager!
    
    private var motionManager: MovementManager = MotionManager(modifier: 30.0)
    private var entityManager: EntityManager!
    private var lastUpdatedTime: TimeInterval = 0
    private let attitudeMultiplier: Double = 30.0
    private var queuedObstacles: [GKPolygonObstacle]?
    
    override func didMove(to view: SKView) {
        setupRequiredNodes()
        setupCamera()
        setupNodes()
        setupMotion()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        entityManager.update(delta)
    }
    
    private func setupRequiredNodes() {
        
        physicsWorld.contactDelegate = self
        motionManager.delegate = self
        entityManager = EntityManager(scene: self)
        
        playerShip = Ship(scene: self, shipType: .defaultShip)
        playerShip.position = CGPoint(x: 0, y: 0)
        playerShip.sprite()!.zRotation = CGFloat(90).degreesToRadians()
        entityManager.add(playerShip)
        obstacleGraph = GraphManager(graph: GKObstacleGraph(obstacles: [], bufferRadius: 30))

    }
    
    private func setupNodes() {
        entityManager.add(World(scene: self, entityManager: entityManager))
    }
    
    private func setupMotion() {
//        motionManager.start()
    }
    
    private func setupCamera() {
        let cam = SKCameraNode()
        cam.xScale = cameraScale.xScale
        cam.yScale = cameraScale.yScale
        addChild(cam)
        camera = cam
        
        ///
        /// Follow Ship
        ///
        
        guard let ship = playerShip.sprite() else { return }
        let followConstraint = SKConstraint.distance(SKRange(constantValue: 0), to: ship)
        
        
        ///
        /// Constraint to edges
        ///
        
        /// This is weird cause we're in anchor point 0.5
        let xRange = SKRange(lowerLimit: -size.halfWidth/2, upperLimit: size.halfWidth/2)
        let yRange = SKRange(lowerLimit: -size.halfHeight/2, upperLimit: size.halfHeight/2)
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = self
        
        camera?.constraints = [followConstraint/*, edgeConstraint*/]
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        entityManager?.didBegin(contact)
    }
}

extension GameScene: MotionManagerDelegate {
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat) {
        guard let sprite = self.playerShip.sprite() else { return }
        
        let moveVelocity = CGVector(dx: pitch, dy: roll)
        if let body = sprite.physicsBody {
            let newVelocity = body.velocity + moveVelocity
            body.velocity = self.normalizedVelocity(velocity: newVelocity)
        }
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


// MARK: - Touch handling
extension GameScene {
    
    /// Want to push the physics body similar to enemyPathFinding
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first?.location(in: self) else { return }
        guard let playerVector = playerShip.position?.vector_float() else { return }
        
        let playerNode = GKGraphNode2D.node(withPoint: playerVector)
        let touchNode = GKGraphNode2D.node(withPoint: touch.vector_float())
        obstacleGraph?.connectUsingObstacles(node: touchNode)
        obstacleGraph?.connectUsingObstacles(node: playerNode)
        
        let paths = obstacleGraph.graph.findPath(from: playerNode, to: touchNode)
        
        
    }
    
    private func runPlayerActions(with paths: [GKPath]) {
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
        let filter = obstacleGraph.graph.obstacles.sorted(by: { (first, second) -> Bool in
            return first.vertex(at: 0).x > second.vertex(at: 0).x
        })
        
        for v in filter {
//            print("\(v.vertex(at: 0)) \n")
        }
        
//        print("TOUCH \(touch)")
        let vertex = filter.first { (obstacle) -> Bool in
            let range: CountableClosedRange<Int> = -100...100
            let matchX = range ~= Int((obstacle.vertex(at: 0).x - Float(touch.x)))
            let matchY = range ~= Int((obstacle.vertex(at: 0).y - Float(touch.y)))
            return matchX && matchY
        }
        
        
    }
}

// MARK: - Game Scales
extension GameScene: MultiScaledScene {
    var sceneScale: (xScale: CGFloat, yScale: CGFloat) {
        return (2.0, 2.0)
    }
    
    var cameraScale: (xScale: CGFloat, yScale: CGFloat) {
        return (4.0, 4.0)
    }
}
