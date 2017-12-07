//
//  MotionManager.swift
//  PiratesBooty
//
//  Created by scott mehus on 12/7/17.
//  Copyright © 2017 scott mehus. All rights reserved.
//

import SpriteKit
import CoreMotion

protocol MovementManager {
    var delegate: MotionManagerDelegate? { get set }
    init(modifier: Double)
    func start()
}

protocol MotionManagerDelegate: class {
    func didRecieveMotionUpdate(pitch: CGFloat, roll: CGFloat)
}

internal final class MotionManager: MovementManager {
    
    weak var delegate: MotionManagerDelegate?
    
    private let motionQueue = OperationQueue()
    private let modifier: Double
    private var motionManager = CMMotionManager()
    
    init(modifier: Double) {
        self.modifier = modifier
    }
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            let reference = motionManager.attitudeReferenceFrame
            motionManager.startDeviceMotionUpdates(using: reference, to: motionQueue, withHandler: { (motion, error) in
                guard let attitude = motion?.attitude else { return }
                
                OperationQueue.main.addOperation {
                    let modifiedPitch = CGFloat(attitude.pitch * abs(self.modifier))
                    let modifiedRoll = CGFloat(attitude.roll * abs(self.modifier))
                    self.delegate?.didRecieveMotionUpdate(pitch: modifiedPitch, roll: modifiedRoll)
                }
            })
        }
    }
}
