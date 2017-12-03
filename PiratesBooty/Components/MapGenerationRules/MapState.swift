//
//  MapState.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

enum MapState: NSString, CustomStringConvertible {
    
    /// Direct neighbors
    
    case incrementBottomRow = "incrementBottomRow"
    case incrementTopRow = "incrementTopRow"
    case incrementLeftColumn = "incrementLeftColumn"
    case incrementRightColumn = "incrementRightColumn"
    
    
    /// Corner neighbors
    
    case topRightCorner = "topRightCorner"
    case bottomRightCorner = "bottomRightCorner"
    
    case topLeftCorner = "topLeftCorner"
    case bottomLeftCorner = "bottomLeftCorner"
    
    var description: String {
        return rawValue as String
    }
    
    static var allStates: [MapState] {
        return [.incrementBottomRow,
                .incrementTopRow,
                .incrementLeftColumn,
                .incrementRightColumn,
                .topRightCorner,
                .bottomRightCorner,
                .topLeftCorner,
                .bottomLeftCorner]
    }
}
