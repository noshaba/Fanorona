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
    var move: Int!
    var turn: UIColor!
    var state = [Stone]()
    var multiMovePos: Position?
    
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
    
    private func alternateTurn(turn: UIColor){
        if turn == UIColor.blackColor(){
            self.turn = UIColor.whiteColor()
        } else {
            self.turn = UIColor.blackColor()
        }
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
            if isMoveAbleToCapture(stone,nextX: nextPos.x,nextY: nextPos.y){
                return true
            }
        }
        return false
    }
    
    func getPossibleMoves(stone: Stone) -> [Position] {
        let currentX = stone.x
        let currentY = stone.y
        var possibleMoves = [Position]()
        if posIsValid(currentX, y: currentY + 1) && posIsEmpty(currentX, y: currentY + 1) &&
            !stone.posIsVisited(Position(x: currentX, y: currentY + 1)) &&
            !stone.isSameDirection(Position(x: 0, y: 1)) {
            possibleMoves.append(Position(x: currentX, y: currentY + 1))
        }
        if posIsValid(currentX, y: currentY - 1) && posIsEmpty(currentX, y: currentY - 1) &&
            !stone.posIsVisited(Position(x: currentX, y: currentY - 1)) &&
            !stone.isSameDirection(Position(x: 0, y: -1)) {
                possibleMoves.append(Position(x: currentX, y: currentY + 1))
        }
        if posIsValid(currentX - 1, y: currentY) && posIsEmpty(currentX - 1, y: currentY) &&
            !stone.posIsVisited(Position(x: currentX - 1, y: currentY)) &&
            !stone.isSameDirection(Position(x: -1, y: 0)) {
                possibleMoves.append(Position(x: currentX - 1, y: currentY))
        }
        if posIsValid(currentX + 1, y: currentY) && posIsEmpty(currentX + 1, y: currentY) &&
            !stone.posIsVisited(Position(x: currentX + 1, y: currentY)) &&
            !stone.isSameDirection(Position(x: 1, y: 0)) {
                possibleMoves.append(Position(x: currentX, y: currentY + 1))
        }
        if stone.isStrongIntersection {
            if posIsValid(currentX + 1, y: currentY + 1) && posIsEmpty(currentX + 1, y: currentY + 1) &&
                !stone.posIsVisited(Position(x: currentX + 1, y: currentY + 1)) &&
                !stone.isSameDirection(Position(x: 1, y: 1)) {
                    possibleMoves.append(Position(x: currentX + 1, y: currentY + 1))
            }
            if posIsValid(currentX + 1, y: currentY - 1) && posIsEmpty(currentX + 1, y: currentY - 1) &&
                !stone.posIsVisited(Position(x: currentX + 1, y: currentY - 1)) &&
                !stone.isSameDirection(Position(x: 1, y: -1)) {
                    possibleMoves.append(Position(x: currentX + 1, y: currentY - 1))
            }
            if posIsValid(currentX - 1, y: currentY + 1) && posIsEmpty(currentX - 1, y: currentY + 1) &&
                !stone.posIsVisited(Position(x: currentX - 1, y: currentY + 1)) &&
                !stone.isSameDirection(Position(x: -1, y: 1)) {
                    possibleMoves.append(Position(x: currentX - 1, y: currentY + 1))
            }
            if posIsValid(currentX - 1, y: currentY - 1) && posIsEmpty(currentX - 1, y: currentY - 1) &&
                !stone.posIsVisited(Position(x: currentX - 1, y: currentY - 1)) &&
                !stone.isSameDirection(Position(x: -1, y: -1)) {
                    possibleMoves.append(Position(x: currentX - 1, y: currentY - 1))
            }
        }
        return possibleMoves
    }
    
    func isMoveAbleToCapture(stone: Stone, nextX: Int, nextY: Int) -> Bool {
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
        if approach || withdrawal {
            return true
        }
        return false
    }
}