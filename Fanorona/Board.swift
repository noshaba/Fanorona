//
//  Board.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

class Board {
    var MIN_X: Int!
    var MAX_X: Int!
    var MIN_Y: Int!
    var MAX_Y: Int!
    var MAX_MOVE: Int!
    var move: Int
    var turn: UIColor
    var state = [Stone]()
    var multiMovePos: Position?
    var utilityDifference: Int{
        var white = 0
        var black = 0
        for stone in state {
            if stone.color == UIColor.whiteColor() {
                ++white
            } else {
                ++black
            }
        }
        return white - black
    }
    
    var utilityOpponentCount: Int {
        var count = 0
        for stone in state {
            if stone.color != turn {
                ++count
            }
        }
        return count
    }
    
    enum GoalState: Printable{
        case Draw
        case WhiteWon
        case BlackWon
        case Continue
        
        var description: String{
            switch self {
            case .Draw: return "Draw"
            case .WhiteWon: return "White won"
            case .BlackWon: return "Black won"
            case .Continue: return "Game continues"
            }
        }
        
        var value: Int? {
            switch self {
            case .Draw: return 0
            case .WhiteWon: return 999
            case .BlackWon: return -999
            default:
                return nil
            }
        }
    }
    
    init(){
        move = 0
        turn = UIColor.whiteColor()
    }
    
    func reset(x: Int, y: Int){
        turn = UIColor.whiteColor()
        multiMovePos = nil
        initWithSize(x,y: y)
    }
    
    private func initWithSize(x: Int, y: Int){
        move = 0
        state.removeAll()
        MIN_X = 0
        MIN_Y = 0
        MAX_X = x - 1
        MAX_Y = y - 1
        MAX_MOVE = y * 10
        
        if x % 2 != 1 || y % 2 != 1 {
            return
        }
        if x == 1 && y == 1 {
            return
        }
        for var i = 0; i < x; ++i {
            for var j = 0; j < y / 2; ++j {
                state.append(Stone(x: i,y: j,stoneColor: UIColor.blackColor()))
            }
        }
        for var i = 0; i < x / 2; ++i {
            if i % 2 == 0 {
                state.append(Stone(x: i, y: y / 2, stoneColor: UIColor.blackColor()))
            } else {
                state.append(Stone(x: i, y: y / 2, stoneColor: UIColor.whiteColor()))
            }
        }
        for var i = x / 2 + 1; i < x; ++i {
            if (i % 2 == 0) {
                state.append(Stone(x: i, y: y / 2, stoneColor: UIColor.whiteColor()))
            } else {
                state.append(Stone(x: i, y: y / 2, stoneColor: UIColor.blackColor()))
            }
        }
        for var i = 0; i < x; ++i {
            for var j = y / 2 + 1; j < y; ++j{
                state.append(Stone(x: i, y: j, stoneColor: UIColor.whiteColor()))
            }
        }
        
        for stone in state {
            stone.setInvertIntersectionType(x, size_y: y)
            stone.setIntersectionType()
        }
    }
    
    func alternateTurn(turn: UIColor){
        if turn == UIColor.blackColor(){
            self.turn = UIColor.whiteColor()
        } else {
            self.turn = UIColor.blackColor()
        }
    }
    
    func clone() -> Board{
        let board = Board()
        board.MIN_X = MIN_X
        board.MIN_Y = MIN_Y
        board.MAX_X = MAX_X
        board.MAX_Y = MAX_Y
        board.MAX_MOVE = MAX_MOVE
        board.move = move
        for stn in state {
            board.state.append(stn.clone())
        }
        board.multiMovePos = multiMovePos?.clone()
        board.turn = turn
        return board
    }
    
    func getStone(x: Int, y: Int) -> Stone? {
        for stone in state {
            if stone.x == x && stone.y == y {
                return stone
            }
        }
        return nil
    }
    
    func posIsEmpty(x: Int, y: Int) -> Bool {
        for stone in state {
            if stone.x == x && stone.y == y {
                return false
            }
        }
        return true
    }
    
    func posIsValid(x: Int, y:Int) -> Bool {
        return x >= MIN_X && x <= MAX_X && y >= MIN_Y && y <= MAX_Y
    }
    
