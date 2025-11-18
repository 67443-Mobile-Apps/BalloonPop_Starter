// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import SpriteKit

// MARK: - Balloon Management

/* This extension contains all balloon-related logic: spawning, animating, and destroying

**Note**: This extension demonstrates the core game loop pattern - repeatedly
 creating game objects (balloons), animating them, and handling their lifecycle.
 Breaking this into its own extension keeps balloon logic separate from UI and input handling.
*/

extension GameScene {

    // MARK: - Balloon Spawning

    /* Start the recurring timer that spawns balloons at regular intervals

     **Note**: There are two key methods here, one for setting up the timer for spawning
     and the other to actually do the spawning.
     
     This also demonstrates several important Swift/iOS patterns:
     1. Timer-based game loops (alternative to SpriteKit's update() method)
     2. Closures (the { } block passed to the timer)
     3. Weak references [weak self] to prevent memory leaks
     4. Optional chaining with self?.
     
     Starting first with the timer that will regulate when balloons spawn...
    */
  
    func startSpawningBalloons() {
        // Create a repeating timer that fires every balloonSpawnInterval seconds
        // **Note**: The closure captures 'self' weakly to avoid a retain cycle.
        // Without [weak self], the timer would keep the scene alive even when we want to release it.
        balloonTimer = Timer.scheduledTimer(withTimeInterval: balloonSpawnInterval, repeats: true) { [weak self] _ in
            // Optional chaining: only calls spawnBalloon if self still exists
            self?.spawnBalloon()
        }
    }

    /* Now that we have a timer, we need a method to actually create a
       new balloon node and add it to the scene with random positioning.

    **Note**: This method demonstrates the complete lifecycle of creating a game object:
    1. Guard clauses for validation
    2. Creating the visual node (SKShapeNode)
    3. Configuring appearance (color, size, stroke)
    4. Calculating safe positioning
    5. Adding physics properties
    6. Adding to scene hierarchy
    7. Starting animations
    */
    func spawnBalloon() {
        // Guard clause: exit early if game is not active
        guard isGameActive else { return }

        // Ensure the scene has valid dimensions before spawning
        // **Note**: Early in the scene lifecycle, dimensions might be zero
        guard frame.width > 0 && frame.height > 0 else { return }

        // Get the device's safe area insets to avoid notches, rounded corners, etc.
        // **Note**: The nil coalescing operator (??) provides a default value if view is nil
        let safeAreaInsets = view?.safeAreaInsets ?? .zero

        // Create a circular shape node for the balloon
        // **Note**: SKShapeNode lets you draw custom shapes. Alternatives include:
        // - SKSpriteNode for image-based sprites (better performance for many objects)
        // - SKEffectNode for nodes with special effects
        let balloon = SKShapeNode(circleOfRadius: balloonRadius)

        // Configure the balloon's appearance
        balloon.fillColor = randomBalloonColor()    // Random color for visual variety
        balloon.strokeColor = .white                // White outline for definition
        balloon.lineWidth = balloonStrokeWidth      // Thickness of the outline

        // Set the name property for identification during touch detection
        // **Note**: The 'name' property is SpriteKit's way of tagging nodes
        // Later, we can search for nodes by name: nodes(at: location).first { $0.name == "balloon" }
        balloon.name = "balloon"

        /* Calculate safe positioning to keep balloons fully visible on screen
           **Note**: This demonstrates important game development concepts:
           - Accounting for device safe areas (notches, rounded corners)
           - Edge detection to prevent objects from being cut off
           - Fallback logic for edge cases

           Calculate padding needed to keep balloon fully visible
           Components: balloon radius + stroke width + safety buffer
           **Aside**: In my first iteration of the game, many of the balloons were
           only partially visible because they were spawned too close to the edge.
         */
        let basePadding = balloonRadius + balloonStrokeWidth + 15  // Extra 15pt safety buffer
        let leftPadding = basePadding + safeAreaInsets.left        // Add left safe area
        let rightPadding = basePadding + safeAreaInsets.right      // Add right safe area

        // Define the valid range for balloon X positions
        let minX = leftPadding                  // Leftmost position (keeps balloon on screen)
        let maxX = frame.width - rightPadding   // Rightmost position

        // Generate random X position within valid range
        // **Note**: Always validate ranges before calling random(in:) to avoid crashes
        let randomX: CGFloat
        if maxX > minX {
            // Range is valid - generate random position
            randomX = CGFloat.random(in: minX...maxX)
        } else {
            // Range is invalid (screen too narrow) - use center as fallback
            randomX = frame.midX
        }

        // Set balloon position: random X, starting just below the visible screen
        // **Note**: Starting at y: -50 (below screen) makes balloons "rise up" into view
        balloon.position = CGPoint(x: randomX, y: -50)

        // Set z-position for proper layering
        // **Note**: zPosition determines draw order (like CSS z-index):
        // - Background: 0 (default)
        // - Balloons: 10 (above background)
        // - UI labels: 100 (above everything)
        balloon.zPosition = 10

        // Configure physics body for the balloon
        // **Note**: Even though we're not using collisions, adding a physics body
        // is good practice and allows for future expansion (e.g., balloon collisions)
        balloon.physicsBody = SKPhysicsBody(circleOfRadius: balloonRadius)

        // Physics body configuration
        balloon.physicsBody?.isDynamic = true           // Can move and be affected by forces
        balloon.physicsBody?.categoryBitMask = 1        // Collision category for identification
        balloon.physicsBody?.contactTestBitMask = 0     // Don't test for contacts with anything
        balloon.physicsBody?.collisionBitMask = 0       // Don't collide with anything
        balloon.physicsBody?.affectedByGravity = false  // We control movement via SKActions, not physics

        // Add the balloon to the scene's node hierarchy
        // **Note**: Nodes must be added as children to be rendered
        addChild(balloon)

        // Start the animation that makes the balloon rise
        animateBalloonRise(balloon)
    }

  
    // MARK: - Balloon Appearance

