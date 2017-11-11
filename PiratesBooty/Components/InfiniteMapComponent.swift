//
//  InfiniteMapComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/21/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

private enum MapState: NSString, CustomStringConvertible {
    case incrementBottomRow = "incrementBottomRow"
    
    var description: String {
        return rawValue as String
    }
}

class InfiniteMapComponent: GKAgent2D {
    
    private var tileMap: SKTileMapNode!
    private let scene: GameScene!
    private let ruleSystem = GKRuleSystem()
    private var sceneHalfHeight: CGFloat {
        return scene.size.halfHeight * max(scene.camera!.xScale, scene.camera!.yScale)
    }
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
        
//        setupRules()
        setupNoise()
    }

    private func setupNoise() {
        let source = GKPerlinNoiseSource()
        let noise = GKNoise(source)
        let map = GKNoiseMap(noise)
        
        
        let generatedMaps = SKTileMapNode
            .tileMapNodes(tileSet: tileMap.tileSet,
                          columns: tileMap.numberOfColumns,
                          rows: tileMap.numberOfRows,
                          tileSize: tileMap.tileSize,
                          from: map,
                          tileTypeNoiseMapThresholds: [-0.5, 0.0, 0.5])
        
        
        scene.addChildren(children: generatedMaps)
    }
    
    private func setupRules() {
        
        ruleSystem.state.addEntries(from: ["scene": scene, "tileMap": tileMap])

        let belowMinTileMapYRule = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state["scene"] as? GameScene,
                let tileMap = system.state["tileMap"] as? SKTileMapNode
            else {
                return false
            }
            
            return (scene.camera!.position.y - self.sceneHalfHeight) < -tileMap.mapSize.halfHeight
        }) { (system) in
            system.assertFact(MapState.incrementBottomRow.rawValue)
        }
        
        

        ruleSystem.add(belowMinTileMapYRule)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        ruleSystem.reset()
        ruleSystem.evaluate()
        
        for fact in ruleSystem.facts {
            guard let state = MapState(rawValue: fact as! NSString) else { continue }
            switch state {
            case .incrementBottomRow:
                addBottomRow()
            }
        }
    }
    
    private func addBottomRow() {
        
    }
}
