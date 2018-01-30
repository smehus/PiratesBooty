//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let sampleCount = vector_int2(500, 500)
    let mapSize = vector_double2(3, 3)
    let spriteSize = CGSize(width: 200, height: 200)
    
    override func didMove(to view: SKView) {
        for child in children {
            child.removeFromParent()
        }
        
    }
    
    
    /// This will use a map to decide which noise object to use. So that within each section of the selection map, varying values of the sub noise can be used. Water noise can have its own map, and land can have its own map.
    func componentNoise() {
        let waterSource = GKRidgedNoiseSource()
        let waterNoise = GKNoise(waterSource, gradientColors: [-1: .blue, 1: .blue])
        
        let landSource = GKPerlinNoiseSource()
        let landNoise = GKNoise(landSource, gradientColors: [-1: .green, 1: .green])
        
        
        let selectionSource = GKPerlinNoiseSource()
        let selectionNoise = GKNoise(selectionSource)
        
        let mapNoise = GKNoise(componentNoises: [waterNoise, landNoise], selectionNoise: selectionNoise)
        
        let map = GKNoiseMap(mapNoise)
        let texture = SKTexture(noiseMap: map)
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: 0, y: 0)
        
        addChild(sprite)
    }
    
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
