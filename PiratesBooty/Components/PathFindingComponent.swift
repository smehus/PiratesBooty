//
//  PathFindingComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 2/21/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

final class PathFindingComponent: GKComponent {

    private unowned let scene: GameScene
    private var currentMap: LayeredMap?
    
    var player: Ship {
        return scene.playerShip
    }
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        if currentMap == nil {
            guard let map = getCurrentMap(), !map.maps.isEmpty else { return }
            currentMap = map
            createObstacles()
        } else {
            guard let playerPosition = player.position else { return }
            let rules = [boundsLeft(), boundsRight(), boundsTop(), boundsBottom()]
            for rule in rules {
                if rule(playerPosition) {
                    currentMap = getCurrentMap()
                    createObstacles()
                }
            }
        }
    }
    
    private func createObstacles() {
        guard let layeredMap = currentMap else { return }
        var obstacles: [GKPolygonObstacle] = []
        for map in layeredMap.maps {
            for (center, texture) in LayeredMap.obstacleTiles(from: map) {
                obstacles.append(createPolygonObstacle(from: map, center: center, texture: texture))
            }
        }
        
//        print("ADDING OBSTACLES \(obstacles.count)")
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.scene.obstacleGraph?.addObstacles(obstacles)
        }
    }
    
    private func createPolygonObstacle(from map: SKTileMapNode, center: CGPoint, texture: SKTexture) -> GKPolygonObstacle {
        let point = map.convert(center, to: scene)
        
        let topRight = float2(Float(point.y + texture.size().halfHeight), Float(point.x + texture.size().halfWidth))
        let bottomRight = float2(Float(point.y - texture.size().halfHeight), Float(point.x + texture.size().halfWidth))
        let bottomLeft = float2(Float(point.y - texture.size().halfHeight), Float(point.x - texture.size().halfWidth))
        let topLeft = float2(Float(point.y + texture.size().halfHeight), Float(point.x - texture.size().halfWidth))
        
        return GKPolygonObstacle(points: [topRight, bottomRight, bottomLeft, topLeft])
    }
    
    private func getCurrentMap() -> LayeredMap? {
        let possibleNodes = scene.nodes(at: scene.playerShip.position!)
        let tileMap = possibleNodes.filter ({ $0 is SKTileMapNode || $0 is PlaceholderMapNode }).first
        return tileMap?.parent as? LayeredMap
    }
}

extension PathFindingComponent {
    private func boundsLeft() -> (CGPoint) -> Bool {
        return { [weak self] position in
            guard let map = self?.currentMap else { return false }
            return position.x < (map.position.x - map.mapSize.halfWidth)
        }
    }
    
    private func boundsRight() -> (CGPoint) -> Bool {
        return { [weak self] position in
            guard let map = self?.currentMap else { return false }
            return position.x > (map.position.x + map.mapSize.halfWidth)
        }
    }
    
    private func boundsTop() -> (CGPoint) -> Bool {
        return { [weak self] position in
            guard let map = self?.currentMap else { return false }
            return position.y > (map.position.y + map.mapSize.halfHeight)
        }
    }
    
    private func boundsBottom() -> (CGPoint) -> Bool {
        return { [weak self] position in
            guard let map = self?.currentMap else { return false }
            return position.y < (map.position.y - map.mapSize.halfHeight)
        }
    }
}
