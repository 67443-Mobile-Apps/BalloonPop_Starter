// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import SpriteKit

// MARK: - Game State Management

/* This extension contains game state transition logic (game over and restart)

   **Note**: Game state management is crucial for any game. This extension handles:
   - Transitioning from gameplay to game over
   - Cleaning up game objects
   - Displaying end-game UI
   - Resetting for a new game
 
   Good state management prevents bugs like scoring points after game over or
   balloons spawning during the restart sequence.
*/
extension GameScene {

    // MARK: - Game Over

    /* Transition to game over state and display end-game UI
      
       **Note**: This method demonstrates a complete state transition:
       1. Set state flag to prevent further gameplay
       2. Stop all game loops/timers
       3. Clean up active game objects
       4. Display new UI for the end state
      
       The order of operations is important! Always stop gameplay systems before
       displaying end-game UI.
    */
    func gameOver() {
        // Set the game state flag to inactive
        // **Note**: This single flag controls multiple behaviors:
        // - Stops balloon spawning (guard in spawnBalloon)
        // - Ignores gameplay touches (guard in handleTouchesBegan)
        // - Enables restart touches (check in handleTouchesEnded)
        isGameActive = false

        // Stop the balloon spawning timer
        // **Note**: Always invalidate timers when done! Timers keep strong
        // references to their targets, which can cause memory leaks if not cleaned up
        balloonTimer?.invalidate()
        balloonTimer = nil

        // Stop the difficulty progression timer
        difficultyTimer?.invalidate()
        difficultyTimer = nil

        // Remove all balloons still on screen
        // **Note**: enumerateChildNodes finds all nodes matching a condition
        // The underscore (_) ignores the stop parameter we don't need
        enumerateChildNodes(withName: "balloon") { node, _ in
            node.removeFromParent()
        }

        // Create and display the "Game Over" message
        // **Note**: We create labels programmatically here rather than in setup
        // because they're only needed in this specific game state
        let gameOverLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.text = "Game Over!"

        // Position in center, slightly above middle
        // **Note**: frame.midX and frame.midY give us the screen center
        // We offset vertically to create visual hierarchy with multiple labels
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        gameOverLabel.zPosition = 100  // Above everything else
        addChild(gameOverLabel)

        // Display the player's final score
        let finalScoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        finalScoreLabel.fontSize = 36  // Slightly smaller than "Game Over"
        finalScoreLabel.fontColor = .white
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - 20)
        finalScoreLabel.zPosition = 100
        addChild(finalScoreLabel)

        // Display restart instructions
        // **Note**: Setting the 'name' property to "restart" allows
        // the touch handler to identify this node and trigger restartGame()
        let restartLabel = SKLabelNode(fontNamed: "Arial")
        restartLabel.fontSize = 24  // Smallest of the three labels
        restartLabel.fontColor = .white
        restartLabel.text = "Tap to Restart"
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 80)
        restartLabel.zPosition = 100
        restartLabel.name = "restart"  // Important! Used for touch detection
        addChild(restartLabel)
    }

  
    // MARK: - Restart Game

    /* Reset the game to its initial state and start a new game
      
       **Note**: This demonstrates how to properly reset a game:
       1. Clear all existing nodes (including game over UI)
       2. Reset all game state variables to initial values
       3. Rebuild the scene from scratch
       4. Restart game loops
      
       This is essentially the same sequence as didMove(to:), but we need to
       clean up first since the scene already exists.
    */
    func restartGame() {
        // Remove ALL child nodes from the scene
        // **Note**: This clears everything - balloons, labels, game over UI, etc.
        // removeAllChildren() is like a "clean slate" for the scene
        removeAllChildren()

        // Reset all game state variables to their initial values
        // **Note**: It's important to reset ALL state variables, not just some.
        // Missing even one can cause bugs (e.g., starting new game with old score)
        score = 0
        missedBalloons = 0
        isGameActive = true
        balloonSpawnInterval = 1.0    // Reset spawn interval to initial value

        // Rebuild the scene exactly as we did in didMove(to:)
        // **Note**: By calling the same setup methods, we ensure the game
        // starts in exactly the same state every time. This is good code reuse!
        setupScene()                  // Background color and physics
        setupScoreLabel()             // Score UI
        setupMissedBalloonsLabel()    // Missed balloons UI
        startSpawningBalloons()       // Start the game loop
        startDifficultyProgression()  // Restart the difficulty progression

        // The game is now fully reset and ready to play again!  LFG!
    }
}
