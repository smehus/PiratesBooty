//
//  InfiniteMapComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/21/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

class InfiniteMapComponent: GKAgent2D {
    
    private let tileMap: SKTileMapNode!
    private let scene: GameScene!
    private let ruleSystem = GKRuleSystem()
    
    init(tileMap: SKTileMapNode, scene: GameScene) {
        self.tileMap = tileMap
        self.scene = scene
        super.init()
        
        setupRules()
    }
    
    private func setupRules() {
        let belowMinTileMapYRule = GKRule(blockPredicate: { (system) -> Bool in
            return (self.scene.camera!.position.y - self.scene.size.halfHeight) < -self.tileMap.mapSize.halfHeight
        }) { (system) in
            // Add new stuff
            print("BELOW STUFF")
        }
        
        ruleSystem.add(belowMinTileMapYRule)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
 
        ruleSystem.evaluate()
    }
}
