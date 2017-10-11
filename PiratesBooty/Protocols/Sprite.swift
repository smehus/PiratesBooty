//
//  Sprite.swift
//  PiratesBooty
//
//  Created by scott mehus on 10/11/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol Sprite {
    var position: CGPoint? { get set }
    func sprite() -> SKSpriteNode?
}

extension Sprite where Self: GKEntity {
    
    var position: CGPoint? {
        get {
            return sprite()?.position
        }
        
        set {
            guard let point = newValue else {
                assertionFailure("Setting nil position")
                return
            }
            sprite()?.position = point
        }
    }
    
    func sprite() -> SKSpriteNode? {
        return component(ofType: SpriteComponent.self)?.node
    }
}
