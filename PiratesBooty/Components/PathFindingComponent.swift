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
    
    let graph = GKMeshGraph()
    
    private unowned let scene: GameScene
    
    init(scene: GameScene) {
        self.scene = scene
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
}
