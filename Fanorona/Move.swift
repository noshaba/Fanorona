//
//  Move.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

/**
    The MoveType determines whether the next possible move done by a player is a Paika, an Approach or Withdrawal Capture or if the player has two decisions for either Approach or Withdrwal.
*/

enum MoveType: Printable{
    case Err
    case Paika
    case Approach
    case Withdrawal
    case CaptureDecision
    var description : String {
        switch self {
        case .Err: return "Err"
        case .Paika: return "Paika"
        case .Approach: return "Approach"
        case .Withdrawal: return "Withdrawal"
        case .CaptureDecision: return "CaptureDecision"
        }
    }
}

/**
    The Move consists of a possible move a stone can make and its MoveType.
*/

struct Move {
    let stone: Stone!
    let nextPos: Position!
    let moveType: MoveType!
    
    init(stone: Stone, nextPos: Position, moveType: MoveType){
        self.stone = stone
        self.nextPos = nextPos
        self.moveType = moveType
    }
    
    /**
        Copies this object in order to prevent referencing to the original state, when calculating nodes in the alpah beta tree.
    
        @return Cloned move
    */
    
    func clone() -> Move {
        return Move(stone: stone.clone(),nextPos: nextPos.clone(),moveType: moveType)
    }
}
