//
//  NSDictionary+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 7/26/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import Foundation

extension NSMutableDictionary {
    
    subscript<T: StringInitable>(accessor: UserDataAccessor) -> T? {
        get {
            guard let value = self[accessor.key] as? String else {
                return nil
            }
            
            return  T.init(string: value)
        }
        
        set {
            self[accessor.key] = newValue
        }
    }
}
