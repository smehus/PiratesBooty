//
//  DirectionalComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/14/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol Directional {
    var directionOffset: CGFloat { get }
}

class DirectionalComponent: GKAgent2D, GKAgentDelegate {
    
    private let offset: CGFloat
    
    init(directional: Directional) {
        self.offset = directional.directionOffset
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    
        guard
            let sprite = entity?.component(ofType: SpriteComponent.self),
            let velocity = sprite.node.physicsBody?.velocity
        else {
            assertionFailure("Failed to find sprite component")
            return
        }
       
        let shortestAngle = shortestAngleBetween(sprite.node.zRotation, angle2: velocity.angle) + offset
        let rotationRadiansPerSec = 4.0 * π
        let amountToRotate = (min(rotationRadiansPerSec * CGFloat(seconds), abs(shortestAngle)))
        sprite.node.zRotation += shortestAngle.sign() * amountToRotate
    }
}
