//
//  PModel.swift
//  Pentominoes
//
//  Created by Julian Panucci on 9/11/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import Foundation


class PentominoeModel {

    fileprivate let numberOfBoards = 6
    let pieceLetters = ["F", "I", "L", "N", "P", "T", "U","V","W","X","Y","Z"]
    let numberOfPieces:Int
    
    let solutions:NSArray!
    var pieces = [String]()
    var boards = [String]()
    var currentBoardNumber = 0
    
    
    init() {
        
        let solutionPath = Bundle.main.path(forResource: "Solutions", ofType: "plist")
        self.solutions = NSArray(contentsOfFile: solutionPath!)
  
        //Create array of pieces' image names
        for letter in pieceLetters {
            let piece = "tile\(letter).png"
            pieces.append(piece)
        }
        //Create array of boards' image names
        for i in 0..<numberOfBoards {
            let board = "Board\(i).png"
            self.boards.append(board)
        }
        
        numberOfPieces = pieceLetters.count
        
    }
    
    func imageBoardNameAtIndex(_ index:Int) -> String {
        return self.boards[index]
    }
    
    func imagePieceNameAtIndex(_ index:Int) -> String{
        return self.pieces[index]
    }
    
    /**
     Returns the solution which for a specific pentomino piece. Contains xcord, ycord, number of flips, and number of rotations.
     
     - parameter letter: The letter of the specific pentomonio piece
     - parameter board:  The number of the board for which is the correct solution for the letter
     
     - returns: The solution for that letter on that specific board
     */
    func solutionForPiece(pieceWithLetter letter:String, onBoard board:Int) -> [String:Int] {
        
        let solution = solutions[board - 1] as! NSDictionary
        let newSolution = solution.value(forKey: letter) as! [String:Int]
        
        
        return newSolution
    }
    
}
