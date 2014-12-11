//
//  AI.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import Foundation

class AI {
    enum UtilType{
        case Random
    }
    
    var utilType: UtilType
    var rootNode: AINode
    
    init(utilType: UtilType, gameBoard: Board){
        self.utilType = utilType
        rootNode = AINode(node: gameBoard)
    }
    
    func getBestMove() -> Move {
        let possibleMoves = rootNode.node.getAllPossibleMoves()
        return possibleMoves[Int(arc4random_uniform(UInt32(possibleMoves.count)))]
    }
    
    class AINode {
        var utilVal: Int!
        var node: Board
        var subNodes = [Board]()
        
        init(node:Board){
            self.node = node
        }
    }
}