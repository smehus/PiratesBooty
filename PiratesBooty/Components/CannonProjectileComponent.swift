//
//  CannonProjectileComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 4/14/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import GameplayKit

struct CannonPhysics: PhysicsConfiguration {
    var categoryBitMask: Collision { return .cannon }
    var contactTestBitMask: Collision { return .ship }
    var collisionBitMask: Collision { return .ship }
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
        let action = SKAction.move(to: vector, duration: 2.0)
        scene?.addChild(cannon)
        
        cannon.run(action)
    }
    
    private func createCannon() -> SKSpriteNode {
        let texture = SKTexture(image: #imageLiteral(resourceName: "cannonBall"))
        let sprite = SKSpriteNode(texture: texture, color: .white, size: texture.size() * 2)
        sprite.position = ship.position!
        
        let physics = SKPhysicsBody(circleOfRadius: texture.size().halfHeight)
        sprite.physicsBody = physics
        sprite.set(physicsConfiguration: CannonPhysics())
        
        return sprite
    }
}


