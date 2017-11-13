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
    
    private let scene: GameScene!
    private let ruleSystem = GKRuleSystem()
    private let noise: GKNoise
    private let noiseMap: GKNoiseMap
    private let source = GKPerlinNoiseSource()
    private let tileSet = SKTileSet(named: MapValues.tileSetName)
    private let mapGenerationQueue = DispatchQueue(label: "map_generation_queue")
    
    private var currentMap: LayeredMap? {
        let possibleNodes = scene.nodes(at: scene.playerShip.position!)
        let tileMap = possibleNodes.filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).first
        return tileMap?.parent as? LayeredMap
    }
    
    init(scene: GameScene) {
        self.scene = scene
        noise = GKNoise(source)
        noiseMap = GKNoiseMap(noise)
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
        ruleSystem.state[RuleSystemValues.map] = currentMap
        ruleSystem.evaluate()
        
        for fact in ruleSystem.facts {
            guard let state = MapState(rawValue: fact as! NSString) else { continue }
            print("ADDING MAP \(fact)")
            addMap(state: state)
        }
    }

    private func setupFirstMap() {
        let firstMap = generateMap()
        scene.addChild(firstMap)
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
            guard bottomCameraEdge < bottomMapEdge else { return false }
            
            let estimatedNextMapArea = CGPoint(x: map.position.x, y: bottomCameraEdge - scene.scaledHalfHeight)
            guard scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty else { return false }
            
            return true
            
        }) { (system) in
            system.assertFact(MapState.incrementBottomRow.rawValue)
        }
        
        let aboveMaxTileMapYRule = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
            
            let cameraTopEdge = scene.camera!.position.y + scene.scaledHalfHeight
            let mapTopEdge = map.position.y + map.mapSize.halfHeight
            guard  cameraTopEdge > mapTopEdge else { return false }
            
            let estimatedNextMapArea = CGPoint(x: map.position.x, y: cameraTopEdge + scene.scaledHalfHeight)
            guard scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty else { return false }
            
            return true
        }) { (system) in
            system.assertFact(MapState.incrementTopRow.rawValue)
        }
        
        
        let leftMaxTileMapRule = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
                else {
                    return false
            }
            
            let cameraLeftEdge = scene.camera!.position.x - scene.scaledHalfWidth
            let mapLeftEdge = map.position.x - map.mapSize.halfWidth
            guard cameraLeftEdge < mapLeftEdge else { return false }
            
            let estimatedNextMapArea = CGPoint(x: cameraLeftEdge - scene.scaledHalfWidth, y: map.position.y)
           guard scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty else { return false }
            
            return true
            
        }) { (system) in
            system.assertFact(MapState.incrementLeftColumn.rawValue)
        }
        
        let rightMaxTileMapRule = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
            else {
                return false
            }
            
            let cameraRightEdge = scene.camera!.position.x + scene.scaledHalfWidth
            let mapRightEdge = map.position.x + map.mapSize.halfWidth
            guard cameraRightEdge > mapRightEdge else { return false }
            
            let estimatedNextMapArea = CGPoint(x: cameraRightEdge + scene.scaledHalfWidth, y: map.position.y)
            guard scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty else { return false }
            
            return true
        }) { (system) in
            system.assertFact(MapState.incrementRightColumn.rawValue)
        }
        
        ruleSystem.add([belowMinTileMapYRule, aboveMaxTileMapYRule, leftMaxTileMapRule, rightMaxTileMapRule])
    }
    
    private func addMap(state: MapState) {
        guard let currentMap = currentMap else { return }
        var pos: CGPoint
        switch state {
        case .incrementBottomRow:
            pos = CGPoint(x: currentMap.position.x, y: currentMap.position.y - currentMap.mapSize.height)
        case .incrementTopRow:
            pos = CGPoint(x: currentMap.position.x, y: currentMap.position.y + currentMap.mapSize.height)
        case .incrementLeftColumn:
            pos = CGPoint(x: currentMap.position.x - currentMap.mapSize.width, y: currentMap.position.y)
        case .incrementRightColumn:
            pos = CGPoint(x: currentMap.position.x + currentMap.mapSize.width, y: currentMap.position.y)
        }
        
        let map = addMap(position: pos)
        checkForLeftovers(map: map)
    }
    
    @discardableResult
    private func addMap(position: CGPoint) -> LayeredMap? {
        guard let currentMap = currentMap else { return nil }
        let placeholder = PlaceholderMapNode(color: .blue, size: currentMap.mapSize)
        let newMap = LayeredMap(placeholder: placeholder)
        newMap.position = position
        newMap.name = MapValues.mapName
        scene.addChild(newMap)
        
        generateMapOnBackground(map: newMap) { (configuredMap) in
            print("Map completed generation")
        }
        
        return newMap
    }
    
    private func checkForLeftovers(map: LayeredMap?) {
        guard let map = map else { return }
        let factorPoint = CGPoint(x: 0, y: map.mapSize.height)
        let positions = [map.position - factorPoint, map.position + factorPoint]
        for position in positions {
            guard scene.nodes(at: position).filter({ $0 is SKTileMapNode || $0 is PlaceholderMapNode}).isEmpty else { continue }
            addMap(position: position)
        }
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
            let mapTopEdge = map.position.y + map.mapSize.halfHeight
            let cameraBottomEdge = self.scene.camera!.position.y - self.scene.scaledHalfHeight
            
            return mapTopEdge < cameraBottomEdge
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
  
        let generatedMaps = SKTileMapNode
            .tileMapNodes(tileSet: tileSet!,
                          columns: MapValues.numberOfColumns,
                          rows: MapValues.numberOfRows,
                          tileSize: MapValues.tileSize,
                          from: noiseMap,
                          tileTypeNoiseMapThresholds: MapValues.threshholds)
        
        let newMap = LayeredMap(maps: generatedMaps)
        newMap.name = MapValues.mapName
        return newMap
    }
    
    private func generateMapOnBackground(map: LayeredMap, completion: @escaping (LayeredMap) -> Void) {
        
        mapGenerationQueue.async {
            let generatedMaps = SKTileMapNode
                .tileMapNodes(tileSet: self.tileSet!,
                              columns: MapValues.numberOfColumns,
                              rows: MapValues.numberOfRows,
                              tileSize: MapValues.tileSize,
                              from: self.noiseMap,
                              tileTypeNoiseMapThresholds: MapValues.threshholds)

            DispatchQueue.main.async {
                map.addMaps(maps: generatedMaps)
                completion(map)
            }
        }
    }
}
