//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit
import GameplayKit

class GameScene: SKScene {

    
    override func didMove(to view: SKView) {
        for child in children {
            child.removeFromParent()
        }
        
    
        let sampleCount = vector_int2(500, 500)
        
        let fakeSource = GKPerlinNoiseSource()
        print("freq \(fakeSource.frequency)  octave \(fakeSource.octaveCount) persistence \(fakeSource.persistence) lacunarity \(fakeSource.lacunarity) seed \(fakeSource.seed) ")

        
        ///
        /// ENEMY SHIP SOURCES
        ///
        
        // Do we want spawn enemies using noise?
        
//        let source = GKBillowNoiseSource(frequency: 2.0,
//                                         octaveCount: 6,
//                                         persistence: 0.5,
//                                         lacunarity: 0.2,
//                                         seed: Int32(2))
        
        ///
        /// WATER LAND SOURCES
        ///
        
        let source = GKPerlinNoiseSource(frequency: 1.0,
                                         octaveCount: 6,
                                         persistence: 0.5,
                                         lacunarity: 2.0,
                                         seed: Int32(50))
//

//        let source = GKRidgedNoiseSource(frequency: 1.0,
//                                         octaveCount: 10,
//                                         lacunarity: 1.0,
//                                         seed: Int32(50))
//
//        let source = GKRidgedNoiseSource(frequency: 0.5,
//                                         octaveCount: 10,
//                                         lacunarity: 2.0,
//                                         seed: Int32(50))
        
//        let source = GKBillowNoiseSource(frequency: 6.0,
//                                         octaveCount: 6,
//                                         persistence: 10.0,
//                                         lacunarity: 0.6,
//                                         seed: Int32(2))
        
        // Frequency basically zooms out
//        number and size of visible features in any given unit area of generated noise
        
        // Persistence: How quickly the hills drop
        // aka - How quickly the red bits turn into green bits
        // Smooths it out kinda
//        Smaller values result in smoother noise; larger values increase roughness. The default value is 0.5.
        
        
        // Lacunarity: less green splots - but larger - more uniformity
        // or more green spots and smaller
//        Smaller values result in coarser noise with more visible structure; finer values result in finer, more uniform noise. The default value is 2.0.
        
        
        // Octave Count:
//        Coherent noise is composed from several applications of a pseudorandom function. Each                 successive application, or octave, increases in frequency and decreases in amplitude relative to the previous octave. This combination of many octaves produces the fractal appearance that makes coherent noise resemble natural phenomena like clouds, stone, and water.
        
//        This property determines the number of octaves of the noise function that the noise source combines to produce noise. A smaller number results in smoother, simpler output; larger numbers result in rougher, more complex output.
        
        
//        let source = GKVoronoiNoiseSource()
//        let source = GKSpheresNoiseSource()
//        let source = GKCoherentNoiseSource()
//        let source = GKCylindersNoiseSource()
        
//        let noise = GKNoise(source,
//                            gradientColors: [0.8: .blue, 1: .red])
        
        // Land water noise
        let noise = GKNoise(source,
                            gradientColors: [0.2: .blue, 1: .green])
//        noise.invert()

//        noise.move(by: vector_double3(0, 0, 0))
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

        noise.move(by: vector_double3(0, 0, -3))
        
        let texture4 = SKTexture(noiseMap: customMap4)
        let sprite4 = SKSpriteNode(texture: texture4, color: .white, size: CGSize(width: 200, height: 200))
        sprite4.position = CGPoint(x: -100, y: 200)
        addChild(sprite4)
        
        
        noise.move(by: vector_double3(-3, 0, 0))
        let customMap5 = GKNoiseMap(noise,
                                    size: vector_double2(3, 3),
                                    origin: double2(0, 0),
                                    sampleCount: sampleCount,
                                    seamless: false)
        
        
        let texture5 = SKTexture(noiseMap: customMap5)
        let sprite5 = SKSpriteNode(texture: texture5, color: .white, size: CGSize(width: 200, height: 200))
        sprite5.position = CGPoint(x: -300, y: 0)
        addChild(sprite5)
        
        
    }
    
    func printValues(with map: GKNoiseMap, name: String) {
//        for i in 0..<map.sampleCount.x {
////            print("\(name): idx: \(i) -> \(map.value(at: vector_int2(i, 0)))")
//        }
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
