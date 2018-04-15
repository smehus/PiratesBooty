//
//  CannonProjectileComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 4/14/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import GameplayKit

enum CannonPhysics: PhysicsConfiguration {
    case playerFire
    case enemyFire
    
    var categoryBitMask: Collision {
        return .cannon
    }
    
    var contactTestBitMask: Collision {
        switch self {
        case .playerFire: return .enemyShip
        case .enemyFire: return .ship
        }
    }
    
    var collisionBitMask: Collision {
        switch self {
        case .playerFire: return .enemyShip
        case .enemyFire: return .ship
        }
    }
    
    var isDynamic: Bool { return true }
    var affectedByGravity: Bool { return false }
}

final class CannonProjectileComponent: GKComponent {
    
    private weak var scene: GameScene?
    
    private var ship: Ship {
        return entity as! Ship
    }
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fire(at vector: CGPoint) {

        let cannon = createCannon()
        scene?.addChild(cannon)
        
        // Not working probably because its centered on the ship - colliding with the ship
        let offset = vector - cannon.position
        let direction = offset.normalized()
        let velocity = direction * 1000
        print("FIRING CANNON AT VELOCITY \(velocity)")
        cannon.physicsBody?.velocity = CGVector(point: velocity)
        
        cannon.run(SKAction.removeFromParentAfterDelay(2.0))
    }
    
    private func createCannon() -> SKSpriteNode {
        let texture = SKTexture(image: #imageLiteral(resourceName: "cannonBall"))
        let sprite = SKSpriteNode(texture: texture, color: .white, size: texture.size() * 2)
        sprite.position = ship.position!
        
        let physics = SKPhysicsBody(circleOfRadius: texture.size().height)
        sprite.physicsBody = physics
        sprite.set(physicsConfiguration: ship.shipType.cannonPhysics)
        
        return sprite
    }
}

extension CannonProjectileComponent: ToucheDetector {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard case .playerShip = ship.shipType else { return }
        guard let touch = touches.first else { return }
        guard let gameScene = scene else { return }
        let location = touch.location(in: gameScene)
        fire(at: location)
    }
}

