//
//  Ship.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ShipType {
    case defaultShip
    
    var texture: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "ship (1)"))
    }
}

struct ShipPhysics: PhysicsConfiguration {
    var categoryBitMask: UInt32 { return 0 }
    var contactTestBitMask: UInt32 { return 0 }
    var collisionBitMask: UInt32 { return 0 }
    var isDynamic: Bool = true
    var affectedByGravity: Bool = false
}


class Ship: GKEntity, Sprite {
    
    init(shipType: ShipType) {
        super.init()
        
        let spriteComponent = SpriteComponent(texture: shipType.texture, physicsConfiguration: ShipPhysics())
        addComponent(spriteComponent)
        addComponent(DirectionalComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

