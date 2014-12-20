//
//  CollectionViewCell.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

/**
    Extension for an array to have the function 'contains' that checks whether the object is in that array or not.

    @param Equable object
    @return True if object is in the array, otherwise false
*/

extension Array {
    func contains<T : Equatable>(obj: T) -> Bool {
        let filtered = self.filter {$0 as? T == obj}
        return filtered.count > 0
    }
}

/**
    The Stone class is there to display the stones and to enable user interaction with them.
*/

class Stone : Equatable {
    
    var x: Int
    var y: Int
    var color: UIColor
    var invertIntersection: Bool
    var isStrongIntersection: Bool  // strong intersection when stone can go diagonal too
    // previous directions and positions to know what fields have been visited
    var prevPositions = [Position]()
    var prevDirection: Position?
    var button = UIButton.buttonWithType(.Custom) as UIButton
    var buttonSize: CGFloat!
    
    
    /**
        Initilizer - initiliazes a stone

        @param x-coordinate
        @param y-coordinate
        @param color player
    */
    
    init(x: Int, y: Int, stoneColor: UIColor){
        self.x = x
        self.y = y
        self.color = stoneColor
        self.invertIntersection = false
        self.isStrongIntersection = false
    }
    
    /**
        Copies this object in order to prevent referencing to the original state, when calculating nodes in the alpah beta tree.
        
        @return cloned stone
    */
    
    func clone() -> Stone{
        let stone = Stone(x: x,y: y,stoneColor: color)
        stone.buttonSize = buttonSize
        stone.setInvertIntersectionType(x, size_y: y)
        stone.setIntersectionType()
        stone.initButton()
        for p in prevPositions {
            stone.prevPositions.append(p.clone())
        }
        stone.prevDirection = prevDirection?.clone()
        return stone
    }
    
    /**
        Initializes the stone button
    */
    
    func initButton(){
        button.frame = CGRectMake(CGFloat(x)*buttonSize, CGFloat(y)*buttonSize, buttonSize, buttonSize)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.backgroundColor = color
        button.transform = CGAffineTransformMakeScale(0.9, 0.9)
    }
    
    /**
        Helper function to generate whether this is a stone with a strong intersection or not.
    */
    
    func setInvertIntersectionType(size_x: Int, size_y: Int) {
        let sqrtDiff = (size_x - size_y) * (size_x - size_y)
        self.invertIntersection = (sqrtDiff == 4 || sqrtDiff == 36 || sqrtDiff == 100)
    }
    
    /**
        Generates the intersection type of the stone.
    */
    
    func setIntersectionType() {
        if invertIntersection {
            self.isStrongIntersection = ((x + y) % 2 == 1)
        } else {
            self.isStrongIntersection = ((x + y) % 2 == 0)
        }
    }
    
    /**
        Determines whether the position has been visited or not.
        
        @param position that shall be determined
        @return true if it has
    */
    
    func posIsVisited(pos: Position) -> Bool{
        return prevPositions.contains(pos)
    }
    
    /**
        Determines whether the stone has gone that direction before or not.
    
        @param direction of the stone
        @return true if it has
    */
    
    func isSameDirection(pos: Position) -> Bool{
        return prevDirection == pos
    }
    
    /**
        The function clears the history of the stone's previous' visited fields for a new round.
    */
    
    func clearHistory(){
        prevPositions.removeAll()
        prevDirection = nil
    }
    
    /**
        Sets the new x-position for the stone and generates the inersection type.
    
        @param New x-coordinate
    */
    
    func setX(x: Int){
        self.x = x
        setIntersectionType()
    }
    
    /**
        Sets the new y-position for the stone and generates the inersection type.
    
        @param New y-coordinate
    */
    
    func setY(y: Int){
        self.y = y
        setIntersectionType()
    }
    
    /**
        Function that highlights a selected stone with a green border.
    */
    
    func selectStone(){
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.greenColor().CGColor
    }
    
    /**
        Function that turns the highlighted border off.
    */
    
    func deselectStone(){
        button.layer.borderWidth = 0
    }
    
    /**
        Function that highlights a capture-decision stone with a yellow border.
    */
    
    func captureDecision(){
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.yellowColor().CGColor
    }
    
}

/**
    Operator overloading of == for an equatable class.

    @param one Stone
    @param another Stone
    @return True when both are the same stones
*/

func == (left: Stone, right: Stone) -> Bool {
    return left.x == right.x && left.y == right.y && left.color == right.color
}
