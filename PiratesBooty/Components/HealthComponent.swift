//
//  HealthComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 4/15/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import GameplayKit

protocol Health {
    var currentHealth: Int { get set  }
    var numOfHearts: Int { get }
    var currentTexture: SKTexture? { get }
}

final class HealthCompnent: GKComponent {
    
    private var health: Health
    
    init(health: Health) {
        self.health = health
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
    
    func takeDamage() {
        health.currentHealth -= 1
        if
            let spriteComponent = entity?.component(ofType: SpriteComponent.self),
            let texture = health.currentTexture
        {
            spriteComponent.node.texture = texture
        }
        
        if
            let ship = entity as? Ship,
            ship.shipType == .playerShip,
            health.currentHealth <= 0
        {
            print("!!!!!!! GAME OVER !!!!!!!!!")
        }
    }
}
