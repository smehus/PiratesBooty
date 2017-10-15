//
//  GameScene.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    private var entityManager: EntityManager!
    private var lastUpdatedTime: TimeInterval = 0
    private var motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    private var tileMap: SKTileMapNode!
    private var tileSet: SKTileSet!
    private var waterGroup: SKTileGroup!
    private var islandGroup: SKTileGroup!
    
    private var playerShip: Ship!
    
    private let attitudeMultiplier: Double = 30.0
    
    override func didMove(to view: SKView) {
        setupRequiredNodes()
        setupCamera()
        setupMotion()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        entityManager.update(delta)
    }
    
    private func setupRequiredNodes() {
        
        tileMap = childNode(withName: "tileMap") as! SKTileMapNode
        tileSet = SKTileSet(named: "PirateTileSet")
        
        
        
        
        entityManager = EntityManager(scene: self)
        
        playerShip = Ship(shipType: .defaultShip)
        playerShip.position = CGPoint(x: 0, y: 0)
        playerShip.sprite()!.zRotation = CGFloat(90).degreesToRadians()
        entityManager.add(playerShip)
        
    }
    
    private func setupMotion() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            let reference = motionManager.attitudeReferenceFrame
            motionManager.startDeviceMotionUpdates(using: reference, to: motionQueue, withHandler: { (motion, error) in
                guard let attitude = motion?.attitude else { return }
                print("ATTITUDE \(attitude)")
                
                guard let sprite = self.playerShip.sprite() else { return }
                OperationQueue.main.addOperation {
                    let modifiedPitch = CGFloat(attitude.pitch * abs(30.0))
                    let modifiedRoll = CGFloat(attitude.roll * abs(30.0))
                    let moveVelocity = CGVector(dx: modifiedPitch, dy: modifiedRoll)
                    if let body = sprite.physicsBody {
                        body.velocity = body.velocity + moveVelocity
                    }
                }
            })
        }
    }
    
    private func setupCamera() {
        let cam = SKCameraNode()
        cam.xScale = 2.0
        cam.yScale = 2.0
        addChild(cam)
        camera = cam
        
        ///
        /// Follow Shipe
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
