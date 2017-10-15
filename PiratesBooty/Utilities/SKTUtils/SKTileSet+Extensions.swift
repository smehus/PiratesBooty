//
//  SKTileSet+Extensions.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/15/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKTileSet {
    
    func groupWith(name: String) -> SKTileGroup? {
        guard let group = tileGroups.filter ({ $0.name == name }).first else {
            assertionFailure("No Tile Set Group With Name \(name)")
            return nil
        }
        
        return group
    }
}
