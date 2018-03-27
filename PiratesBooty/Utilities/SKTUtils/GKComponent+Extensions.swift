//
//  GKComponent+Extensions.swift
//  PiratesBooty
//
//  Created by Scott Mehus on 3/26/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

extension GKComponent {
    func normalizedVelocity(velocity: CGVector) -> CGVector {
        var y: CGFloat
        var x: CGFloat
        if velocity.dx < -Ship.MAX_VELOCITY {
            x = -Ship.MAX_VELOCITY
        } else if velocity.dx > Ship.MAX_VELOCITY {
            x = Ship.MAX_VELOCITY
        } else {
            x = velocity.dx
        }
        
        if velocity.dy < -Ship.MAX_VELOCITY {
            y = -Ship.MAX_VELOCITY
        } else if velocity.dy > Ship.MAX_VELOCITY {
            y = Ship.MAX_VELOCITY
        } else {
            y = velocity.dy
        }
        
        return CGVector(dx: x, dy: y)
    }
}
