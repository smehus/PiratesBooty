//
//  Assert+SKNode.swift
//  GravityWizard2
//
//  Created by scott mehus on 5/29/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit

extension SKNode {
    public func conditionFailure(with message: String) {
        let assertionMessage = "\(type(of: self)): \(message))"
        assertionFailure(assertionMessage)
    }
}
