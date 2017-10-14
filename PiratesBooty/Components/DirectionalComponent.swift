//
//  DirectionalComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/14/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class DirectionalComponent: GKAgent2D, GKAgentDelegate {
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    
        guard
            let sprite = entity?.component(ofType: SpriteComponent.self),
            let velocity = sprite.node.physicsBody?.velocity
        else {
            assertionFailure("Failed to find sprite component")
            return
        }
       
        let shortestAngle = shortestAngleBetween(sprite.node.zRotation, angle2: velocity.angle)
        let rotationRadiansPerSec = 4.0 * π
        let amountToRotate = min(rotationRadiansPerSec * CGFloat(seconds), abs(shortestAngle))
        sprite.node.zRotation += shortestAngle.sign() * amountToRotate
    }
}
