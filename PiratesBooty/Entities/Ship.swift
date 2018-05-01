//
//  Ship.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit


enum ShipStyle: String, HealthTexturable {
    case plain = "plain"
    case black
    case red
    case green
    case blue
    case yellow
    
    var baseName: String {
        return rawValue
    }
    
    func texture(for health: Int) -> SKTexture {
        let normalizedHealth = health >= 0 ? health : 0
        let texture = SKTexture(imageNamed: "\(baseName)\(normalizedHealth)")
        return texture
    }
}

enum ShipType: Directional, PhysicsConfiguration, Equatable {
    case playerShip(style: ShipStyle)
    case enemyShip(style: ShipStyle)
    
    var style: ShipStyle {
        switch self {
        case .playerShip(let style), .enemyShip(let style):
            return style
        }
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
    
    static func ==(lhs: ShipType, rhs: ShipType) -> Bool {
        switch (lhs, rhs) {
        case (.playerShip, .playerShip): return true
        case (.enemyShip, .enemyShip): return true
        default: return false
        }
    }
}

final class Ship: GKEntity, Sprite {
    
    static let MAX_VELOCITY: CGFloat = 500
    static let MAX_HEALTH: Int = 3
    
    var shipType: ShipType
    weak var scene: GameScene?
    
    init(scene: GameScene, shipType: ShipType) {
        self.scene = scene
        self.shipType = shipType
        
        super.init()
        
        let spriteComponent = SpriteComponent(texture: shipType.style.texture(for: Ship.MAX_HEALTH), physicsConfiguration: shipType)
        addComponent(spriteComponent)
        addComponent(DirectionalComponent(directional: shipType))
        addComponent(ShipWreckComponent(scene: scene))
        addComponent(CannonProjectileComponent(scene: scene))
        addComponent(CannonDamageComponent(scene: scene))
        addComponent(HealthComponent(maxHealth: Ship.MAX_HEALTH, texturable: shipType.style))
        
        
        switch shipType {
        case .enemyShip:
            addComponent(EnemyPathfindingComponent(scene: scene))
        case .playerShip:
//            addComponent(PlayerTouchPathFindingComponent(scene: scene))
            addComponent(MotionResponderComponent())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fireCannon(at vector: CGPoint) {
        component(ofType: CannonProjectileComponent.self)?.fire(at: vector)
    }
    
    func die() {
        switch shipType {
        case .enemyShip:
            removeComponent(ofType: HealthComponent.self)
            removeComponent(ofType: EnemyPathfindingComponent.self)
            removeComponent(ofType: CannonProjectileComponent.self)
            removeComponent(ofType: CannonDamageComponent.self)
            
            scene?.entityManager.removeOrphanComponents()
            
            
            if let world: World = scene?.entityManager.entity() as? World {
                world.component(ofType: EnemySpawnComponent.self)?.enemyDied()
            }
            
            
        case .playerShip:
            print("!!!!! GAME OVER !!!!!")
        }
    }
}

