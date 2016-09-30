//
//  PieceImageView.swift
//  Pentominoes
//
//  Created by Julian Panucci on 9/12/16.
//  Copyright © 2016 Julian Panucci. All rights reserved.
//

import UIKit

class PieceImageView: UIImageView {
    
    var numberOfRotations = 0
    var numberOfFlips = 0
    var intialFrame = CGRectMake(0.0, 0.0, 0.0, 0.0)
    var shouldBeInHint = false
    var letter = ""
    
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset()
    {
        numberOfRotations = 0
        numberOfFlips = 0
        intialFrame = CGRectMake(0.0, 0.0, 0.0, 0.0)
    }
    
    func addFlip()
    {
        numberOfFlips += 1
        if numberOfFlips == 2 {
            numberOfFlips = 0
        }
    }
    
    func addRotation()
    {
        numberOfRotations += 1
        if numberOfRotations == 4 {
            numberOfRotations = 0
        }
    }

}
