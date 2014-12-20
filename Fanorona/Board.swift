//
//  Board.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

/**
    The Board creates the current board and calculates every possible move for a stone and updates the board according to the player's decision. Furthermore, it also checks whether a goal state was reached or not.
*/

class Board {
    // minimum and maximum board sizes
    var MIN_X: Int!
    var MAX_X: Int!
    var MIN_Y: Int!
    var MAX_Y: Int!
    // maximal number of moves possible, if 40 or moves required, then the game is a draw!
    var MAX_MOVE: Int!
    // possible move that determines a state
    var move: Int
    // current turn color
    var turn: UIColor
    // current state of the board
    var state = [Stone]()
    // determines if a stone can do a successive capture
    var multiMovePos: Position?
    // determines the difference between the number of white and black stones.
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
    // determines the number of the opponent's stones.
    var utilityOpponentCount: Int {
        var count = 0
        for stone in state {
            if stone.color != turn {
                ++count
            }
        }
        return count
    }
    
    /**
        Goalstates for the game.
    */
    
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
        
        // The number of -999 and 999 has been chosen for goal nodes because they should be weighted heigher than cut off nodes and that would not be possible when you can get values that are higher than 1 or lower than -1 for the utility value. The values for the goal states can be found in the Board class in the enum 'GoalState'.
        
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
    
    /**
        Default initilizer.
    */
    
    init(){
        move = 0
        turn = UIColor.whiteColor()
    }
    
    /**
        Resets the board to the starting settings.
    
        @param size in x direction
        @param size in y direction
    */
    
    func reset(x: Int, y: Int){
        turn = UIColor.whiteColor()
        multiMovePos = nil
        initWithSize(x,y: y)
    }
    
    /**
        Initiliazes the board with a board width and height.
    
        @param size in x direction
        @param size in y direction
    */
    
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
    
    /**
        Changes the current turn to the other player's turn.
    
        @param One player's turn.
    */
    
    func alternateTurn(turn: UIColor){
        if turn == UIColor.blackColor(){
            self.turn = UIColor.whiteColor()
        } else {
            self.turn = UIColor.blackColor()
        }
    }
    
    /**
        Copies this object in order to prevent referencing to the original state, when calculating nodes in the alpah beta tree.
    
        @return Cloned board
    */
    
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
    
    /**
        Returns the stone when it is found in the state of the board. Returns 'nil' if the stone was not found.
    
        @param x-coordinate of the searched stone
        @param y-coordinate of the searched stone
        @return Stone or nil
    */
    
    func getStone(x: Int, y: Int) -> Stone? {
        for stone in state {
            if stone.x == x && stone.y == y {
                return stone
            }
        }
        return nil
    }
    
    /**
        Checks whether a position is empty or not.
    
        @param x-coordinate of position
        @param y-coordinate of position
        @return true when the position is empty
    */
    
    func posIsEmpty(x: Int, y: Int) -> Bool {
        for stone in state {
            if stone.x == x && stone.y == y {
                return false
            }
        }
        return true
    }
    
    /**
        Checks whether a position is in the given board height and width of a board.
    
        @param x-coordinate of position
        @param y-coordinate of position
        @return true when the position is within those limits.
    */
    
    func posIsValid(x: Int, y:Int) -> Bool {
        return x >= MIN_X && x <= MAX_X && y >= MIN_Y && y <= MAX_Y
    }
    
    /**
        Checks whether a turn is a Paika turn or not.
    
        @param color of player
        @return true if Paika
    */
    
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
    
    /**
        Checks whether a stone is able to capture or not.
    
        @param Stone that shall be checked.
        @return true if able to capture
    */
    
    func ableToCapture(stone: Stone) -> Bool {
        var possibleMoves = getPossibleMoves(stone)
        for nextPos in possibleMoves {
            if moveIsAbleToCapture(stone,nextX: nextPos.x,nextY: nextPos.y) != .Paika {
                return true
            }
        }
        return false
    }
    
    /**
        Calculates the possible moves for one stone (no successive captures)
    
        @param Stone that shall be checked
        @return Close fields that are valid to go
    */
    
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
    
    /**
        Checks whether a move is able to capture or not. If it is it determines whether is a withdrawal capture or approach capture or if both is possible.
    
        @param Stone that's move shall be checked.
        @param next x-coordinate of the stone
        @param next y-coordinate of the stone
        @return type of move
    */
    
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
    
    /**
        Calculates all the possible moves from a stone (with successive captures)
    
        @return possible moves of stone
    */
    
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
                    // Paika moves are not included
                    if moveIsAbleToCapture(stone, nextX: position.x, nextY: position.y) == .Paika {
                        continue
                    }
                    moves.append(Move(stone: stone,nextPos: position,moveType: moveStone(stone,nextX: position.x,nextY: position.y)))
                }
            }
        }
        return moves
    }
    
    /**
         Moves the stone from one position to another and determines the resulting move type.
    */
    
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
    
    /**
        Updates the board according to the move applied to one stone.
    
        @param next move of stone
    */
    
    func updateBoard(nextMove: Move){
        let stone = nextMove.stone
        let nextX = nextMove.nextPos.x
        let nextY = nextMove.nextPos.y
        let moveType = nextMove.moveType
        updateBoard(moveType, stone: stone, nextX: nextX, nextY: nextY)
    }
    
    /**
        Updates the board according to the move applied to one stone.
    
        @param move type of next move
        @param stone that shall be moved
        @param next x-coordinate of the stone
        @param next y-coordinate of the stone
    */
    
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
        stone.button.transform = CGAffineTransformMakeScale(1, 1)
        stone.button.frame.origin.x = CGFloat(nextX)*stone.buttonSize
        stone.button.frame.origin.y = CGFloat(nextY)*stone.buttonSize
        stone.button.transform = CGAffineTransformMakeScale(0.9, 0.9)
        ++move
        checkGoalState()
    }
    
    /**
        Removes a stone from the board
    
        @param Stone
    */
    
    func removeStone(stone: Stone){
        state.removeAtIndex(find(state,stone)!)
        stone.button.removeFromSuperview()
    }
    
    /**
        Determines the goalstate of the board.
    
        @return goal state
    */
    
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