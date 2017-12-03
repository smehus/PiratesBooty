//
//  ShipWreckComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

final class ShipWreckComponent: GKComponent {
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
}

extension ShipWreckComponent: CollisionDetector {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let ship = entity as? Ship else {
            assertionFailure("ShipWreckComponents should only be added to Ship entities")
            return
        }
        
        guard let collision = Collision(rawValue: contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) else {
            return
        }
        
        switch collision {
        case .shipWreck:
            break
        }
    }
}
