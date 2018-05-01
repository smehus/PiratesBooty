//
//  LayeredMap.swift
//  PiratesBooty
//
//  Created by scott mehus on 11/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol TileOperation {
    func run(with map: SKTileMapNode, row: Int, column: Int)
    func finish(with map: SKTileMapNode)
}

enum MapGroups: String, CustomStringConvertible {
    case water = "water"
    case land = "land"
    
    /// Used in PirateTileSet.sks in the tiles user data to tag edge tiles
    /// Which I then use to only add physics bodies to land edges
    static let isEdgeKey = "isEdge"
    static let isLandKey = "isLand"
    
    var description: String {
        return rawValue
    }
}

private struct LandPhysics: PhysicsConfiguration {
    
    var categoryBitMask: Collision {
        return .land
    }
    
    var contactTestBitMask: Collision {
        return .ship
    }
    
    var collisionBitMask: Collision {
        return .ship
    }
    
    var isDynamic: Bool = false
    var affectedByGravity: Bool = false
}

final class LayeredMap: SKNode {
    
    var maps: [SKTileMapNode] = []
    var polygonSprites: [SKNode] = []
    var obstacleVertices: [[float2]] = []
    var placeholderMap: PlaceholderMapNode?
    var enemyCount = 0
    var hasAttachedObstacles = false
    var mapName = ""
    
    var mapSize: CGSize {
        return maps.first?.mapSize ?? placeholderMap!.size
    }
    
    var gameScene: GameScene {
        return scene as! GameScene
    }
    
    init(placeholder: PlaceholderMapNode, mapNumber: Int = 0) {
        self.placeholderMap = placeholder
        super.init()
        mapName = "\(mapNumber)"
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
    
    static func obstacleTiles(from map: SKTileMapNode) -> [(center: CGPoint, texture: SKTexture)] {
        var response: [(CGPoint, SKTexture)] = []
        for row in 0..<map.numberOfRows {
            for column in 0..<map.numberOfColumns {
                guard
                    let groupName = map.tileGroup(atColumn: column, row: row)?.name,
                    let group = MapGroups(rawValue: groupName),
                    case .land = group,
                    let tile = map.tileDefinition(atColumn: column, row: row),
                    let isEdge = tile.userData?[MapGroups.isEdgeKey] as? Bool,
                    isEdge,
                    let texture = tile.textures.first
                    else { continue }
                
                let center = map.centerOfTile(atColumn: column, row: row)
                response.append((center, texture))
            }
        }
        
        return response
    }
    
    func centerOfLandTile(at point: CGPoint) -> CGPoint? {
        
        let mapsWithLand = maps.flatMap { (map) -> CGPoint? in
            let column = map.tileColumnIndex(fromPosition: point)
            let row = map.tileRowIndex(fromPosition: point)
            
            guard column != UInt.max, row != UInt.max else { return nil }
            guard let groupName = map.tileGroup(atColumn: column, row: row)?.name else { return nil }
            guard let group = MapGroups(rawValue: groupName) else { return nil }
            guard case .land = group else { return nil }
            guard let definition = map.tileDefinition(atColumn: column, row: row) else { return nil }
            guard let name = definition.name else { return nil }
            guard name != "water" else { return nil }
            print("TILE AT POITN \(point) IS LAND GROUP")
            return map.centerOfTile(atColumn: column, row: row)
        }
        
        return mapsWithLand.first
    }
    
    func addMaps(maps: [SKTileMapNode]) {
        self.maps = maps
        addChildren(children: maps)
        configure(maps: maps)
    }

    
    /// Adds sprites for pathfind around obstacles
    private func configure(maps: [SKTileMapNode]) {
        for map in maps {
            for (center, texture) in LayeredMap.obstacleTiles(from: map) {
                guard polygonSprites.first (where : { $0.position == center }) == nil else {
                    return
                }
//                addSpriteForObstacle(map: map, center: center, texture: texture)
                createVerticeForObstacle(map: map, center: center, texture: texture)
            }
        }
    }
    
    private func createVerticeForObstacle(map: SKTileMapNode, center: CGPoint, texture: SKTexture) {
        let pos = map.convert(center, to: scene!)
        
        let offset = texture.size().halfWidth
        
        let topLeft = float2(Float(pos.x - offset), Float(pos.y + offset))
        let topRight = float2(Float(pos.x + offset), Float(pos.y + offset))
        let bottomRight = float2(Float(pos.x + offset), Float(pos.y - offset))
        let bottomLeft = float2(Float(pos.x - offset), Float(pos.y - offset))
        
        obstacleVertices.append([topLeft, topRight, bottomRight, bottomLeft])
    }
    
    private func addSpriteForObstacle(map: SKTileMapNode, center: CGPoint, texture: SKTexture) {
        let pos = map.convert(center, to: scene!)
        let sprite = SKSpriteNode(texture: nil, color: .white, size: texture.size())
        sprite.position = pos
        
        let physics = LandPhysics()
        let body = SKPhysicsBody(rectangleOf: texture.size(), center: CGPoint(x: 0, y: 0))
        body.isDynamic = physics.isDynamic
        body.affectedByGravity = physics.affectedByGravity
        body.categoryBitMask = physics.categoryBitMask.rawValue
        body.collisionBitMask = physics.collisionBitMask.rawValue
        body.contactTestBitMask = physics.contactTestBitMask.rawValue
        sprite.physicsBody = body
        sprite.move(toParent: map)
        polygonSprites.append(sprite)
    }
}

