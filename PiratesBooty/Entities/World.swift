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
    case islandGroup = "land"
    case tileSet = "tileSet"
    case tileMap = "tileMap"
    
    var description: String {
        return rawValue
    }
}

class World: GKEntity {
    
    init(scene: GameScene) {
        super.init()
        addComponent(InfiniteMapComponent(scene: scene))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