    func isPaika(turn: UIColor) -> Bool {
        var stones = [Stone]()
        for stone in state {
            if stone.color == turn {
                stones.append(stone)
            }
        }
        for stone in stones{
            if ableToCapture(stone){
                return false
            }
        }
        return true
    }
    
    func ableToCapture(stone: Stone) -> Bool {
        var possibleMoves = getPossibleMoves(stone)
        for nextPos in possibleMoves {
            if moveIsAbleToCapture(stone,nextX: nextPos.x,nextY: nextPos.y) != .Paika {
                return true
            }
        }
        return false
    }
    
    func getPossibleMoves(stone: Stone) -> [Position] {
        let currentX = stone.x
        let currentY = stone.y
        var possibleMoves = [Position]()
        for var i = -1; i <= 1; ++i {
            for var j = -1; j <= 1; ++j {
                if i == 0 && j == 0{
                    continue
                }
                if !stone.isStrongIntersection && i*i == j*j {
                    continue
                }
                if posIsValid(currentX + i, y: currentY + j) && posIsEmpty(currentX + i, y: currentY + j) && !stone.posIsVisited(Position(x: currentX + i, y: currentY + j))
                    && !stone.isSameDirection(Position(x: i, y: j)) {
                        possibleMoves.append(Position(x: currentX + i, y: currentY + j))
                }
            }
        }
        return possibleMoves
    }
    
    func moveIsAbleToCapture(stone: Stone, nextX: Int, nextY: Int) -> MoveType {
        let currentX = stone.x
        let currentY = stone.y
        let diffX = nextX - currentX
        let diffY = nextY - currentY
        let withdrawalStn = getStone(currentX - diffX, y: currentY - diffY)
        let approachStn = getStone(currentX + 2 * diffX, y: currentY + 2 * diffY)
        var approach = false
        var withdrawal = false
        if withdrawalStn != nil && stone.color != withdrawalStn?.color {
            withdrawal = true;
        }
        if approachStn != nil && stone.color != approachStn?.color {
            approach = true;
        }
        if approach && withdrawal {
            return .CaptureDecision
        }
        if approach {
            return .Approach
        }
        if withdrawal {
            return .Withdrawal
        }
        return .Paika
    }
    
    func getAllPossibleMoves() -> [Move] {
        var moves = [Move]()
        var stones = [Stone]()
        if multiMovePos != nil {
            stones.append(getStone(multiMovePos!.x,y: multiMovePos!.y)!)
        } else {
            for stone in state {
                if stone.color == turn {
                    stones.append(stone)
                }
            }
        }
        for stone in stones {
            let moveFromOneStone = getPossibleMoves(stone)
            for position in moveFromOneStone {
                if(isPaika(turn)){
                    moves.append(Move(stone: stone,nextPos: position,moveType: moveStone(stone,nextX: position.x,nextY: position.y)))
                } else {
                    if moveIsAbleToCapture(stone, nextX: position.x, nextY: position.y) == .Paika {
                        continue
                    }
                    moves.append(Move(stone: stone,nextPos: position,moveType: moveStone(stone,nextX: position.x,nextY: position.y)))
                }
            }
        }
        return moves
    }
    
    func moveStone(stone: Stone, nextX: Int, nextY: Int) -> MoveType {
        if turn != stone.color {
            println("NOT YOUR TURN!")
            return .Err
        }
        let currentX = stone.x
        let currentY = stone.y
        if multiMovePos != nil && multiMovePos != Position(x: currentX,y: currentY){
            return .Err
        }
        let diffX = nextX - currentX
        let diffY = nextY - currentY
        let diffX2 = diffX * diffX
        let diffY2 = diffY * diffY
        var withdrawal = false
        var approach = false
        if !posIsEmpty(nextX, y: nextY) || !posIsValid(nextX, y: nextY){
            return .Err
        }
        if diffX2 > 1 || diffY2 > 1 {
            return .Err
        }
        if !stone.isStrongIntersection {
            if diffX2 == 1 && diffY2 == 1 {
                return .Err
            }
        }
        if isPaika(turn){
            return .Paika
        }
        let approachStn = getStone(currentX + 2 * diffX, y: currentY + 2 * diffY)
        let withdrawalStn = getStone(currentX - diffX, y: currentY - diffY)
        if withdrawalStn != nil && stone.color != withdrawalStn?.color {
            withdrawal = true
        }
        if approachStn != nil && stone.color != approachStn?.color {
            approach = true
        }
        if stone.isSameDirection(Position(x: diffX, y: diffY)){
            return .Err
        }
        if stone.posIsVisited(Position(x: nextX, y: nextY)){
            return .Err
        }
        if approach && withdrawal{
            return .CaptureDecision
        }
        if approach {
            return .Approach
        }
        if withdrawal{
            return .Withdrawal
        }
        return .Err
    }
    
