//
//  LayeredMap.swift
//  PiratesBooty
//
//  Created by scott mehus on 11/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

class LayeredMap: SKNode {
    
    let maps: [SKTileMapNode]
    
    var mapName = ""
    
    var mapSize: CGSize {
        return maps.first?.mapSize ?? CGSize(width: 0, height: 0)
    }
    
    init(maps: [SKTileMapNode]) {
        self.maps = maps
        super.init()
        
        
        addChildren(children: maps)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

