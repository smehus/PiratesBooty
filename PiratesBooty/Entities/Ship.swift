//
//  Ship.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ShipType: Directional {
    case playerShip
    case enemyShip
    
    var texture: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "ship (1)"))
    }
    
    var directionOffset: CGFloat {
        return CGFloat(90).degreesToRadians()
     }
}

struct ShipPhysics: PhysicsConfiguration {
    var categoryBitMask: Collision {
        return .ship
    }
    
    var contactTestBitMask: Collision {
        return [.land, .ship]
    }
    
    var collisionBitMask: Collision {
        return [.land, .ship]
    }
    
    var isDynamic: Bool = true
    var affectedByGravity: Bool = false
}


class Ship: GKEntity, Sprite {
    
    static let MAX_VELOCITY: CGFloat = 500
    
    private unowned let scene: GameScene
    
    init(scene: GameScene, shipType: ShipType) {
        self.scene = scene
        super.init()
        
        let spriteComponent = SpriteComponent(texture: shipType.texture, physicsConfiguration: ShipPhysics())
        spriteComponent.node.name = "FUCK"
        addComponent(spriteComponent)
        addComponent(DirectionalComponent(directional: shipType))
        addComponent(ShipWreckComponent())
        
        switch shipType {
        case .enemyShip:
            addComponent(EnemyPathfindingComponent(scene: scene))
        case .playerShip:
            addComponent(PlayerTouchPathFindingComponent(scene: scene))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

