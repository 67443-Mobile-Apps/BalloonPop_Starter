// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import UIKit
import SpriteKit
import GameplayKit

/* The main view controller that hosts and presents the SpriteKit game scene
  
   **Note**: In a SpriteKit game, the view controller's main job is to:
   1. Create and configure the SKView (the SpriteKit rendering surface)
   2. Create and present the game scene
   3. Configure view properties and device orientations
  
   Think of this as the "launcher" for your game - it sets up the environment
   and then hands control to the game scene.
*/
class GameViewController: UIViewController {

    /* Called when the view controller's view is loaded into memory
      
       **Note**: This is UIKit's primary initialization point for view controllers.
       Here we set up the SpriteKit view and present our game scene. This only runs once
       when the view controller first loads.
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Cast the generic view to SKView (SpriteKit's specialized view class)
        // **Note**: The conditional cast (as!) will crash if the view isn't
        // an SKView, but we know it is because it's configured in the storyboard
        if let view = self.view as! SKView? {
            /* Create the game scene programmatically with exact view dimensions
               **Note**: Creating the scene with view.bounds.size ensures
               the scene matches the device screen exactly, preventing scaling issues
               that could crop objects at screen edges. This is better than loading
               from a .sks file with a fixed size that gets scaled.
            */
            let scene = GameScene(size: view.bounds.size)

            /* Configure how the scene scales to fit the view
               **Note**: Scale modes determine how the scene adjusts to different screen sizes:
               - .resizeFill: Resizes scene to exactly match view (no letterboxing/pillarboxing)
               - .aspectFill: Maintains aspect ratio, may crop edges
               - .aspectFit: Maintains aspect ratio, may show letterboxing
               Since we create the scene with exact dimensions, .resizeFill works perfectly
            */
            scene.scaleMode = .resizeFill

            // Present the scene (start the game!)
            // **Note**: presentScene() begins rendering the scene and starts
            // the SpriteKit game loop, which calls update() every frame
            view.presentScene(scene)

            // Performance optimization: don't worry about draw order of sibling nodes
            // **Note**: Setting this to true can improve performance slightly
            // because SpriteKit doesn't have to sort nodes at the same z-level
            view.ignoresSiblingOrder = true

            // Show debug information (useful during development)
            // **Note**: These overlays show useful debugging info:
            // - showsFPS: Displays frames per second (aim for 60 FPS)
            // - showsNodeCount: Shows how many nodes are in the scene
            // Set these to false before releasing to the App Store!
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    /* Specify which device orientations this view controller supports
      
       **Note**: iOS games often restrict orientations to prevent awkward
       gameplay when the device rotates. This property is checked by iOS to determine
       which orientations are allowed.
      
       - Returns: A mask of allowed interface orientations
    */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Different rules for different device types
        // **Note**: iPads typically support all orientations, while
        // phones often restrict them for better gameplay experience
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Allow all orientations except upside down (phone held upside down)
            // **Note**: .allButUpsideDown is common for phone games
            // because upside-down can cover the speaker and feels unnatural
            return .allButUpsideDown
        } else {
            // iPad: allow all orientations
            return .all
        }
    }

    /* Control whether the status bar (time, battery, etc.) is visible
      
       **Note**: Hiding the status bar is common in games to:
       1. Maximize screen space for gameplay
       2. Create a more immersive experience
       3. Prevent accidental swipes that open Control Center
      
       - Returns: true to hide the status bar, false to show it
    */
    override var prefersStatusBarHidden: Bool {
        return true  // Hide status bar for full-screen gameplay
    }
}
