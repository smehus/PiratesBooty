//
//  CannonDamageComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 4/14/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import GameplayKit

final class CannonDamageComponent: GKComponent {
    
    private let collisionType: Collision
    
    init(collisionType: Collision) {
        self.collisionType = collisionType
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CannonDamageComponent: CollisionDetector {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let ship = entity as? Ship else { return }
        guard case Collision(rawValue: contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) = collisionType else { return }
        let contactPoint = contact.contactPoint
        
        
    }
}
