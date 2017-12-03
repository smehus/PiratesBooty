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
    
    
    /// Direct neighbors
    
    case incrementBottomRow = "incrementBottomRow"
    case incrementTopRow = "incrementTopRow"
    case incrementLeftColumn = "incrementLeftColumn"
    case incrementRightColumn = "incrementRightColumn"
    
    
    /// Corner neighbors
    
    case topRightCorner = "topRightCorner"
    case bottomRightCorner = "bottomRightCorner"
    
    case topLeftCorner = "topLeftCorner"
    case bottomLeftCorner = "bottomLeftCorner"
    
    var description: String {
        return rawValue as String
    }
    
    static var allStates: [MapState] {
        return [.incrementBottomRow,
                .incrementTopRow,
                .incrementLeftColumn,
                .incrementRightColumn,
                .topRightCorner,
                .bottomRightCorner,
                .topLeftCorner,
                .bottomLeftCorner]
    }
}

class InfiniteMapComponent: GKAgent2D {
    
    private struct RuleSystemValues {
        static let map = "map"
        static let scene = "scene"
    }
    
    private struct MapValues {
        struct NoiseMap {
            static let noiseSize: Double = 3.0
            static let sampleSize: Int32 = 200
        }
        
        static let mapName = "TILE_MAP"
        static let tileSetName = "PirateTiles"
        static let numberOfColumns = 48
        static let numberOfRows = 48
        static let tileSize = CGSize(width: 64, height: 64)
        static let threshholds: [NSNumber] = [0.0, 1.0]
        static let mapWidth: CGFloat = CGFloat(MapValues.numberOfColumns) * MapValues.tileSize.width
        static let mapHeight: CGFloat = CGFloat(MapValues.numberOfRows) * MapValues.tileSize.height
    }
    
    private let scene: GameScene!
    private let ruleSystem = GKRuleSystem()
    private let noise: GKNoise
    private let source: GKNoiseSource
    private let tileSet = SKTileSet(named: MapValues.tileSetName)
    private let mapGenerationQueue = DispatchQueue(label: "map_generation_queue")
    
