//
//  HintViewController.swift
//  Pentominoes
//
//  Created by Julian Panucci on 9/18/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit

class HintViewController: UIViewController {
    
    
    var model:PentominoeModel? = nil
    
    //Array of pieces passed from ViewController so we can make reference to what pieces are on the board in ViewController, so we know what pieces to show in the hint (These are never actually seen)
    var boardPieces = [PieceImageView]()
    
    //New array of pieces that we create separately in this view controller and add to board. These are the pieces that are shown or not shown on the hint board
    var hintPieces = [PieceImageView]()
    
    let kSideOfSquare:CGFloat = 30.0
    
    @IBAction func nextHintAction(sender: AnyObject) {
        revealNextHint()
    }
    
    @IBOutlet weak var boardImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let model = model {
              self.boardImageView.image = UIImage(named: model.imageBoardNameAtIndex((model.currentBoardNumber)))
        }
        
        addAllPiecesToBoard()
        revealNextHint()
    }
    
    /**
     Adds all pieces to the current board sent from the original view controller. Sets all of them to hidden. Very similar to method in ViewController that adds the pieces to the board, but with no animation
     */
    func addAllPiecesToBoard()
    {
        var pieceIndex = 0
        
        if let model = model {
            for letter in model.pieceLetters {
                
                let name = model.imagePieceNameAtIndex(pieceIndex)
                let pieceImage = UIImage(named: name)
                let pieceImageView = PieceImageView(image: pieceImage)
                pieceImageView.letter = letter
                hintPieces.append(pieceImageView)
                
                let solution = model.solutionForPiece(pieceWithLetter: letter, onBoard: model.currentBoardNumber)
               

                //Get all info needed for the transition of the piece
                let xcord = CGFloat(solution["x"]!) * kSideOfSquare
                let ycord = CGFloat(solution["y"]!) * kSideOfSquare
                let flips = solution["flips"]
                let rotations = solution["rotations"]
                
                pieceImageView.numberOfRotations = rotations!
                pieceImageView.numberOfFlips = flips!
               
                if(rotations > 0) {
                    pieceImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2 * Double(rotations!)))
                }
                if(flips > 0) {
                    pieceImageView.transform = CGAffineTransformScale(pieceImageView.transform, -1.0, 1.0);
                }
                
                pieceImageView.frame = CGRectMake(xcord, ycord, pieceImageView.frame.size.width, pieceImageView.frame.size.height)
                self.boardImageView.addSubview(pieceImageView)
                pieceImageView.hidden = true
            
            
                pieceIndex += 1;
                }
            }
    }
    
    func revealNextHint()
    {
        var hintCount = 0;
        //Traverse through boardPieces and identify which one should be included in the hint or not. If it should we break out of the for loop because we want to reveal one hint at a time, and remove from boardPieces
        for piece in self.boardPieces {
            
            if piece.shouldBeInHint {
                showPieceWithLetter(piece.letter)
                self.boardPieces.removeAtIndex(hintCount)
                break
            }
            hintCount += 1
        }
        
    }
    
    /**
     Traverse through hintPieces (pieces that are actually added to the hint board) We compare the letter of the current piece to letter passed through, if they are the same then we reveal the current piece on the board setting hidden to true
     
     - parameter letter: letter of piece we want to reveal
     */
    func showPieceWithLetter(letter:String) {
        for piece in hintPieces {
            if piece.letter == letter {
                piece.hidden = false
            }
        }
    }
  
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