    /* Return a random color for visual variety in balloons

     **Note**: This demonstrates a couple of things related to Optionals:
     - The randomElement() method (returns Optional)
     - Nil coalescing operator (??) for providing a default value
    */
    func randomBalloonColor() -> SKColor {
        // Array of available balloon colors
        // **Note**: SKColor is a typealias that works on both iOS (UIColor) and macOS (NSColor)
        let colors: [SKColor] = [
            .red, .blue, .green, .yellow, .orange, .purple, .systemPink, .cyan
        ]

        // Get a random element from the array, or default to red if array is empty
        // **Note**: randomElement() returns an Optional because the array could be empty
        return colors.randomElement() ?? .red
    }

  
    // MARK: - Balloon Animation

    /* Animate the balloon moving from bottom to top of screen
    
     **Note**: This demonstrates SKAction, SpriteKit's powerful animation system.
     SKActions can be:
     - Combined in sequences (one after another)
     - Combined in groups (simultaneously)
     - Repeated, reversed, and chained in complex ways
     - Run with completion handlers for triggering game events
    */
    func animateBalloonRise(_ balloon: SKShapeNode) {
        // Create an action that moves the balloon to just above the screen
        // **Note**: moveTo moves to an absolute position, move(by:) is relative
        let moveUp = SKAction.moveTo(y: frame.height + 50, duration: balloonRiseSpeed)

        // Create an action that runs custom code when the animation completes
        // **Note**: SKAction.run executes a closure, perfect for game logic triggers
        // [weak self] prevents retain cycles (memory leaks) in the closure
        // **Aside**: I've mentioned this several times here and in class because even though
        // there is auto reference counting, I have been burned by this with closures;
        // that error wasn't obvious and took some time, so I try not to repeat it. ;-)
      
        let remove = SKAction.run { [weak self] in
            balloon.removeFromParent()  // Remove from scene (also removes from memory)
            self?.balloonEscaped()      // Update game state for missed balloon
        }

        // Sequence combines actions to run one after another
        // **Note**: The balloon moves up, THEN gets removed and counted as missed
        // Order matters! Removing before moving would make the balloon invisible immediately
        let sequence = SKAction.sequence([moveUp, remove])

        // Execute the action sequence on the balloon
        balloon.run(sequence)
    }

  
    // MARK: - Balloon Escaped

    /* Called when a balloon reaches the top of the screen without being popped
    
     **Note**: This demonstrates game state management:
       - Updating counters
       - Updating UI to reflect state changes
       - Checking win/loss conditions
       - Triggering state transitions (to game over)
    */
    func balloonEscaped() {
        // Increment the missed balloon counter
        missedBalloons += 1

        // Update the UI to show the new count
        updateMissedLabel()

        // Check if the player has reached the maximum allowed misses
        // **Note**: This is a common game design pattern - allowing some mistakes
        // before game over makes the game more forgiving and fun
        if missedBalloons >= maxMissedBalloons {
            gameOver()  // Trigger game over sequence
        }
    }

     /* Start the difficulty progression timer that makes the game progressively harder

     **Note**: This timer runs every X seconds and gradually reduces the spawn interval,
     causing balloons to appear more frequently. This creates a natural difficulty curve
     that keeps the game engaging as players improve.
    */
    func startDifficultyProgression() {
        difficultyTimer = Timer.scheduledTimer(withTimeInterval: difficultyIncreaseInterval, repeats: true) { [weak self] _ in
            self?.increaseDifficulty()
        }
    }


  
    // MARK: - Balloon Popping

    /* Handle a balloon being successfully popped by the player
       (This is the method you called in the prior touch-handling exercise)
    
       TODO: TASK 2 - Create a pop animation and remove the balloon
       You need to:
       1. Increment the score by 1
       2. Update scoreLabel.text to show "Score: \(score)"
       3. Create a scale up action: SKAction.scale(to: 1.5, duration: 0.1)
       4. Create a fade out action: SKAction.fadeOut(withDuration: 0.1)
       5. Group these two actions together using SKAction.group([scaleUp, fadeOut])
       6. Create a remove action: SKAction.removeFromParent()
       7. Create a sequence that runs the pop animation, then removes the node
          using SKAction.sequence([popAnimation, remove])
       8. Run the sequence on the balloon node using balloon.run(sequence)
    */
  
    func popBalloon(_ balloon: SKNode) {
        // Update game state
        
      
      
      

        // Create visual feedback animations
        // **Note**: Good games provide immediate, satisfying feedback for player actions
        // A simple scale+fade makes popping feel impactful

        // Scale up the balloon as it "pops"

      
        // Fade out simultaneously

      
      
        // Run both animations at the same time using group
        // **Note**: group vs sequence:
        // - group: all actions run simultaneously
        // - sequence: actions run one after another

      
      
        // After the pop animation finishes, remove the balloon from the scene

      
      
        // Sequence: pop animation THEN removal

      
      
        // Execute the animation sequence

      
      
      
        // TODO: Time to build and run the game (phone or simulator)
      
        /* Optional: Add sound effects for better game feel
           **Note**: To add sound:
           1. Add a .wav or .mp3 file to your project (one is given for you already)
           2. Uncomment the line below and replace "pop_sound.wav" with your filename
           
           Sound makes games significantly more engaging! (Try without and you'll see)
        */
      
      // run(SKAction.playSoundFileNamed("pop_sound.mp3", waitForCompletion: false))
    }
}

