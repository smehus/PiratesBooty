//
//  BitMasks.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

struct Collision: OptionSet {
    let rawValue: UInt32
    
    /// Physics Categories
    static let ship = Collision(rawValue: 0x1 << 0)
    static let land = Collision(rawValue: 0x1 << 1)
    static let cannon = Collision(rawValue: 0x1 << 2)
    
    /// Collisions
    static let shipWreck: Collision = [.ship, .land]
    static let cannonShip: Collision = [.cannon, .ship]
}
