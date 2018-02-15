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
    private unowned var entityManager: EntityManager
    
    private var lastMap: LayeredMap?
    private let ruleSystem = GKRuleSystem()
    
    /// Number of maps the player has crossed
    private var numMapsTraveled = 0
    private var targetMapCount = Int.random(min: 1, max: 2)
    
    private var randomNumber: Int {
        return Int.random(min: 1, max: 2)
    }
    
    init(scene: GameScene, entityManager: EntityManager) {
        self.scene = scene
        self.entityManager = entityManager
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
        guard currentMap.enemyCount == 0 else { return }
        guard spawnEnemyShip(map: currentMap) else { return }
        
        numMapsTraveled = 0
        targetMapCount = randomNumber
    }
    
    private func spawnEnemyShip(map: LayeredMap) -> Bool {
        guard let pos = findEmptyPosition(map: map) else { return false }
        
        let scenePosition = map.convert(pos, to: scene)
        print("*** Creating Enemy Ship at \(scenePosition) -> My Position \(scene.playerShip.position!)")
        var ship = Ship(shipType: .defaultShip)
        ship.position = scenePosition
        ship.sprite()?.zPosition = 10
        entityManager.add(ship)
        map.enemyCount += 1
        
        return true
    }

    private func findEmptyPosition(map: LayeredMap) -> CGPoint? {
        guard let enumerator = map.maps.first else { return nil }
        
        // Start at middle, and find water going forward in columns / rows
        if let point = findPoint(with: map,
                                 rowRange: stride(from: enumerator.numberOfRows/2, to: enumerator.numberOfRows, by: 1),
                                 columnRange: stride(from: enumerator.numberOfColumns/2, to: enumerator.numberOfColumns, by: 1))
        {
            return point
        }
        
        // Start at middle, and find water going BACKWARDS in columns / rows
        if let point = findPoint(with: map,
                                  rowRange: stride(from: enumerator.numberOfRows/2, to: 0, by: -1),
                                  columnRange: stride(from: enumerator.numberOfColumns/2, to: 0, by: -1))
        {
            return point
        }
        
        return nil
    }
    
    
    private func findPoint(with map: LayeredMap, rowRange: StrideTo<Int>, columnRange: StrideTo<Int>) -> CGPoint? {
        guard let baseMap = map.maps.first else {
            assertionFailure("❌ Couldn't find the first map in a layered amp")
            return nil
        }
        
        // Start at the middle and go forwards
        for row in rowRange {
            for column in columnRange {

                let isEmpty = map.maps.reduce(into: true, { (isWater, nextMap) in
                    if !isWater {
                        return
                    }

                    guard
                        let definition = nextMap.tileDefinition(atColumn: column, row: row),
                        let name = definition.name
                        else {
                            return
                    }

                    if name != "water" {
                        isWater = false
                    }
                })

                if isEmpty {
                    return baseMap.centerOfTile(atColumn: column, row: row)
                }
            }
        }
        
        return nil
    }
}
