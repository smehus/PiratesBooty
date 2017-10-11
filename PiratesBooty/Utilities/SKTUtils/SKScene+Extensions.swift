//
//  SKScene+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKScene {
    func zeroAnchoredCenter() -> CGPoint {
        let width = size.width / 2
        let height = size.height / 2
        return CGPoint(x: position.x + width, y: position.y + height)
    }
    
    var playableHeight: CGFloat {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        return isIpad() ? size.height : playableHeight
    }
    
    var playableMargin: CGFloat {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight) / 2.0
        return isIpad() ? 0 : playableMargin
    }
    
    var sceneMidPoint: CGPoint {
        let width = size.width / 2
        let height = size.height / 2
        return CGPoint(x: width, y: height)
    }
    
    var cameraSize: CGSize? {
        guard let camera = camera else { return nil }
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        
        let calculatedHeight = (UIDevice.current.userInterfaceIdiom == .pad) ? size.height : playableHeight
        let xValue = size.width * camera.xScale
        let yValue = calculatedHeight * camera.yScale
        return CGSize(width: xValue, height: yValue)
    }
    
    func addTestFrame(size: CGSize) {
        let testNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        testNode.fillColor = .clear
        testNode.strokeColor = .red
        testNode.lineWidth = 30
        addChild(testNode)
    }
    
    
    func addPhysicsBorders(size: CGSize) {
        
        let leftBorder = SKShapeNode(rect: CGRect(x: 0, y: size.height / 2, width: 1.0, height: size.height))
        let rightBorder = SKShapeNode(rect: CGRect(x: size.width - 1.0, y: size.height / 2, width: 1.0, height: size.height))

        for border in [leftBorder, rightBorder] {
            let body = SKPhysicsBody(rectangleOf: border.frame.size)
            body.affectedByGravity = false
            body.isDynamic = false
            body.categoryBitMask = PhysicsCategory.Ground
            body.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.enemy
            body.collisionBitMask = PhysicsCategory.Hero | PhysicsCategory.enemy
            border.physicsBody = body
            
            addChild(border)
        }
    }
    
    func createFixedJoint(with nodeA: SKNode?, nodeB: SKNode?, position: CGPoint) {
        guard let bodyA = nodeA?.physicsBody, let bodyB = nodeB?.physicsBody else {
            assertionFailure("Create fixed joint called with nil nodes")
            return
        }
        
        let joint = SKPhysicsJointFixed.joint(withBodyA: bodyA, bodyB: bodyB, anchor: position)
        physicsWorld.add(joint)
    }
}
