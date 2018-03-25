//
//  World.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/21/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import GameplayKit
import SpriteKit

final class World: GKEntity {
    
    init(scene: GameScene, entityManager: EntityManager) {
        super.init()
        addComponent(InfiniteMapComponent(scene: scene))
        addComponent(EnemySpawnComponent(scene: scene, entityManager: entityManager))
        addComponent(PathFindingComponent(scene: scene))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
