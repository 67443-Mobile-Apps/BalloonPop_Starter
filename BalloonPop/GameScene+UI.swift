// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import SpriteKit

// MARK: - UI Management
/* This extension contains all user interface setup and update methods
  
   **Note**: Organizing code into extensions by feature (UI, game logic, touch handling)
   makes it much easier to navigate and maintain. Each extension focuses on one responsibility.
   This follows the Single Responsibility Principle from software engineering.
   I know I keep harping on this, but I feel I can't say it too much -- clean up your code.
*/
extension GameScene {

    // MARK: - Score Label Setup

    /* Create and configure the score label that displays at the top of the screen
      
       **Note**: This demonstrates several key SpriteKit concepts:
       1. Creating nodes (SKLabelNode for text display)
       2. Positioning nodes using the scene's coordinate system
       3. Managing the node hierarchy with addChild()
       4. Using zPosition for layering (like CSS z-index)
    */
    func setupScoreLabel() {
        // Create a label node with a specific font
        // **Note**: SKLabelNode is similar to UILabel but designed for SpriteKit's node system
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white

        // Position at the top center of the screen
        // **Note**: SpriteKit's coordinate system has (0,0) at bottom-left, not top-left like UIKit
        // - frame.midX gives us the horizontal center
        // - frame.maxY - 60 positions it 60 points from the top
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)

        // Configure text alignment
        // **Note**: Alignment modes affect how the text is positioned relative to its position point
        scoreLabel.horizontalAlignmentMode = .center  // Center the text horizontally on the position
        scoreLabel.verticalAlignmentMode = .top       // Align the top of the text to the position

        // Set initial text using string interpolation
        scoreLabel.text = "Score: 0"

        // zPosition controls drawing order (layering) - higher values are drawn on top
        // **Note**: This is similar to z-index in CSS. We use 100 to ensure
        // the label appears above game objects (balloons have zPosition = 10)
        scoreLabel.zPosition = 100

        // Add the label to the scene's node tree so it becomes visible
        // **Note**: Nodes must be added to the scene hierarchy to be rendered
        addChild(scoreLabel)
    }

  
    // MARK: - Missed Balloons Label Setup

    // Create and configure the label showing how many balloons have been missed
    
    // **Note**: This follows the same pattern as setupScoreLabel() but with
    // different positioning and styling to differentiate it from the score.
    func setupMissedBalloonsLabel() {
        missedLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        missedLabel.fontSize = 24  // Slightly smaller than score label
        missedLabel.fontColor = .white

        // Position below the score label with adequate spacing (60 points below)
        // **Note**: Consistent spacing creates better visual hierarchy
        missedLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)

        missedLabel.horizontalAlignmentMode = .center

        // Use string interpolation to include the maximum allowed misses
        // **Note**: \() inside strings lets you embed variable values
        missedLabel.text = "Missed: 0/\(maxMissedBalloons)"

        missedLabel.zPosition = 100
        addChild(missedLabel)
    }

  
    // MARK: - Label Updates

    // Update the score label to reflect the current score
    
    // **Note**: Separating update logic into its own method makes it easy to
    // call from anywhere in the code when the score changes. This is better than
    // duplicating the update code in multiple places.
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }

    // Update the missed balloons label to show current progress toward game over
    
    // **Note**: Showing "current/max" gives players clear feedback on how
    // close they are to losing. This is an important game design principle.
    func updateMissedLabel() {
        missedLabel.text = "Missed: \(missedBalloons)/\(maxMissedBalloons)"
    }
}
