//
//  ShipWreckComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/3/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

final class ShipWreckComponent: GKComponent {
    
    private unowned let scene: GameScene
    private var isColliding = false
    
    private var map: LayeredMap? {
        guard let playerPos = scene.playerShip.position else { return nil }
        let mapsAtPoint = scene.nodes(at: playerPos).filter { $0 is LayeredMap }
        return mapsAtPoint.first as? LayeredMap
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
        
        checkForCollision()
    }
    
    private func checkForCollision() {
        guard let sprite = scene.playerShip.sprite() else { return }
        guard let body = sprite.physicsBody else { return }
        if isLandTile() {
            if !isColliding {
                isColliding = true
                
                if let health = scene.playerShip.component(ofType: HealthComponent.self) {
                    health.takeDamage()
                }
                
                body.velocity = CGVector(dx: -body.velocity.dx, dy: -body.velocity.dy)
            }
        } else {
            isColliding = false
        }
    }
    
    private func isLandTile() -> Bool {
        guard let map = map else { return false }
        guard let pos = scene.playerShip.position else { return false }
        return map.mapContainsLand(at: pos)
    }
}
