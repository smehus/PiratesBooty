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
    
    private unowned let scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CannonDamageComponent: CollisionDetector {
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let sprite = entity as? Sprite, let spriteNode = sprite.sprite(), let physicsBody = spriteNode.physicsBody else { return }
        
        // Check to make sure the contact node is the same node as the entity
        guard let contactNode = contact.bodyA.categoryBitMask == physicsBody.categoryBitMask ? contact.bodyA.node : contact.bodyB.node else { return }
        guard contactNode == spriteNode else { return }
        
        // bit mask for entity
        guard let entityCollision = Collision(value: physicsBody.categoryBitMask) else { return }
        
        // Bitmask for collision of two physics bodies
        guard let collision = Collision(value: contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask) else { return }
        
        // Make sure the collision bit mask contains the entities bitmask
        guard collision.contains(entityCollision) else { return }
        
        switch collision {
        case .cannonEnemyShip:
            fallthrough
        case .cannonShip:
            cannonShipCollision(contact: contact)
        default:
            break
        }
    }
    
    private func cannonShipCollision(contact: SKPhysicsContact) {
        // Make sure we're acting on the correct sprite
        guard let ship = entity as? Ship,
            let sprite = ship.sprite(),
            let body = sprite.physicsBody,
            let cannon = contact.bodyA.categoryBitMask == body.categoryBitMask ? contact.bodyB.node : contact.bodyA.node
        else {
            assertionFailure("Cannon missing from contact")
            return
        }
        
        cannon.removeFromParent()
        
        let point = scene.convert(contact.contactPoint, to: ship.sprite()!)
        let explosion = createExplosion(at: point)
        sprite.addChild(explosion)
        
        let textures: [Explosion] = [.small, .medium, .large]
        let action = SKAction.animate(with: textures.map ({ $0.texture }), timePerFrame: 0.15, resize: true, restore: false)
        let removal = SKAction.removeFromParent()
        let sequence = SKAction.sequence([action, action.reversed(), removal])
        explosion.run(sequence)
        
        damageHealth()
    }
    
    private func createExplosion(at point: CGPoint) -> SKSpriteNode {
        let explosion = SKSpriteNode(texture: Explosion.small.texture)
        explosion.position = point
        explosion.zPosition = 100
        
        return explosion
    }
    
    private func damageHealth() {
        guard let healthComponent = entity?.component(ofType: HealthComponent.self) else {
            assertionFailure("Failed to retrieve health componenet when taking damage")
            return
        }
        
        healthComponent.takeDamage()
    }
}
