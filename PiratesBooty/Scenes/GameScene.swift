//
//  GameScene.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/10/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var entityManager: EntityManager!
    
    override func didMove(to view: SKView) {
        
        entityManager = EntityManager(scene: self)
        
        var ship = Ship(shipType: .defaultShip)
        ship.position = CGPoint(x: 0, y: 0)
        entityManager.add(ship)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
