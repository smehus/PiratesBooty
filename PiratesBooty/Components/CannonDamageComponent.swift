//
//  CannonDamageComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 4/14/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import GameplayKit

private enum Explosion {
    case large
    case medium
    case small
    
    var texture: SKTexture {
        switch self {
        case .large: return SKTexture(image: #imageLiteral(resourceName: "largeExplosion"))
        case .medium: return SKTexture(image: #imageLiteral(resourceName: "mediumExplosion"))
        case .small: return SKTexture(image: #imageLiteral(resourceName: "smallExplosion"))
        }
    }
}

final class CannonDamageComponent: GKComponent {
    
    private let collisionType: Collision
    private unowned let scene: GameScene
    
    init(scene: GameScene, collisionType: Collision) {
        self.collisionType = collisionType
        self.scene = scene
        
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
        let explosion = createExplosion(at: contact.contactPoint)
        
        scene.addChild(explosion)
    }
    
    func createExplosion(at point: CGPoint) -> SKSpriteNode {
        let explosion = SKSpriteNode(texture: Explosion.small.texture, color: .white, size: Explosion.small.texture.size())
        explosion.position = point
        explosion.zPosition = 10
        return explosion
    }
}
