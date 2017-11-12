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
    case incrementLeftColumn = "incrementLeftColumn"
    case incrementRightColumn = "incrementRightColumn"
    
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
        static let mapName = "TILE_MAP"
        static let tileSetName = "PirateTiles"
        static let numberOfColumns = 48
        static let numberOfRows = 48
        static let tileSize = CGSize(width: 64, height: 64)
        static let threshholds: [NSNumber] = [-0.5, 0.0, 0.5]
    }
    
    private var currentMap: LayeredMap!
    private let scene: GameScene!
    private let ruleSystem = GKRuleSystem()
    private let source = GKPerlinNoiseSource()
    private var totalMapsGenerated = 0
    
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
        cleanMaps()
        ruleSystem.reset()
        ruleSystem.evaluate()
        
        for fact in ruleSystem.facts {
            guard let state = MapState(rawValue: fact as! NSString) else { continue }
            switch state {
            case .incrementBottomRow:
                addBottomRow()
            case .incrementTopRow:
                addTopRow()
            case .incrementLeftColumn:
                addLeftColumn()
            case .incrementRightColumn:
                addRightColumn()
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
            
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
        
            let bottomCameraEdge = scene.camera!.position.y - scene.scaledHalfHeight
            let bottomMapEdge = map.position.y - map.mapSize.halfHeight
            let cameraEdgeIsBelowMapEdge = bottomCameraEdge < bottomMapEdge
            let estimatedNextMapArea = CGPoint(x: map.position.x, y: bottomCameraEdge - scene.scaledHalfHeight)
            guard cameraEdgeIsBelowMapEdge else { return false }
            
            let existingMapsInArea = scene.nodes(at: estimatedNextMapArea).filter { $0 is LayeredMap }
            
            return existingMapsInArea.isEmpty
            
        }) { (system) in
            system.assertFact(MapState.incrementBottomRow.rawValue)
        }
        
        let aboveMaxTileMapYRule = GKRule(blockPredicate: { (system) -> Bool in
            let currentFacts = system.facts.map { MapState(rawValue: $0 as! NSString) }
            guard
                currentFacts.filter ({ $0 == .incrementBottomRow }).isEmpty,
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let playerBody = scene.playerShip.sprite()?.physicsBody,
                playerBody.velocity.dy > 0,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
            
            return (scene.camera!.position.y + scene.scaledHalfHeight) > (map.position.y + map.mapSize.halfHeight)
        }) { (system) in
            system.assertFact(MapState.incrementTopRow.rawValue)
        }
        
        
        let leftMaxTileMapRule = GKRule(blockPredicate: { (system) -> Bool in
            let currentFacts = system.facts.map { MapState(rawValue: $0 as! NSString) }
            guard
                currentFacts.filter ({ $0 == .incrementRightColumn }).isEmpty,
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let playerBody = scene.playerShip.sprite()?.physicsBody,
                playerBody.velocity.dx < 0,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
                else {
                    return false
            }
            
            return (scene.camera!.position.x - scene.scaledHalfWidth) < (map.position.x - map.mapSize.halfWidth)
            
        }) { (system) in
            system.assertFact(MapState.incrementLeftColumn.rawValue)
        }
        
        let rightMaxTileMapRule = GKRule(blockPredicate: { (system) -> Bool in
            let currentFacts = system.facts.map { MapState(rawValue: $0 as! NSString) }
            guard
                currentFacts.filter ({ $0 == .incrementLeftColumn }).isEmpty,
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let playerBody = scene.playerShip.sprite()?.physicsBody,
                playerBody.velocity.dx > 0,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
            
            return (scene.camera!.position.x + scene.scaledHalfWidth) > (map.position.x + map.mapSize.halfWidth)
        }) { (system) in
            system.assertFact(MapState.incrementRightColumn.rawValue)
        }
        
        ruleSystem.add([belowMinTileMapYRule/*, aboveMaxTileMapYRule, leftMaxTileMapRule, rightMaxTileMapRule*/])
    }
    
    private func addBottomRow() {
        let newMap = generateMap()
        newMap.position = CGPoint(x: currentMap.position.x, y: currentMap.position.y - currentMap.mapSize.height)
        scene.addChild(newMap)
        currentMap = newMap
        ruleSystem.state[RuleSystemValues.map] = newMap
    }
    
    private func addTopRow() {
        let newMap = generateMap()
        newMap.position = CGPoint(x: currentMap.position.x, y: currentMap.position.y + currentMap.mapSize.height)
        scene.addChild(newMap)
        currentMap = newMap
        ruleSystem.state[RuleSystemValues.map] = newMap
    }
    
    private func addLeftColumn() {
        let newMap = generateMap()
        newMap.position = CGPoint(x: currentMap.position.x - currentMap.mapSize.width, y: currentMap.position.y)
        scene.addChild(newMap)
        currentMap = newMap
        ruleSystem.state[RuleSystemValues.map] = newMap
    }
    
    private func addRightColumn() {
        let newMap = generateMap()
        newMap.position = CGPoint(x: currentMap.position.x + currentMap.mapSize.width, y: currentMap.position.y)
        scene.addChild(newMap)
        currentMap = newMap
        ruleSystem.state[RuleSystemValues.map] = newMap
    }
}

extension InfiniteMapComponent {
    private func cleanMaps() {
        let rules = [offScreenBottom(), offScreenTop(), offScreenRight(), offScreenLeft()]
        
        scene.enumerateChildNodes(withName: "\(MapValues.mapName)") { (node, stop) in
            guard let map = node as? LayeredMap else { return }
            
            for rule in rules {
                if rule(map) {
                    map.removeFromParent()
                    return
                }
            }
        }
    }
    
    private func offScreenBottom() -> ((LayeredMap) -> Bool) {
        return { map in
            return (map.position.y + map.mapSize.halfHeight) < (self.scene.camera!.position.y - self.scene.scaledHalfHeight)
        }
    }
    
    private func offScreenTop() -> ((LayeredMap) -> Bool) {
        return { map in
            return (map.position.y - map.mapSize.halfHeight) > (self.scene.camera!.position.y + self.scene.scaledHalfHeight)
        }
    }
    
    private func offScreenRight() -> ((LayeredMap) -> Bool) {
        return { map in
            return (map.position.x - map.mapSize.halfWidth) > (self.scene.camera!.position.x + self.scene.scaledHalfWidth)
        }
    }
    
    private func offScreenLeft() -> ((LayeredMap) -> Bool) {
        return { map in
            return (map.position.x + map.mapSize.halfWidth) < (self.scene.camera!.position.x - self.scene.scaledHalfWidth)
        }
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
        newMap.name = MapValues.mapName
        return newMap
    }
}
