//
//  Ship.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ShipType: Directional, PhysicsConfiguration {
    case playerShip
    case enemyShip
    
    var texture: SKTexture {
        return SKTexture(image: #imageLiteral(resourceName: "ship (1)"))
    }
    
    var directionOffset: CGFloat {
        return CGFloat(90).degreesToRadians()
     }
    
    var categoryBitMask: Collision {
        switch self {
        case .playerShip: return .ship
        case .enemyShip: return .enemyShip
        }
    }
    
    var contactTestBitMask: Collision {
        return [.land, .ship]
    }
    
    var collisionBitMask: Collision {
        return [.land, .ship]
    }
    
    var isDynamic: Bool {
        return true
    }
    
    var affectedByGravity: Bool {
        return false
    }
    
    var cannonPhysics: CannonPhysics {
        switch self {
        case .enemyShip: return .enemyFire
        case .playerShip: return .playerFire
        }
    }
    
    var cannonDamageContactBitMask: Collision {
        switch self {
        case .enemyShip: return .cannonEnemyShip
        case .playerShip: return .cannonShip
        }
    }
}

final class Ship: GKEntity, Sprite {
    
    static let MAX_VELOCITY: CGFloat = 500
    
    var shipType: ShipType
    
    private unowned let scene: GameScene
    
    init(scene: GameScene, shipType: ShipType) {
        self.scene = scene
        self.shipType = shipType
        
        super.init()
        
        let spriteComponent = SpriteComponent(texture: shipType.texture, physicsConfiguration: shipType)
        spriteComponent.node.name = "FUCK"
        addComponent(spriteComponent)
        addComponent(DirectionalComponent(directional: shipType))
        addComponent(ShipWreckComponent())
        addComponent(CannonProjectileComponent(scene: scene))
        
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
    
    func fireCannon(at vector: CGPoint) {
        component(ofType: CannonProjectileComponent.self)?.fire(at: vector)
    }
}

