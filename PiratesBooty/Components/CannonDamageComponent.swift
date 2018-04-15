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
        
        // remove cannon
        let cannon = contact.bodyA.categoryBitMask == ship.sprite()!.physicsBody!.categoryBitMask ? contact.bodyB.node : contact.bodyA.node
        cannon?.removeFromParent()
        
        let point = scene.convert(contact.contactPoint, to: ship.sprite()!)
        let explosion = createExplosion(at: point)
        ship.sprite()?.addChild(explosion)
        
        let textures: [Explosion] = [.small, .medium, .large]
        let action = SKAction.animate(with: textures.map ({ $0.texture }), timePerFrame: 0.15, resize: true, restore: false)
        let removal = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action, action.reversed(), removal])
        explosion.run(sequence)
    }
    
    func createExplosion(at point: CGPoint) -> SKSpriteNode {
        let explosion = SKSpriteNode(texture: Explosion.small.texture)
        explosion.position = point
        explosion.zPosition = 100
        
        return explosion
    }
}
