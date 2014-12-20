//
//  Position.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import Foundation

/**
    Class to determine a stone's position.
*/

struct Position : Equatable {
    let x : Int
    let y : Int
    
    /**
        Initializer - initializes a position.
    
        @param x-coordinate
        @param y-coordinate
    */
    
    init(x: Int, y: Int){
        self.x = x
        self.y = y
    }
    
    /**
        Copies this object in order to prevent referencing to the original state, when calculating nodes in the alpha beta tree.
    
        @return Cloned stone.
    */
    
    func clone() -> Position {
        return Position(x: x,y: y)
    }
    
}

/**
    Operator overloading of == for an equatable class.

    @param one Position
    @param another Position
    @return True when both are the same stones
*/

func == (left: Position, right: Position) -> Bool {
    return left.x == right.x && left.y == right.y
}