    private var currentMap: LayeredMap? {
        let possibleNodes = scene.nodes(at: scene.playerShip.position!)
        let tileMap = possibleNodes.filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).first
        return tileMap?.parent as? LayeredMap
    }
    
    init(scene: GameScene) {
        self.scene = scene
        
//        source = GKPerlinNoiseSource(frequency: 0.5,
//                                     octaveCount: 3,
//                                     persistence: 5.0,
//                                     lacunarity: 2.0,
//                                     seed: Int32(50))
        
//        source = GKRidgedNoiseSource(frequency: 1.0,
//                                     octaveCount: 10,
//                                     lacunarity: 2.0,
//                                     seed: Int32(50))
        
        source = GKBillowNoiseSource(frequency: 6.0,
                                     octaveCount: 6,
                                     persistence: 10.0,
                                     lacunarity: 0.5,
                                     seed: Int32(2))
        
        noise = GKNoise(source, gradientColors:[-1: .red, 1: .green])
//        noise.invert()
        
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
        addMap(position: CGPoint(x: 0, y: 0))
        for state in MapState.allStates {
            addMap(state: state)
        }
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
    
            let estimatedNextMapArea = CGPoint(x: map.position.x, y: map.position.y - map.mapSize.height)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
            
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

            let estimatedNextMapArea = CGPoint(x: map.position.x, y: map.position.y + map.mapSize.height)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
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

            let estimatedNextMapArea = CGPoint(x: map.position.x - map.mapSize.width, y: map.position.y)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
            
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
            
            let estimatedNextMapArea = CGPoint(x: map.position.x + map.mapSize.width, y: map.position.y)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
        }) { (system) in
            system.assertFact(MapState.incrementRightColumn.rawValue)
        }
        
        let topRightCorner = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
                else {
                    return false
            }
            
            let estimatedNextMapArea = CGPoint(x: map.position.x + map.mapSize.width, y: map.position.y + map.mapSize.height)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
        }) { (system) in
            system.assertFact(MapState.topRightCorner.rawValue)
        }
        
        let bottomRightCorner = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
                else {
                    return false
            }
            
            let estimatedNextMapArea = CGPoint(x: map.position.x + map.mapSize.width, y: map.position.y - map.mapSize.height)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
        }) { (system) in
            system.assertFact(MapState.bottomRightCorner.rawValue)
        }
        
        let topLeftCorner = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
                else {
                    return false
            }
            
            let estimatedNextMapArea = CGPoint(x: map.position.x - map.mapSize.width, y: map.position.y + map.mapSize.height)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
        }) { (system) in
            system.assertFact(MapState.topLeftCorner.rawValue)
        }
        
        let bottomLeftCorner = GKRule(blockPredicate: { (system) -> Bool in
            guard
                let scene = system.state[RuleSystemValues.scene] as? GameScene,
                let map = system.state[RuleSystemValues.map] as? LayeredMap
                else {
                    return false
            }
            
            let estimatedNextMapArea = CGPoint(x: map.position.x - map.mapSize.width, y: map.position.y - map.mapSize.height)
            if scene.nodes(at: estimatedNextMapArea).filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).isEmpty {
                return true
            }
            
            return false
        }) { (system) in
            system.assertFact(MapState.bottomLeftCorner.rawValue)
        }
        
        ruleSystem.add([belowMinTileMapYRule,
                        aboveMaxTileMapYRule,
                        leftMaxTileMapRule,
                        rightMaxTileMapRule,
                        topRightCorner,
                        bottomRightCorner,
                        topLeftCorner,
                        bottomLeftCorner])
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
            
        case .topRightCorner:
            pos = CGPoint(x: currentMap.position.x + currentMap.mapSize.width, y: currentMap.position.y + currentMap.mapSize.height)
        case .bottomRightCorner:
            pos = CGPoint(x: currentMap.position.x + currentMap.mapSize.width, y: currentMap.position.y - currentMap.mapSize.height)
        case .topLeftCorner:
            pos = CGPoint(x: currentMap.position.x - currentMap.mapSize.width, y: currentMap.position.y + currentMap.mapSize.height)
        case .bottomLeftCorner:
            pos = CGPoint(x: currentMap.position.x - currentMap.mapSize.width, y: currentMap.position.y - currentMap.mapSize.height)
        }
        
        addMap(position: pos)
    }
    
    @discardableResult
    private func addMap(position: CGPoint) -> LayeredMap? {
        
        /// Check the position is within desired range to create a new map
        if let current = currentMap, abs(position.distanceTo(current.position)) > (MapValues.mapWidth * 3) {
            return nil
        }
        
        let placeholder = PlaceholderMapNode(color: .blue, size: CGSize(width: MapValues.mapWidth, height: MapValues.mapHeight))
        let newMap = LayeredMap(placeholder: placeholder)
        newMap.position = position
        newMap.name = MapValues.mapName
        scene.addChild(newMap)
        
        generateMapOnBackground(map: newMap) { (configuredMap) in }
        
        return newMap
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
    
    private func generateMapOnBackground(map: LayeredMap, completion: @escaping (LayeredMap) -> Void) {
        
        mapGenerationQueue.async {
            
            /// How man units offset is the current map from 0, 0
            var mapOriginOffset = vector_double2(Double(map.position.x / map.mapSize.width), Double(map.position.y / map.mapSize.height))
            mapOriginOffset = mapOriginOffset * MapValues.NoiseMap.noiseSize

            self.noise.move(by: vector_double3(mapOriginOffset.x, 0, mapOriginOffset.y))
            let noiseMap = GKNoiseMap(self.noise,
                                      size: vector_double2(MapValues.NoiseMap.noiseSize),
                                      origin: vector_double2(0, 0),
                                      sampleCount: vector_int2(MapValues.NoiseMap.sampleSize),
                                      seamless: false)
            
            /// Reset the noise field - the y value actually goes into the z axis - because of the way the slice is sampled?
            self.noise.move(by: vector_double3(-mapOriginOffset.x, 0, -mapOriginOffset.y))
            
            let generatedMaps = SKTileMapNode
                .tileMapNodes(tileSet: self.tileSet!,
                              columns: MapValues.numberOfColumns,
                              rows: MapValues.numberOfRows,
                              tileSize: MapValues.tileSize,
                              from: noiseMap,
                              tileTypeNoiseMapThresholds: MapValues.threshholds)
            

//            self.addDebugSprite(map: map, noiseMap: noiseMap)
            DispatchQueue.main.async {
                map.addMaps(maps: generatedMaps)
                completion(map)
            }
        }
    }
    
    private func addDebugSprite(map: LayeredMap, noiseMap: GKNoiseMap) {
        DispatchQueue.main.async {
            let texture = SKTexture(noiseMap: noiseMap)
            let sprite = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: MapValues.mapWidth, height: MapValues.mapHeight))
            map.addChild(sprite)
        }
    }
}