    func updateBoard(nextMove: Move){
        let stone = nextMove.stone
        let nextX = nextMove.nextPos.x
        let nextY = nextMove.nextPos.y
        let moveType = nextMove.moveType
        updateBoard(moveType, stone: stone, nextX: nextX, nextY: nextY)
    }
    
    func updateBoard(moveType: MoveType, stone: Stone, nextX: Int, nextY: Int){
        let currentX = stone.x
        let currentY = stone.y
        let diffX = nextX - currentX
        let diffY = nextY - currentY
        if moveType == .Approach || moveType == .Withdrawal {
            if moveType == .Approach {
                var removePosX = currentX + 2 * diffX
                var removePosY = currentY + 2 * diffY
                while true {
                    let stoneToBeRemoved = getStone(removePosX, y: removePosY)
                    if stoneToBeRemoved == nil || stoneToBeRemoved?.color == turn {
                        break
                    }
                    removeStone(stoneToBeRemoved!)
                    if diffX < 0 {
                        --removePosX
                    }
                    if diffX > 0 {
                        ++removePosX
                    }
                    if diffY < 0 {
                        --removePosY
                    }
                    if diffY > 0 {
                        ++removePosY
                    }
                }
            }
            if moveType == .Withdrawal {
                var removePosX = currentX - diffX
                var removePosY = currentY - diffY
                while true {
                    let stoneToBeRemoved = getStone(removePosX, y: removePosY)
                    if stoneToBeRemoved == nil || stoneToBeRemoved?.color == turn {
                        break
                    }
                    removeStone(stoneToBeRemoved!)
                    if diffX < 0 {
                        ++removePosX
                    }
                    if diffX > 0 {
                        --removePosX
                    }
                    if diffY < 0 {
                        ++removePosY
                    }
                    if diffY > 0 {
                        --removePosY
                    }
                }
            }
            state.removeAtIndex(find(state,stone)!)
            stone.setX(nextX)
            stone.setY(nextY)
            stone.prevDirection = Position(x: diffX, y: diffY)
            stone.prevPositions.append(Position(x: currentX, y: currentY))
            state.append(stone)
            multiMovePos = Position(x: nextX, y: nextY)
            if !ableToCapture(stone){
                stone.clearHistory()
                alternateTurn(turn)
                multiMovePos = nil
            }
        } else {
            state.removeAtIndex(find(state,stone)!)
            stone.setX(nextX)
            stone.setY(nextY)
            state.append(stone)
            alternateTurn(turn)
            multiMovePos = nil
        }
//        UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseOut, animations: {
        stone.button.transform = CGAffineTransformMakeScale(1, 1)
        stone.button.frame.origin.x = CGFloat(nextX)*stone.buttonSize
        stone.button.frame.origin.y = CGFloat(nextY)*stone.buttonSize
        stone.button.transform = CGAffineTransformMakeScale(0.9, 0.9)
//            }, completion: { finished in
//                println("stone moved")
//        })
        ++move
        checkGoalState()
    }
    
    func removeStone(stone: Stone){
        state.removeAtIndex(find(state,stone)!)
        stone.button.removeFromSuperview()
    }
    
    func checkGoalState() -> GoalState {
        var whiteCount = 0
        var blackCount = 0
        if (move >= MAX_MOVE) {
            println("Draw!")
            return .Draw
        }
        for stone in state {
            if stone.color == UIColor.whiteColor() {
                ++whiteCount
            } else {
                ++blackCount
            }
        }
        if whiteCount == 0 {
            println("Black Won!")
            return .BlackWon
        }
        if blackCount == 0 {
            println("White Won!")
            return .WhiteWon
        }
        return .Continue
    }
}