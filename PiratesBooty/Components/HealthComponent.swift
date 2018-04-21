//
//  HealthComponent.swift
//  PiratesBooty
//
//  Created by scott mehus on 4/15/18.
//  Copyright © 2018 scott mehus. All rights reserved.
//

import GameplayKit

protocol HealthTexturable {
    func texture(for health: Int) -> SKTexture
}

final class HealthCompnent: GKComponent {

    private let maxHealth: Int
    private var currentHealth: Int
    private let texturable: HealthTexturable
    
    init(maxHealth: Int, texturable: HealthTexturable) {
        self.texturable = texturable
        self.maxHealth = maxHealth
        currentHealth = maxHealth
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
    
    func takeDamage() {
        currentHealth -= 1
        
        if let spriteComponent = entity?.component(ofType: SpriteComponent.self) {
            spriteComponent.set(texture: texturable.texture(for: currentHealth))
        }
    
        if
            let ship = entity as? Ship,
            case .playerShip = ship.shipType,
            currentHealth <= 0
        {
            print("!!!!!!! GAME OVER !!!!!!!!!")
        }
    }
}
