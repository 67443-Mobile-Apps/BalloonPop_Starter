// Created by Prof. H in 2025
// Part of the BalloonPop project
// Using Swift 6.0 and SpriteKit
// Qapla'

import SpriteKit

// MARK: - Touch Handling
/* This extension contains all touch event handling logic
  
   **Note**: Touch handling is fundamental to iOS games. SpriteKit provides several
   touch methods inherited from UIResponder:
   - touchesBegan: When finger touches down
   - touchesMoved: When finger drags
   - touchesEnded: When finger lifts up
   - touchesCancelled: When touch is interrupted (e.g., phone call)
  
   This game uses began for gameplay and ended for menu interactions.
*/
extension GameScene {

    // MARK: - Touch Began

    /* Handle touch-down events during active gameplay
      
       TODO: TASK 1 - Handle user touches to detect balloon pops
       touchesBegan is called whenever the user touches the screen
       You need to:
       1. Check if the game is active (guard isGameActive else { return })
       2. Get the first touch from the touches set (guard let touch = touches.first)
       3. Convert the touch location to scene coordinates using touch.location(in: self)
       4. Get all nodes at that location using nodes(at: location)
       5. Loop through the touched nodes
       6. Check if any node has name == "balloon"
       7. If you find a balloon, call popBalloon() with that node and break out of the loop
      
       I've also given you a bunch of comments in the method itself to guide you through this
    */
    
    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Exit early if game is not active (prevents touches during game over screen)
         
      

        // Get the first touch from the set
        // **Note**: iOS supports multi-touch, so touches is a Set.
        // For this game, we only care about single touches, so we get .first
        
      

        // Convert touch location from view coordinates to scene coordinates
        // **Note**: Critical concept! Touches come in UIView coordinates,
        // but SpriteKit nodes use scene coordinates. Always convert with location(in:)
        
      

        // Get all nodes at the touch location
        // **Note**: nodes(at:) returns an array of ALL nodes at that point,
        // from top to bottom (highest zPosition first). This is called "hit testing"
        
      

        // Search through touched nodes to find a balloon
        // **Note**: We iterate through nodes checking the 'name' property
        // This is why we set balloon.name = "balloon" when creating balloons
        
      
      
      
      
      
      
    }
  
    // TODO: Now go to popBalloon method and follow the instructions there
    // (Based on what we said in class, where do you think it is? ... )

  
  
    // MARK: - Touch Ended

    /* Handle touch-up events for menu interactions (restart button)
      
       **Note**: We use touchesEnded instead of touchesBegan for buttons
       because it feels more natural - the action happens when you lift your finger,
       just like standard iOS buttons. This also allows users to cancel by dragging away.
      
       - Parameters:
         - touches: Set of UITouch objects
         - event: The event containing all touches
    */
    func handleTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Only handle touches when game is NOT active (game over screen)
        // **Note**: Different UI states respond to touches differently.
        // During gameplay: tap balloons. During game over: tap to restart.
        if !isGameActive {
            guard let touch = touches.first else { return }

            // Same coordinate conversion as above
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)

            // Look for the restart button (a label node with name "restart")
            for node in touchedNodes {
                if node.name == "restart" {
                    restartGame()
                    break  // Only need to find one restart button
                }
            }
        }
    }
}

