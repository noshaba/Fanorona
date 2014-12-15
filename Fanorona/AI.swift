//
//  AI.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

class AI {
    enum UtilType{
        case Random
        case Difference
        case OpponentCount
    }
    
    var utilType: UtilType
    var rootNode: AINode
    
    init(utilType: UtilType, gameBoard: Board){
        self.utilType = utilType
        rootNode = AINode(state: gameBoard)
    }
    
    func getBestMove() -> Move? {
        if utilType == .Random {
            let possibleMoves = rootNode.state.getAllPossibleMoves()
            return possibleMoves[Int(arc4random_uniform(UInt32(possibleMoves.count)))]
        }
        return alphaBetaSearch()
    }
    
    func alphaBetaSearch() -> Move? {
        let value = maxWhiteValue(rootNode, alpha: -999999, beta: 999999)
        for var i = 0; i < rootNode.subNodes.count; ++i {
            if rootNode.subNodes[i].utilVal == value {
                println("yay")
                return rootNode.state.getAllPossibleMoves()[i]
            }
        }
        println(":(")
        return nil
    }
    
    func maxWhiteValue(node: AINode,var alpha: Int, beta: Int) -> Int {
        if node.state.checkGoalState() != .Continue {
            node.utilVal = node.state.checkGoalState().value!
            return node.utilVal
        }
        node.utilVal = -999999
        let moves = node.state.getAllPossibleMoves()
        var subNode: AINode
        for move in moves {
            subNode = AINode(state: node.state.clone())
            subNode.state.updateBoard(move.clone())
            node.subNodes.append(subNode)
            node.utilVal = max(node.utilVal, minBlackValue(subNode,alpha: alpha,beta: beta))
            if node.utilVal >= beta {
                return node.utilVal
            }
            alpha = max(alpha,node.utilVal)
        }
        return node.utilVal
    }
    
    func minBlackValue(node: AINode,alpha: Int, var beta: Int) -> Int {
        if node.state.checkGoalState() != .Continue {
            node.utilVal = node.state.checkGoalState().value!
            return node.utilVal
        }
        node.utilVal = 999999
        let moves = node.state.getAllPossibleMoves()
        var subNode: AINode
        for move in moves {
            subNode = AINode(state: node.state.clone())
            subNode.state.updateBoard(move.clone())
            node.subNodes.append(subNode)
            node.utilVal = min(node.utilVal, maxWhiteValue(subNode,alpha: alpha,beta: beta))
            if node.utilVal <= alpha {
                return node.utilVal
            }
            beta = min(alpha,node.utilVal)
        }
        return node.utilVal
    }
    
    class AINode {
        var utilVal: Int!
        var state: Board
        var subNodes = [AINode]()
        
        init(state:Board){
            self.state = state
        }
    }
}