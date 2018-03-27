//
//  MotionResponderComponent.swift
//  PiratesBooty
//
//  Created by Scott Mehus on 3/26/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

final class MotionResponderComponent: GKComponent {
    
}

extension MotionResponderComponent: MotionDetector {
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat) {
        guard let ship = entity as? Ship, let sprite = ship.sprite() else { return }
        
        let moveVelocity = CGVector(dx: pitch, dy: roll)
        if let body = sprite.physicsBody {
            let newVelocity = body.velocity + moveVelocity
            body.velocity = normalizedVelocity(velocity: newVelocity)
        }
    }
}
