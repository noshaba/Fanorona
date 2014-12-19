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
    var alphaCut = 0
    var betaCut = 0
    var generatedNodes = 0
    var earlyCut = false
    var startTime = NSDate().timeIntervalSince1970
    
    var utilType: UtilType
    var rootNode: AINode
    
    init(utilType: UtilType, gameBoard: Board){
        self.utilType = utilType
        rootNode = AINode(state: gameBoard)
    }
    
    func getDepthOfTree(node: AINode) -> Int{
        if node.subNodes.isEmpty {
            return 0
        }
        var maxDepth = 0
        for child in node.subNodes {
            maxDepth = max(maxDepth,getDepthOfTree(child))
        }
        return maxDepth + 1
    }
    
    func printStats(){
        println()
        println("----------Game Tree Stats----------")
        println("Early cut-off: \(earlyCut)")
        println("Max. depth of game tree: \(getDepthOfTree(rootNode))")
        println("Total number of nodes generated: \(generatedNodes)")
        println("Alpha-Cut: \(alphaCut)")
        println("Beta-Cut: \(betaCut)")
        println("-----------------------------------")
        println()
    }
    
    func getBestMove() -> Move? {
        if utilType == .Random {
            let possibleMoves = rootNode.state.getAllPossibleMoves()
            return possibleMoves[Int(arc4random_uniform(UInt32(possibleMoves.count)))]
        }
        return alphaBetaSearch()
    }
    
    func alphaBetaSearch() -> Move? {
        let value = minBlackValue(rootNode, alpha: -999999, beta: 999999)
        println("value: \(value)")
        printStats()
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
        if NSDate().timeIntervalSinceNow - startTime == 1000 {
            earlyCut = true
        }
        if node.state.checkGoalState() != .Continue {
            node.utilVal = node.state.checkGoalState().value!
            println("node value: \(node.utilVal)")
            return node.utilVal
        } else if earlyCut {
            if node.state.utilityOpponentCount == 0 {
                node.utilVal = node.state.utilityDifference
            } else {
                node.utilVal = node.state.utilityDifference/node.state.utilityOpponentCount
            }
            println("node value: \(node.utilVal)")
            return node.utilVal
        }
        node.utilVal = -999
        ++generatedNodes
        let moves = node.state.getAllPossibleMoves()
        var subNode: AINode
        for move in moves {
            subNode = AINode(state: node.state.clone())
            subNode.state.updateBoard(move.clone())
            node.subNodes.append(subNode)
            node.utilVal = max(node.utilVal, minBlackValue(subNode,alpha: alpha,beta: beta))
            if node.utilVal >= beta {
                // beta cut-off
                println("BetaCut")
                ++betaCut
                return node.utilVal
            }
            alpha = max(alpha,node.utilVal)
        }
        return node.utilVal
    }
    
    func minBlackValue(node: AINode,alpha: Int, var beta: Int) -> Int {
        if NSDate().timeIntervalSinceNow - startTime == 1000 {
            earlyCut = true
        }
        if node.state.checkGoalState() != .Continue {
            node.utilVal = node.state.checkGoalState().value!
            println("node value: \(node.utilVal)")
            return node.utilVal
        } else if earlyCut {
            if node.state.utilityOpponentCount == 0 {
                node.utilVal = node.state.utilityDifference
            } else {
                node.utilVal = node.state.utilityDifference/node.state.utilityOpponentCount
            }
            println("node value: \(node.utilVal)")
            return node.utilVal
        }
        node.utilVal = 999
        ++generatedNodes
        let moves = node.state.getAllPossibleMoves()
        var subNode: AINode
        for move in moves {
            subNode = AINode(state: node.state.clone())
            subNode.state.updateBoard(move.clone())
            node.subNodes.append(subNode)
            node.utilVal = min(node.utilVal, maxWhiteValue(subNode,alpha: alpha,beta: beta))
            if node.utilVal <= alpha {
                // alpha cut-off
                println("AlphaCut")
                ++alphaCut
                return node.utilVal
            }
            beta = min(beta,node.utilVal)
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