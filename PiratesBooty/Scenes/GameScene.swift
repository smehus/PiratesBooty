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
    
    private var playerShip: Ship!
    
    private let attitudeMultiplier: Double = 30.0
    
    override func didMove(to view: SKView) {
        
        entityManager = EntityManager(scene: self)
        
        playerShip = Ship(shipType: .defaultShip)
        playerShip.position = CGPoint(x: 0, y: 0)
        playerShip.sprite()!.zRotation = CGFloat(90).degreesToRadians()
        entityManager.add(playerShip)
        
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
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        
        entityManager.update(delta)
    }
}
