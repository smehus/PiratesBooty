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
    
    var maps: [SKTileMapNode] = []
    var placeholderMap: PlaceholderMapNode?
    
    var mapName = ""
    
    var mapSize: CGSize {
        return maps.first?.mapSize ?? placeholderMap!.size
    }
    
    init(placeholder: PlaceholderMapNode) {
        self.placeholderMap = placeholder
        super.init()
        
        addChild(placeholder)
    }
    
    init(maps: [SKTileMapNode]) {
        self.maps = maps
        super.init()
        
        
        addChildren(children: maps)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMaps(maps: [SKTileMapNode]) {
        self.maps = maps
        addChildren(children: maps)
    }
}

