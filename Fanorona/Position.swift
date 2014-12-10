//
//  Position.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import Foundation

class Position : Equatable{
    let x : Int
    let y : Int
    
    init(x: Int, y: Int){
        self.x = x
        self.y = y
    }
    
    func getX() -> Int { return self.x }
    func getY() -> Int { return self.y }
    func hashCode() -> Int { return self.x * 31 ^ self.y }
    func clone() -> Position { return Position(x: self.x,y: self.y) }
}

func == (left: Position, right: Position) -> Bool {
    return left.x == right.x && left.y == right.y
}