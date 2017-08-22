//
//  ViewController.swift
//  Pentominoes
//
//  Created by Julian Panucci on 9/11/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UIViewController {

    
    //MARK: - Outlets
    @IBOutlet weak var boardButton0: UIButton!
    @IBOutlet weak var boardButton1: UIButton!
    @IBOutlet weak var boardButton2: UIButton!
    @IBOutlet weak var boardButton3: UIButton!
    @IBOutlet weak var boardButton4: UIButton!
    @IBOutlet weak var boardButton5: UIButton!
    
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var boardImageView: UIImageView!
    @IBOutlet weak var piecesContainer: UIView!
    
    
    //MARK: - Actions
    @IBAction func solveAction(_ sender: AnyObject) {
        solveGame()
    }
    
    @IBAction func resetAction(_ sender: AnyObject) {
        resetPiecesToDefaultPosition()
    }
    @IBAction func changePlayingBoardAction(_ sender: AnyObject) {
        if let boardButton = sender as? UIButton {
            model.currentBoardNumber = boardButton.tag
            if model.currentBoardNumber == 0 {
                hintButton.isEnabled = false
            }else {
                hintButton.isEnabled = true
            }
            self.boardImageView.image = UIImage(named: model.imageBoardNameAtIndex((model.currentBoardNumber)))
        }
    }
    
    //MARK: - Constants
    
    let kSideOfSquare:CGFloat = 30.0
    let kVerticalSpaceForPieces:CGFloat = 25.0
    let kHorizontalSpaceForPieces:CGFloat = 40.0
    let kAnimationDuration = 1.5
    let kSnapAnimationDuration = 0.3
    let kFlipAnimationDuration = 0.5
    let kRotateAnimtionDuration = 0.5
    let kShrinkScale:CGFloat = 0.8
    
  
    //MARK: -Properties
    let model = PentominoeModel()
    var currentBoardNumber = 0
    var boardPieces = [PieceImageView]()
    var boardButtonArray = [UIButton]()
    var solved = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Created to easily traverse through all buttons to enable or disable them
        boardButtonArray = [boardButton0, boardButton1, boardButton2, boardButton3, boardButton4, boardButton5]
        
        //Create the board pieces and add gestures to them
        for i in 0..<model.numberOfPieces {
            
            let name = model.imagePieceNameAtIndex(i)
            let pieceImage = UIImage(named: name)
            let pieceImageView = PieceImageView(image: pieceImage)
            pieceImageView.letter = model.pieceLetters[i]
            
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(roatePiece(_:)))
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(flipPiece(_:)))
            let pan = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
            
            singleTap.require(toFail: doubleTap)
            doubleTap.numberOfTapsRequired = 2
            
            pieceImageView.addGestureRecognizer(singleTap)
            pieceImageView.addGestureRecognizer(doubleTap)
            pieceImageView.addGestureRecognizer(pan)
            
            
            boardPieces.append(pieceImageView)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {

        //If puzzle is solved and rotation happens before reset we do not want to add pieces again, we want to keep them in sovled position
        if !solved {
            addPiecesToBoard()
        }
 
    }
    
    
    /**
     Initially sets all the board pieces in their respecitve contianer on the main view. Spaces them out based on their height and width. Moves piece to a new row if it will not fit in container view.
     */
    func addPiecesToBoard()
    {
        let containerSize = self.piecesContainer.bounds.size
        
        var xcord:CGFloat = 0.0
        var ycord:CGFloat = 0.0
        var maxHeight:CGFloat = 0.0
        
        
        
        for piece in self.boardPieces {
            
            piece.shouldBeInHint = true
            
            let pieceSize = piece.bounds.size
            
            if pieceSize.height > maxHeight {
                maxHeight = pieceSize.height
            }
            //If current x position and width of the piece are too big to be in container, update ycord to be below current row and reset x to be back at 0
            if xcord + pieceSize.width > containerSize.width {
                ycord = ycord + maxHeight + kVerticalSpaceForPieces
                xcord = 0.0
                maxHeight = 0.0
            }
            UIView.animate(withDuration: kAnimationDuration, animations: {
                let initialPieceFrame = CGRect(x: xcord, y: ycord, width: pieceSize.width, height: pieceSize.height)
                piece.frame = initialPieceFrame
                
                //Set the inital frame of piece to use later when resetting back to original position
                piece.intialFrame = initialPieceFrame
                
                xcord  = xcord + pieceSize.width + self.kHorizontalSpaceForPieces
                
                self.piecesContainer.addSubview(piece)
            })
            
            
            
        }
    }
    
    func resetPiecesToDefaultPosition()
    {
        solved = false
        //Enable board buttons to be able to switch boards
        enableButtons(true)
        
            for piece in self.boardPieces {
                
                //Setup each pentomino so that it can move from the board view to the container view
                moveView(piece, toSuperView: self.piecesContainer)
                

                        UIView.animate(withDuration: kAnimationDuration, animations: { 
                            
                            piece.transform = CGAffineTransform.identity;
                            
                            piece.frame = piece.intialFrame
                            }, completion: { (succeeded) in
                                piece.numberOfFlips = 0
                                piece.numberOfRotations = 0
                                piece.shouldBeInHint = true
                        })
                
                
            }
        
        //Call this to ensure that the container view is setup incase we rotated when it was solved and then reset right after. Without this pentominoes will not reset to container view if it was solved->not reset-> rotated-> reset
        viewDidLayoutSubviews()
    }
    
    func solveGame()
    {
        //Board number 0 is blank and cannot be solved so we skip if it is 0
        if(model.currentBoardNumber != 0) {
            
            //Disable buttons so board cannot be switched out while one is solved
            enableButtons(false)
        
            var pieceIndex = 0
                
            for letter in model.pieceLetters {
                
                let solution = model.solutionForPiece(pieceWithLetter: letter, onBoard: model.currentBoardNumber)
                
                let currentPiece = self.boardPieces[pieceIndex]
                
                //Setup each pentomino so that it can move from its container view to the board view
                moveView(currentPiece, toSuperView: self.boardImageView)
                
                //Get all info needed for the transition of the piece
                let xcord = CGFloat(solution["x"]!) * kSideOfSquare
                let ycord = CGFloat(solution["y"]!) * kSideOfSquare
                let flips = solution["flips"]
                let rotations = solution["rotations"]
                
                currentPiece.numberOfRotations = rotations!
                currentPiece.numberOfFlips = flips!
                
                //Animate piece to board image view rotating and/or flipping it if need be
                UIView.animate(withDuration: kAnimationDuration, animations: { 
                    if(rotations > 0) {
                        currentPiece.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2 * Double(rotations!)))
                    }
                    if(flips > 0) {
                        currentPiece.transform = currentPiece.transform.scaledBy(x: -1.0, y: 1.0);
                    }
                    
                    currentPiece.frame = CGRect(x: xcord, y: ycord, width: currentPiece.frame.size.width, height: currentPiece.frame.size.height)
                    self.boardImageView.addSubview(currentPiece)
                    }, completion: { (succeeded) in
                        currentPiece.shouldBeInHint = false
                })
                
                
                pieceIndex += 1;
            }
            
            
        }
        solved = true
    }
    
    func enableButtons(_ enabled:Bool)
    {
        for button in boardButtonArray {
            button.isEnabled = enabled
        }
        solveButton.isEnabled = enabled
        
    }
    
    
    //MARK: - Gesture Functions
    
    /**
     Rotate a pentominoe piece. If it is flipped we need to account for the way to rotate.
     
     - parameter tap: requires on single tap
     */
    func roatePiece(_ tap:UITapGestureRecognizer) {
        
        if let piece = tap.view as? PieceImageView {
            
            if tap.state == .ended {
                piece.addRotation()
                let direction = (piece.numberOfFlips == 1) ? -1 : 1 as Double
                
                UIView.animate(withDuration: kRotateAnimtionDuration, animations: {
                    piece.transform = piece.transform.rotated(by: CGFloat(M_PI_2 * direction))
                })
            }
        }
    }
    
    
    /**
     Flip a pentominoe piece to show its mirror image. Have to account for the number of rotations, to decide how we want to rotate it
     
     - parameter tap: requires a double tap
     */
    func flipPiece(_ tap:UITapGestureRecognizer) {
        if let piece = tap.view as? PieceImageView {
            if tap.state == .ended {
                piece.addFlip()
                
                let x = (piece.numberOfRotations % 2 == 0) ? -1: 1 as CGFloat
                let y = -x
                UIView.animate(withDuration: kFlipAnimationDuration, animations: {
                    piece.transform = piece.transform.scaledBy(x: x, y: y)
                })
            }
        }
    }
    
    func panPiece(_ pan:UIPanGestureRecognizer) {
        if let piece = pan.view as? PieceImageView {
            let center = pan.location(in: self.boardImageView)
            
            switch pan.state {
            case .began:
                moveView(piece, toSuperView: boardImageView)
                //Shrink the piece down when we begin moving it
                shrinkPiece(piece, shrink: true)
            case .changed:
                piece.center = center
            case .ended:
                //When it has been set or dropped by a finger unshrink it back to its original frame and transform
                shrinkPiece(piece, shrink: false)
                
                //If piece is on board snap it to the grid
                if isPieceOnBoard(piece) {
                    UIView.animate(withDuration: kSnapAnimationDuration, animations: {
                        self.snapPieceToGrid(piece)
                    })
                }else {
                    //If piece is not on board animate back to its original spot
                    resetPieceToInitialFrame(piece)
                }
            default:
                break
            }
        }
        
    }
    
    //MARK - Pan Helper Functions
    
    /**
     Animates the piece back to its original frame
     
     - parameter piece: pentomino piece that is being reset
     */
    func resetPieceToInitialFrame(_ piece:PieceImageView) {
        
        moveView(piece, toSuperView: piecesContainer)
        UIView.animate(withDuration: kAnimationDuration, animations: { 
            piece.frame = piece.intialFrame
            }, completion: { (succeeded) in
                //Because it is not on the board we set this to true, so if user needs a hint this piece will be revealed for them at some point
                piece.shouldBeInHint = true
        }) 
    }
    
    /**
     Checks if piece is on the board or not
     
     - parameter piece: piece that is being checked
     
     - returns: returns true if it is on the board, false otherwise
     */
    func isPieceOnBoard(_ piece:PieceImageView) -> Bool {
        
        let boardWidth = boardImageView.frame.size.width
        let boardHeight = boardImageView.frame.size.height
        if piece.center.x < boardWidth && piece.center.x > 0 && piece.center.y < boardHeight && piece.center.y > 0{
            return true
        }else {
            return false
        }
    }
    
    func snapPieceToGrid(_ piece:PieceImageView)
    {
        let x = piece.frame.origin.x / kSideOfSquare
        let y = piece.frame.origin.y / kSideOfSquare
        
        let newX = round(x) * kSideOfSquare
        let newY = round(y) * kSideOfSquare
        
        piece.frame = CGRect(x: newX, y: newY, width: piece.frame.size.width, height: piece.frame.size.height)
        //Because it is on the board we set this to false, so if user needs a hint this piece will not be revealed to them
        piece.shouldBeInHint = false
    }
    
    
    /**
     Shrink or unshrink piece using CGAffineTransformScale
     - parameter piece:  piece to be shrunk
     - parameter shrink: if true -> shrink it, if false -> bring back to original scale
     */
    func shrinkPiece(_ piece:PieceImageView, shrink:Bool) {
        
        if shrink {
           UIView.animate(withDuration: kSnapAnimationDuration, animations: { 
            piece.transform = piece.transform.scaledBy(x: self.kShrinkScale, y: self.kShrinkScale)
           })
        }else {
            UIView.animate(withDuration: kSnapAnimationDuration, animations: { 
                piece.transform = piece.transform.scaledBy(x: 1/self.kShrinkScale, y: 1/self.kShrinkScale)
            })
        }
    }
    
    
    
    
    
    
    /**
     Moves a view from its current superView to a new view
     
     - parameter view:      View to be moved
     - parameter superView: Super view that will contain view being passed
     */
    func moveView(_ view:UIView, toSuperView superView:UIView)
    {
        let newOrigin = superView.convert(view.frame.origin, from: view.superview)
        view.frame.origin = newOrigin
        superView.addSubview(view)
    }
    
    
    //MARK: - Segue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "HintSegue") {
            if let hintVC = segue.destination as? HintViewController {
                //Passing our model to the hint view controller so it can access properties of the pieces needed to determine if a piece should be in the hint or not, as well as the current board number to display that in the hint.
                hintVC.model = self.model
                hintVC.boardPieces = self.boardPieces
            }
        }
    }


}

