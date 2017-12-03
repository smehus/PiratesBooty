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

protocol CollisionDetector {
    func didBegin(_ contact: SKPhysicsContact)
}

/// Subclass to support collision detection
class ComponentSystem: GKComponentSystem<GKComponent> {
    func didBegin(_ contact: SKPhysicsContact) {
        for component in components {
            if let detector = component as? CollisionDetector {
                detector.didBegin(contact)
            }
        }
    }
}

class EntityManager {
    
    // MARK: - Public
    
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    
    
    // MARK: - Private
    
    private let scene: SKScene
    
    lazy var componentSystems: [ComponentSystem] = {
        // Manages all instances of the DirectionalComponent
        let directional = ComponentSystem(componentClass: DirectionalComponent.self)
        let infiniteMapSystem = ComponentSystem(componentClass: InfiniteMapComponent.self)
        return [directional, infiniteMapSystem]
    }()
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func add(_ entity: GKEntity) {
        entities.insert(entity)
        
        if let sprite = entity.component(ofType: SpriteComponent.self)?.node {
            scene.addChild(sprite)
        }
        
        for system in componentSystems {
            // Looks through all of the components in the entity,
            // and adds any that match the class for the current iteration of the systems array
            system.addComponent(foundIn: entity)
        }
    }
    
    func remove(_ entity: GKEntity) {
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        
        entities.remove(entity)
        toRemove.insert(entity)
    }
    
    func update(_ deltaTime: CFTimeInterval) {
        componentSystems.forEach { (system) in
            system.update(deltaTime: deltaTime)
        }
        
        toRemove.forEach { (entity) in
            componentSystems.forEach({ (system) in
                system.removeComponent(foundIn: entity)
            })
        }
        
        toRemove.removeAll()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        componentSystems.forEach { (system) in
            system.didBegin(contact)
        }
    }
}
