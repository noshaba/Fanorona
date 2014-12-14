//
//  Move.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

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
