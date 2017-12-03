//
//  MapGenerationRules.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

struct RuleSystemValues {
    static let map = "map"
    static let scene = "scene"
}

class MapGenRules {
  
    static func generateRules() -> [GKRule] {
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
        
        return [belowMinTileMapYRule,
                aboveMaxTileMapYRule,
                leftMaxTileMapRule,
                rightMaxTileMapRule,
                topRightCorner,
                bottomRightCorner,
                topLeftCorner,
                bottomLeftCorner]
    }
}
