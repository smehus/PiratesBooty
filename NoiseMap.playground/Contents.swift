//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import GameplayKit

class GameScene: SKScene {

    
    override func didMove(to view: SKView) {
        for child in children {
            child.removeFromParent()
        }
        
    
        let sampleCount = vector_int2(100, 100)
        
        let fakeSource = GKPerlinNoiseSource()
        print("freq \(fakeSource.frequency)  octave \(fakeSource.octaveCount) persistence \(fakeSource.persistence) lacunarity \(fakeSource.lacunarity) seed \(fakeSource.seed) ")
        
        
        
        let source = GKPerlinNoiseSource(frequency: 1.0,
                                         octaveCount: 3,
                                         persistence: 3.0,
                                         lacunarity: 1.0,
                                         seed: Int32(50))
        

//        let source = GKRidgedNoiseSource(frequency: 1.0,
//                                         octaveCount: 3,
//                                         lacunarity: 1.0,
//                                         seed: Int32(50))
        
//        let source = GKBillowNoiseSource()
//        let source = GKVoronoiNoiseSource()
//        let source = GKSpheresNoiseSource()
//        let source = GKCoherentNoiseSource()
//        let source = GKCylindersNoiseSource()
        
        let noise = GKNoise(source,
                            gradientColors: [-1: .red, 1: .green])

        noise.move(by: vector_double3(0, 0, 0))
        let map = GKNoiseMap(noise)
        print("sample count \(map.sampleCount)")
        print("size \(map.size)")
        print("origin \(map.origin)")
        
        let customMap = GKNoiseMap(noise,
                                   size: vector_double2(3, 3),
                                   origin: vector_double2(0, 0),
                                   sampleCount: sampleCount,
                                   seamless: false)
        

        let texture = SKTexture(noiseMap: customMap)
        let sprite = SKSpriteNode(texture: texture, color: .white, size: CGSize(width: 200, height: 200))
        sprite.position = CGPoint(x: -100, y: 0)
        
        addChild(sprite)
        
        
        /// Will need to keep track of the translation - and maybe
        /// reset back to 0 each time a new map is about to be created
        noise.move(by: vector_double3(3, 0, 0))

        let customMap2 = GKNoiseMap(noise,
                                    size: vector_double2(3, 3),
                                    origin: double2(0, 0),
                                    sampleCount: sampleCount,
                                    seamless: false)

        noise.move(by: vector_double3(-3, 0, 0))
        let texture2 = SKTexture(noiseMap: customMap2)
        let sprite2 = SKSpriteNode(texture: texture2, color: .white, size: CGSize(width: 200, height: 200))
        sprite2.position = CGPoint(x: 100, y: 0)
        addChild(sprite2)



        noise.move(by: vector_double3(0, 0, -3))

        let customMap3 = GKNoiseMap(noise,
                                    size: vector_double2(3, 3),
                                    origin: double2(0, 0),
                                    sampleCount: sampleCount,
                                    seamless: false)

        noise.move(by: vector_double3(0, 0, 3))
        let texture3 = SKTexture(noiseMap: customMap3)
        let sprite3 = SKSpriteNode(texture: texture3, color: .white, size: CGSize(width: 200, height: 200))
        sprite3.position = CGPoint(x: -100, y: -200)
        addChild(sprite3)



        noise.move(by: vector_double3(0, 0, 3))

        let customMap4 = GKNoiseMap(noise,
                                    size: vector_double2(3, 3),
                                    origin: double2(0, 0),
                                    sampleCount: sampleCount,
                                    seamless: false)


        let texture4 = SKTexture(noiseMap: customMap4)
        let sprite4 = SKSpriteNode(texture: texture4, color: .white, size: CGSize(width: 200, height: 200))
        sprite4.position = CGPoint(x: -100, y: 200)
        addChild(sprite4)
        
        
    }
    
    func printValues(with map: GKNoiseMap, name: String) {
        for i in 0..<map.sampleCount.x {
            print("\(name): idx: \(i) -> \(map.value(at: vector_int2(i, 0)))")
        }
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
