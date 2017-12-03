//
//  SKSpriteNode+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 2/23/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    var spriteSize: CGSize? {
        guard let text = texture else {
            return nil
        }
        
        return text.size()
    }
    
    var halfSpriteHeight: CGFloat? {
        guard let text = texture else {
            return nil
        }
        
        let size = text.size()
        return size.height/2
    }
    
    func updateXScale() {
        guard let body = physicsBody else { return }
        if body.velocity.dx > 0 {
            xScale = 1
        } else if body.velocity.dx < 0 {
            xScale = -1
        }
    }
    
    func set(physicsConfiguration config: PhysicsConfiguration) {
        guard let text = texture else {
            assertionFailure("Sprite missing texture")
            return
        }
        
        physicsBody = SKPhysicsBody(texture: text, size: text.size())
        physicsBody?.categoryBitMask = config.categoryBitMask.rawValue
        physicsBody?.contactTestBitMask = config.contactTestBitMask.rawValue
        physicsBody?.isDynamic = config.isDynamic
        physicsBody?.affectedByGravity = config.affectedByGravity
        physicsBody?.collisionBitMask = config.collisionBitMask.rawValue
    }
}



