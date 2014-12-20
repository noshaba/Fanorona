//
//  AI.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

/**
    The AI determines the computer's next turn by using Alpha-Beta pruning
    For the utility function the difference between white and black has been chosen, weighted by the number of stones of the opposite color. The number of -999 and 999 has been chosen for goal nodes because they should be weighted heigher than cut off nodes and that would not be possible when you can get values that are higher than 1 or lower than -1 for the utility value. The values for the goal states can be found in the Board class in the enum 'GoalState'.
*/

class AI {
    // Difficulty level of AI
    enum UtilType{
        case Easy
        case Medium
        case Hard
    }
    // alpha-beta pruning stats
    var alphaCut = 0
    var betaCut = 0
    var generatedNodes = 0
    var earlyCut = false
    var startTime = NSDate().timeIntervalSince1970
    
    var utilType: UtilType  // difficulty level
    var rootNode: AINode    // root node of tree
    var aiColor: UIColor    // stone color of AI
    
    init(aiColor: UIColor, utilType: UtilType, gameBoard: Board){
        self.aiColor = aiColor
        self.utilType = utilType
        rootNode = AINode(state: gameBoard)
    }
    
    /**
        Calculates the depth of the search tree recursively.
    
        @param node Rootnode of the tree.
        @return Height of tree.
    */
    
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
    
    /**
        Prints the Alpha-Beta Pruning statistics on the console.
    */
    
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
    
    /**
        Calculates the best possible move by the AI depending on the difficulty level.
    
        @return Best move depending on difficulty level.
    */
    
    func getBestMove() -> Move? {
        if utilType == .Easy {
            let possibleMoves = rootNode.state.getAllPossibleMoves()
            return possibleMoves[Int(arc4random_uniform(UInt32(possibleMoves.count)))]
        }
        return alphaBetaSearch()
    }
    
    /**
        Creates the Alpha-Beta search tree and returns the best possible move determined by the Alpha-Beta pruning algorithm depending on the level of difficulty the AI has.
    
        @return Best move calculated with Alpha-Beta pruning and depending on AI's difficulty level.
    */
    
    func alphaBetaSearch() -> Move? {
        var value : Int
        if aiColor == UIColor.blackColor(){
            // if AI is black
            value = minBlackValue(rootNode, alpha: -999, beta: 999)
        } else {
            // if AI is white
            value = maxWhiteValue(rootNode, alpha: -999, beta: 999)
        }
        println("value: \(value)")
        printStats()
        for var i = 0; i < rootNode.subNodes.count; ++i {
            if rootNode.subNodes[i].utilVal == value {
                return rootNode.state.getAllPossibleMoves()[i]
            }
        }
        return nil
    }
    
    /**
        Function for max player(white)
    
        @param node Max node
        @param alpha Alpha value from node before.
        @param beta Beta value from node befoe.
        @return Current value at that node.
    */
    
    func maxWhiteValue(node: AINode,var alpha: Int, beta: Int) -> Int {
        if NSDate().timeIntervalSince1970 - startTime >= 10 {
            earlyCut = true
        }
        if node.state.checkGoalState() != .Continue {
            // if game is not over try to calculate the whole tree
            node.utilVal = node.state.checkGoalState().value!
            println("node value: \(node.utilVal)")
            return node.utilVal
        } else if utilType == .Medium && earlyCut {
            // if early cut off, then use the evaluation function
            // evaluation function: difference of white and black stones weighted by the total number of the opponents stones for that state
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
    
    /**
        Function for min player(black)
    
        @param node Min node
        @param alpha Alpha value from node before.
        @param beta Beta value from node befoe.
        @return Current value at that node.
    */
    
    func minBlackValue(node: AINode,alpha: Int, var beta: Int) -> Int {
        if NSDate().timeIntervalSince1970 - startTime >= 10 {
            earlyCut = true
        }
        if node.state.checkGoalState() != .Continue {
            // if game is not over try to calculate the whole tree
            node.utilVal = node.state.checkGoalState().value!
            println("node value: \(node.utilVal)")
            return node.utilVal
        } else if utilType == .Medium && earlyCut {
            if node.state.utilityOpponentCount == 0 {
            // if early cut off, then use the evaluation function
            // evaluation function: difference of white and black stones weighted by the total number of the opponents stones for that state
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
    
    /**
        AINode is a node in a alpha-beta tree.
    */
    
    class AINode {
        var utilVal: Int!           // utility v6alue of that node
        var state: Board            // state of the board resulting by a possible move
        var subNodes = [AINode]()   // children of a node
        
        init(state:Board){
            self.state = state
        }
    }
}