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

class LayeredMap: SKNode {
    
    var maps: [SKTileMapNode] = []
    var polygonObstacles: [GKPolygonObstacle] = []
    var polygonSprites: [SKNode] = []
    var placeholderMap: PlaceholderMapNode?
    var enemyCount = 0
    
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
    
    func addMaps(maps: [SKTileMapNode]) {
        self.maps = maps
        addChildren(children: maps)
        
        configure(maps: maps)
    }
    
    
    private func configure(maps: [SKTileMapNode]) {
        for map in maps {
            var physicsBodies: [SKPhysicsBody] = []
            
            for (center, texture) in LayeredMap.obstacleTiles(from: map) {
                let pos = map.convert(center, to: scene!)
                let sprite = SKSpriteNode(texture: nil, color: .white, size: texture.size())
                sprite.position = pos
                
                let body = SKPhysicsBody(rectangleOf: texture.size(), center: CGPoint(x: 0, y: 0))
                sprite.physicsBody = body
                sprite.move(toParent: map)
                
                
                polygonSprites.append(sprite)
                physicsBodies.append(body)
            }
            
            print("*** ADDING OBSTACLES NODES TO GRAPH FOR MAP #: \(mapName)")
            gameScene.obstacleGraph.addNodes(polygonSprites, fromSource: mapName)
        }
    }
}

