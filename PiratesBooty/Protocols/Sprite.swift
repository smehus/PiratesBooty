//
//  Sprite.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

protocol Sprite {
    func sprite() -> SKSpriteNode?
}

extension Sprite where Self: GKEntity {
    func sprite() -> SKSpriteNode? {
        return component(ofType: SpriteComponent.self)?.node
    }
}
