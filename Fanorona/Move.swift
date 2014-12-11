//
//  Move.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

enum MoveType{
    case Err
    case Paika
    case Approach
    case Withdrawal
}

struct Move {
    let stone: Stone
    let nextPos: Position
    let moveType: MoveType
    
    init(stone: Stone, nextPos: Position, moveType: MoveType){
        self.stone = stone
        self.nextPos = nextPos
        self.moveType = moveType
    }
}
