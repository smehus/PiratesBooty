//
//  BitMasks.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

/// Defines the primitive bit mask
struct PhysicsCategory {
    static let playerShip:           UInt32 = 0        // 00
    static let land:                 UInt32 = 0x1 << 1 // 01
    static let stub1:                UInt32 = 0x1 << 2 // 010
    static let stub2:                UInt32 = 0x1 << 3 // 0100
    static let stub3:                UInt32 = 0x1 << 4 // 01000
}

/// Abstracted colllision
enum Collision {
    
}
