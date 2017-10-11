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
    
    func configure(with config: SpriteConfiguration) {
        guard let body = physicsBody else {
            conditionFailure(with: "Failed to unwrap physics body in configure method")
            return
        }
        
        body.categoryBitMask = config.categoryBitMask
        body.contactTestBitMask = config.contactTestBitMask
        body.collisionBitMask = config.collisionBitMask
        body.isDynamic = config.isDynamic
        body.affectedByGravity = config.affectedByGravity
        body.allowsRotation = config.allowsRotation
        body.fieldBitMask = config.fieldBitMask
    }
}

