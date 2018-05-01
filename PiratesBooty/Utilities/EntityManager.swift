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

protocol ToucheDetector {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
}

protocol CollisionDetector {
    func didBegin(_ contact: SKPhysicsContact)
}

protocol MotionDetector {
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat)
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
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for component in components {
            if let detector = component as? ToucheDetector {
                detector.touchesBegan(touches, with: event)
            }
        }
    }
    
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat) {
        for component in components {
            if let detector = component as? MotionDetector {
                detector.didRecieveMotionUpdate(pitch: pitch, roll: roll)
            }
        }
    }
}

class EntityManager {
    
    // MARK: - Public
    
    var entities = Set<GKEntity>()
    var toRemove = Set<GKEntity>()
    
    
    // MARK: - Private
    
    private unowned var scene: SKScene
    
    lazy var componentSystems: [ComponentSystem] = {
        // Manages all instances of the DirectionalComponent
        let directional = ComponentSystem(componentClass: DirectionalComponent.self)
        let infiniteMapSystem = ComponentSystem(componentClass: InfiniteMapComponent.self)
        let shipWreckSystem = ComponentSystem(componentClass: ShipWreckComponent.self)
        let enemySpawnSystem = ComponentSystem(componentClass: EnemySpawnComponent.self)
        let pathFindingSystem = ComponentSystem(componentClass: PathFindingComponent.self)
        let enemyPathfindingSystem = ComponentSystem(componentClass: EnemyPathfindingComponent.self)
        let touchPathFinding = ComponentSystem(componentClass: PlayerTouchPathFindingComponent.self)
        let cannonBall = ComponentSystem(componentClass: CannonProjectileComponent.self)
        let motionSystem = ComponentSystem(componentClass: MotionResponderComponent.self)
        let cannonDamage = ComponentSystem(componentClass: CannonDamageComponent.self)
        return [directional,
                infiniteMapSystem,
                shipWreckSystem,
                enemySpawnSystem, 
                pathFindingSystem,
                enemyPathfindingSystem,
                touchPathFinding,
                motionSystem,
                cannonBall,
                cannonDamage]
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
    
    func removeOrphanComponents() {
        for system in componentSystems {
            for component in system.components {
                if component.entity == nil {
                    system.removeComponent(component)
                }
            }
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
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        componentSystems.forEach { (system) in
            system.touchesBegan(touches, with: event)
        }
    }
    
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat) {
        componentSystems.forEach { (system) in
            system.didRecieveMotionUpdate(pitch: pitch, roll: roll)
        }
    }
    
    func entity<T: GKEntity>() -> T? {
        return entities.first(where: { $0 is T }) as? T
    }
}
