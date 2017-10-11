//
//  Bool+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 9/2/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation


extension Bool {
    static func random() -> Bool {
        switch Int.random(min: 0, max: 1) {
        case 0:
            return false
        case 1:
            return true
        default: fatalError()
        }
    }
}
