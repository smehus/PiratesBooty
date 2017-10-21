//
//  World.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/21/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

enum Nodes: String, CustomStringConvertible {
    case waterGroup = "water"
    case islandGroup = "island"
    case tileSet = "tileSet"
    case tileMap = "tileMap"
    
    var description: String {
        return rawValue
    }
}

class World: GKEntity {
    
    private let tileMap: SKTileMapNode!
    private let waterGroup: SKTileGroup!
    private let islandGroup: SKTileGroup!
    
    init(scene: SKScene) {
        tileMap = scene.childNode(withName: Nodes.tileMap)
        waterGroup = tileMap.tileSet.groupWith(name: Nodes.waterGroup)
        islandGroup = tileMap.tileSet.groupWith(name: Nodes.islandGroup)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
