//
//  Array+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/27/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

extension Array {
    func random() -> Element {
        let idx = Int(arc4random_uniform(UInt32(count)))
        return self[idx]
    }
}
