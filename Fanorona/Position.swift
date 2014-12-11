//
//  Position.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import Foundation

struct Position : Equatable{
    let x : Int
    let y : Int
    
    init(x: Int, y: Int){
        self.x = x
        self.y = y
    }
}

func == (left: Position, right: Position) -> Bool {
    return left.x == right.x && left.y == right.y
}