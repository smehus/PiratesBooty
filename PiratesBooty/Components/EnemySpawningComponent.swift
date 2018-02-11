//
//  EnemySpawningComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 1/30/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import Foundation
import GameplayKit

// how to do this....
// Spawn based off of 

class EnemySpawnComponent: GKComponent {
    
    private unowned var scene: GameScene
    private var lastMap: LayeredMap?
    private let ruleSystem = GKRuleSystem()
    
    /// Number of maps the player has crossed
    private var numMapsTraveled = 0
    private var targetMapCount = Int.random(min: 1, max: 2)
    
    private var randomNumber: Int {
        return Int.random(min: 1, max: 2)
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
        checkSpawn()
    }
    
    private func checkSpawn() {
        guard let shipPosition = scene.playerShip.position else { return }
        let nodesAtShipPosition = scene.nodes(at: shipPosition)
        guard let currentMap = nodesAtShipPosition.filter ({ $0 is LayeredMap }).first as? LayeredMap else { return }
        
        if lastMap == nil {
            lastMap = currentMap
        }
        
        guard let lastPOS = lastMap?.position else { return }
        guard currentMap.position != lastPOS else { return }
        
        lastMap = currentMap
        
        numMapsTraveled += 1
        guard  targetMapCount <= numMapsTraveled else { return }
        guard spawnEnemyShip(map: currentMap) else { return }
        
        numMapsTraveled = 0
        targetMapCount = randomNumber
    }
    
    private func spawnEnemyShip(map: LayeredMap) -> Bool {
        guard let _ = findEmptyPosition(map: map) else { return false }
        
        
        return true
    }
    
    private func findEmptyPosition(map: LayeredMap) -> CGPoint? {
        guard let enumerator = map.maps.first else { return nil }
        
        for row in 0..<enumerator.numberOfRows {
            for column in 0..<enumerator.numberOfColumns {
                for tMap in map.maps {
                    guard let definition = tMap.tileDefinition(atColumn: column, row: row) else {
                        continue
                    }
                    
                    guard let name = definition.name else { continue }
                    
                    guard name == "water" else { return nil }
                }
            }
        }
        
        
        return nil
    }
    
}
