//
//  SKScene+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 1/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKScene {
    
    func childNode<T>(withName name: CustomStringConvertible) -> T? {
        guard let node = childNode(withName: name.description) as? T else {
            assertionFailure("Failed to resolve node with name \(name.description)")
            return nil
        }
        
        return node
    }
    
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
    
    func isIpad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
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
    
    
    func createFixedJoint(with nodeA: SKNode?, nodeB: SKNode?, position: CGPoint) {
        guard let bodyA = nodeA?.physicsBody, let bodyB = nodeB?.physicsBody else {
            assertionFailure("Create fixed joint called with nil nodes")
            return
        }
        
        let joint = SKPhysicsJointFixed.joint(withBodyA: bodyA, bodyB: bodyB, anchor: position)
        physicsWorld.add(joint)
    }
}

protocol MultiScaledScene: class {
    var sceneScale: (xScale: CGFloat, yScale: CGFloat) { get }
    var cameraScale: (xScale: CGFloat, yScale: CGFloat) { get }
}

extension MultiScaledScene where Self: SKScene {
    var scaledHeight: CGFloat {
        return size.height * max(sceneScale.xScale, sceneScale.yScale)
    }
    
    var scaledWidth: CGFloat {
        return size.width * max(sceneScale.xScale, sceneScale.yScale)
    }
    
    var scaledHalfHeight: CGFloat {
        return size.halfHeight * max(sceneScale.xScale, sceneScale.yScale)
    }
    
    var scaledHalfWidth: CGFloat {
        return size.halfWidth * max(sceneScale.xScale, sceneScale.yScale)
    }
}
