//
//  SpriteComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol PhysicsConfiguration {
    var categoryBitMask: UInt32 { get }
    var contactTestBitMask: UInt32 { get }
    var collisionBitMask: UInt32 { get }
    var isDynamic: Bool { get }
    var affectedByGravity: Bool { get }
}

class SpriteComponent: GKComponent {
    
    let node: SKSpriteNode
    
    init(texture: SKTexture, physicsConfiguration: PhysicsConfiguration?) {
        node = SKSpriteNode(texture: texture, color: .white, size: texture.size())
        if let config = physicsConfiguration {
            node.set(physicsConfiguration: config)
        }
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
