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
    
    override func didMove(to view: SKView) {
        
        entityManager = EntityManager(scene: self)
        
        playerShip = Ship(shipType: .defaultShip)
        playerShip.position = CGPoint(x: 0, y: 0)
        entityManager.add(playerSHip)
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            let reference = motionManager.attitudeReferenceFrame
            motionManager.startDeviceMotionUpdates(using: reference, to: motionQueue, withHandler: { (motion, error) in
                OperationQueue.main.addOperation {
                    // Update ship
                }
            })
            
        }
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime = lastUpdatedTime
        lastUpdatedTime = currentTime
        
        entityManager.update(delta)
    }
}
