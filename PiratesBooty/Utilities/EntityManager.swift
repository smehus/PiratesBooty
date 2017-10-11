//
//  EntityManager.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
    
    // MARK: - Public
    
    var entities = Set<GKEntity>()
    
    
    // MARK: - Private
    
    private let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        if let sprite = entity.component(ofType: SpriteComponent.self)?.node {
            scene.addChild(sprite)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        
        entities.remove(entity)
    }
}
