//
//  BitMasks.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

struct ShipCategory: Equatable, ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = UInt32
    
    init() {
        
    }
    
    init(integerLiteral value: IntegerLiteralType) {
        
    }
    
    static func ==(lhs: ShipCategory, rhs: ShipCategory) -> Bool {
        return false
    }
}

/// Defines the primitive bit mask
struct PhysicsCategory {
    static let ship:                 UInt32 = 0        // 00
    static let land:                 UInt32 = 0x1 << 1 // 01
    static let stub1:                UInt32 = 0x1 << 2 // 010
    static let stub2:                UInt32 = 0x1 << 3 // 0100
    static let stub3:                UInt32 = 0x1 << 4 // 01000
}

struct Collision: OptionSet {
    let rawValue: UInt32
    
    static let shipWreck = Collision(rawValue: PhysicsCategory.ship | PhysicsCategory.land)
}
