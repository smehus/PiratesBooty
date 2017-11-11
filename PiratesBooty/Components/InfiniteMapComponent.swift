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
    case incrementTopRow = "incrementTopRow"
    
    var description: String {
        return rawValue as String
    }
}

class InfiniteMapComponent: GKAgent2D {
    
    private struct RuleSystemValues {
        static let map = "map"
        static let scene = "scene"
    }
    
    private struct MapValues {
        static let tileSetName = "PirateTiles"
        static let numberOfColumns = 24
        static let numberOfRows = 24
        static let tileSize = CGSize(width: 64, height: 64)
        static let threshholds: [NSNumber] = [-0.5, 0.0, 0.5]
    }
    
    private var currentMap: LayeredMap!
    private let scene: GameScene!
    private let ruleSystem = GKRuleSystem()
    private let source = GKPerlinNoiseSource()
    private var totalMapsGenerated = 0
    private var sceneHalfHeight: CGFloat {
        return scene.size.halfHeight * max(scene.camera!.xScale, scene.camera!.yScale)
    }
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
        
        setupFirstMap()
        setupRules()
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
            case .incrementTopRow:
                addTopRow()
            }
        }
    }

    private func setupFirstMap() {
        let firstMap = generateMap()
        scene.addChild(firstMap)
        currentMap = firstMap
    }
    
    private func setupRules() {
        guard let currentMap = self.currentMap else { return }
        ruleSystem.state.addEntries(from: [RuleSystemValues.scene: scene, RuleSystemValues.map: currentMap])

        let belowMinTileMapYRule = GKRule(blockPredicate: { (system) -> Bool in
            
            let currentFacts = system.facts.map { MapState(rawValue: $0 as! NSString) }
            guard
                currentFacts.filter ({ $0 == .incrementTopRow }).isEmpty,
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
        
            return (scene.camera!.position.y - self.sceneHalfHeight) < (map.position.y - map.mapSize.halfHeight)
        }) { (system) in
            system.assertFact(MapState.incrementBottomRow.rawValue)
        }
        
        let aboveMaxTileMapYRule = GKRule(blockPredicate: { (system) -> Bool in
            let currentFacts = system.facts.map { MapState(rawValue: $0 as! NSString) }
            guard
                currentFacts.filter ({ $0 == .incrementBottomRow }).isEmpty,
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
            
            return (scene.camera!.position.y + self.sceneHalfHeight) > (map.position.y + map.mapSize.halfHeight)
        }) { (system) in
            system.assertFact(MapState.incrementTopRow.rawValue)
        }
        
        ruleSystem.add([belowMinTileMapYRule, aboveMaxTileMapYRule])
    }
    
    private func addBottomRow() {
        let newMap = generateMap()
        newMap.position = CGPoint(x: currentMap.position.x, y: currentMap.position.y - currentMap.mapSize.height)
        scene.addChild(newMap)
        currentMap = newMap
        ruleSystem.state["map"] = newMap
    }
    
    private func addTopRow() {
        let newMap = generateMap()
        newMap.position = CGPoint(x: currentMap.position.x, y: currentMap.position.y + currentMap.mapSize.height)
        scene.addChild(newMap)
        currentMap = newMap
        ruleSystem.state["map"] = newMap
    }
}

extension InfiniteMapComponent {
    private func generateMap() -> LayeredMap {
        totalMapsGenerated += 1
        let tileSet = SKTileSet(named: MapValues.tileSetName)
        let noise = GKNoise(source)
        let map = GKNoiseMap(noise)
        
        let generatedMaps = SKTileMapNode
            .tileMapNodes(tileSet: tileSet!,
                          columns: MapValues.numberOfColumns,
                          rows: MapValues.numberOfRows,
                          tileSize: MapValues.tileSize,
                          from: map,
                          tileTypeNoiseMapThresholds: MapValues.threshholds)
        
        let newMap = LayeredMap(maps: generatedMaps)
        newMap.mapName = "Map # \(totalMapsGenerated)"
        return newMap
    }
}
