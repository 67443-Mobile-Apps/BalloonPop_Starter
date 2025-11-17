// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import SpriteKit
import GameplayKit

// MARK: - GameScene

/*
 The main game scene where all gameplay takes place.

 This class demonstrates several key SpriteKit concepts:
 - Scene lifecycle management (didMove, willMove)
 - Node hierarchy and positioning
 - Timer-based game loops
 - Touch event handling
 - Scene organization through extensions (see GameScene+*.swift files)

 **Note**: SKScene is the root container for all SpriteKit content.
 Think of it as a canvas that manages all game objects (nodes) and their interactions.
 The scene has a coordinate system with (0,0) at the bottom-left corner.
 */

class GameScene: SKScene {

    // MARK: - Game State Properties

    // The player's current score - incremented each time a balloon is successfully popped
    // **Note**: Properties marked with 'var' can be modified, unlike 'let' constants
    var score = 0

    // Counter for balloons that escaped off the top of the screen
    // When this reaches maxMissedBalloons, the game ends
    var missedBalloons = 0

    // Flag indicating whether the game is currently active
    // Set to false during game over to stop balloon spawning and ignore touch events
    // **Note**: Bool properties are often prefixed with 'is' for readability
    var isGameActive = true

  
    // MARK: UI Properties

    // Label displaying the current score at the top of the screen
    // **Note**: SKLabelNode is SpriteKit's text rendering node
    // The '!' indicates this is an implicitly unwrapped optional - it will be initialized in setupScoreLabel()
    var scoreLabel: SKLabelNode!

    // Label showing how many balloons the player has missed
    var missedLabel: SKLabelNode!

    // MARK: Timer Properties

    // Timer that repeatedly calls spawnBalloon() at regular intervals
    // **Note**: Timers are commonly used for recurring events in games
    // The '?' makes this optional since it's nil when the game isn't active
    var balloonTimer: Timer?

    // Timer that increases difficulty by reducing spawn interval every 30 seconds
    var difficultyTimer: Timer?


    // MARK: Game Configuration Constants

    // How often (in seconds) to spawn a new balloon
    // **Note**: TimeInterval is a typealias for Double, used for time measurements
    // Changed from 'let' to 'var' to allow progressive difficulty increases
    var balloonSpawnInterval: TimeInterval = 1.0

    // How long (in seconds) it takes a balloon to travel from bottom to top of screen
    // Lower values make the game harder by increasing balloon speed
    let balloonRiseSpeed: TimeInterval = 4.0

    // Maximum number of balloons that can escape before game over
    let maxMissedBalloons = 5

    // Visual properties for balloon appearance
    // **Note**: CGFloat is the standard type for graphics coordinates and sizes
    let balloonRadius: CGFloat = 40
    let balloonStrokeWidth: CGFloat = 2

    // Difficulty progression settings
    // How often (in seconds) to increase difficulty
    let difficultyIncreaseInterval: TimeInterval = 15.0
    // How much to reduce spawn interval each time (makes spawning faster)
    let spawnIntervalDecrease: TimeInterval = 0.1
    // Minimum spawn interval (prevents it from getting impossibly fast)
    let minimumSpawnInterval: TimeInterval = 0.3

  
    // MARK: - Scene Lifecycle

    /* Called when the scene is presented by the view - this is where we perform initial setup
    
     **Note**: This is similar to viewDidLoad() in UIKit. It's called once when
     the scene is first displayed. This is the perfect place to initialize your game state,
     create initial nodes, and start any recurring processes.
    
     The setup is split into separate methods to keep code organized and maintainable.
    */
    override func didMove(to view: SKView) {
        setupScene()                  // Configure scene properties (background, physics)
        setupScoreLabel()             // Create and position the score label
        setupMissedBalloonsLabel()    // Create and position the missed balloons label
        startSpawningBalloons()       // Begin the game loop that creates balloons
        startDifficultyProgression()  // Start the timer that increases difficulty over time
    }

  
    // MARK: - Scene Setup

    /* Configure the basic scene properties including background color and physics
    
     **Note**: This demonstrates how to set up a SpriteKit scene's visual
     appearance and physics simulation. Even if you're not using complex physics,
     setting up the physics world is a common pattern in SpriteKit games.
    */
    func setupScene() {
        // Set a pleasant sky blue background color using RGB values (0-1 range)
        // **Note**: SKColor is SpriteKit's color type (typealias for UIColor/NSColor)
        backgroundColor = SKColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0)

        // Configure the physics world
        // **Note**: SpriteKit includes a 2D physics engine for realistic movement and collisions
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)  // Zero gravity - we control balloon movement manually
        physicsWorld.contactDelegate = self            // This scene will receive physics contact notifications
    }

  
    // MARK: - Touch Handling

    /* Called when user touches begin on the screen
    
     **Note**: SpriteKit provides several touch event methods inherited from UIResponder:
     - touchesBegan: finger touches down
     - touchesMoved: finger drags across screen
     - touchesEnded: finger lifts off screen
     - touchesCancelled: touch interrupted (e.g., phone call)
    
     We delegate to an extension method to keep this main file clean and organized.
     (You know refactoring matters to me -- keeping code maintainable is important.)
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesBegan(touches, with: event)
    }

    // Called when user touches end (finger lifts off screen)
    // Used to handle the "restart game" functionality after game over
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesEnded(touches, with: event)
    }

    // MARK: - Cleanup

    /* Called when the scene is about to be removed from the view

     **Note**: Always clean up timers and other resources to prevent memory leaks.
     Timers maintain strong references to their targets, so they must be explicitly invalidated.
     This is similar to deinit or viewWillDisappear in UIKit.
    */
    override func willMove(from view: SKView) {
        balloonTimer?.invalidate()      // Stop the balloon spawning timer
        balloonTimer = nil              // Release the reference
        difficultyTimer?.invalidate()   // Stop the difficulty progression timer
        difficultyTimer = nil           // Release the reference
    }
}


// MARK: - SKPhysicsContactDelegate
/* Extension implementing physics contact detection protocol

 **Note**: Extensions are a powerful Swift feature that let you add functionality
 to existing classes without modifying their original implementation. They're perfect for
 organizing code by feature or conforming to protocols.

 This extension makes GameScene conform to SKPhysicsContactDelegate, which allows it to
 receive notifications when physics bodies collide or make contact.
*/
extension GameScene: SKPhysicsContactDelegate {

    /* Called automatically when two physics bodies begin making contact

    **Note**: This is a delegate method - the physics world calls it when
    two bodies with matching contact masks touch. The contact parameter contains
    information about both bodies (bodyA and bodyB) and the collision point.

    Currently unused in this game, but included to demonstrate the pattern.
    You could extend this game to:
     - Detect balloon-to-balloon collisions
     - Check when balloons reach a certain height
     - Add power-ups or obstacles that interact with balloons
    */
    func didBegin(_ contact: SKPhysicsContact) {
        // Example: You could identify which bodies collided and take action
        // if contact.bodyA.categoryBitMask == balloonCategory && contact.bodyB.categoryBitMask == powerUpCategory {
        //     // Handle balloon collecting a power-up
        // }
    }
}
