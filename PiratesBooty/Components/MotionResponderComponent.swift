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
    
    private var isPaused: Bool {
        return countDown > 0
    }
    
    private var countDown: TimeInterval = 0 {
        didSet {
            if countDown < 0 {
                countDown = 0
                return
            }
        }
    }
    
    func pause(for interval: TimeInterval) {
        countDown = interval
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if countDown > 0 {
            countDown -= seconds
        }
    }
}

extension MotionResponderComponent: MotionDetector {
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat) {
        guard !isPaused else { return }
        guard let ship = entity as? Ship, let sprite = ship.sprite() else { return }
        
        let moveVelocity = CGVector(dx: pitch, dy: roll)
        if let body = sprite.physicsBody {
//            let newVelocity = body.velocity + moveVelocity
            let newVelocity = moveVelocity * 20
            body.velocity = normalizedVelocity(velocity: newVelocity)
        }
    }
}
