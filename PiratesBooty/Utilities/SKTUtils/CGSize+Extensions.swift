//
//  CGSize+Extensions.swift
//  GravityWizard2
//
//  Created by scott mehus on 12/20/16.
//  Copyright © 2016 scott mehus. All rights reserved.
//

import SpriteKit


func *(size: CGSize, multiplier: CGFloat) -> CGSize {
    let width = size.width * multiplier
    let height = size.height * multiplier
    return CGSize(width: width, height: height)
}

func /(size: CGSize, multiplier: CGFloat) -> CGSize {
    let width = size.width / multiplier
    let height = size.height / multiplier
    return CGSize(width: width, height: height)
}

func /(lhs: CGSize, rhs: CGSize) -> CGSize {
    let widthRatio = lhs.width / rhs.width
    let heightRatio = lhs.height / rhs.height
    return CGSize(width: widthRatio, height: heightRatio)
}

func *(lhs: CGSize, rhs: CGSize) -> CGSize {
    let widthRatio = lhs.width * rhs.width
    let heightRatio = lhs.height * rhs.height
    return CGSize(width: widthRatio, height: heightRatio)
}


extension CGSize {
    var cgPoint: CGPoint {
        return CGPoint(x: width, y: height)
    }
}

extension CGSize {
    
    var halfHeight: CGFloat {
        return CGFloat(height / 2)
    }
    
    var halfWidth: CGFloat {
        return CGFloat(width / 2)
    }
    
    public mutating func offset(dx: CGFloat, dy: CGFloat) -> CGSize {
        width += dx
        height += dy
        return self
    }
}
