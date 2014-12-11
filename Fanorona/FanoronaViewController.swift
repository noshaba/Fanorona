//
//  FanoronaViewController.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

class FanoronaViewController: UIViewController{
    let board = Board()
    var boardWidth: Int
    var boardHeight: Int
    var time: Int!
    var aiVersion: Int?
    var aiDepth: Int?
    var goalState: Board.GoalState
    var fromX: Int!
    var fromY: Int!
    var captureX: Int!
    var captureY: Int!
    var toX: Int!
    var toY: Int!
    var moveType: Int!
    var approachRemoveX: Int!
    var approachRemoveY: Int!
    var withdrwalRemoveX: Int!
    var withdrwalRemoveY: Int!
    var isStoneSelected: Bool
    var forceUserToMove: Bool
    var mustDecideCaptureDirection: Bool
    var isGameOver: Bool
    var isOpponentAI: Bool
    var isPaikaGlobal: Bool!
    var isSacrificeGlobal: Bool!
    var timer: NSTimer!
    
    override init() {
        boardWidth = 9
        boardHeight = 5
        isOpponentAI = true
        if isOpponentAI {
            aiVersion = 0
            aiDepth = 2
        }
        goalState = .Continue
        isStoneSelected = false
        forceUserToMove = false
        mustDecideCaptureDirection = false
        isGameOver = false
        board.reset(boardWidth, y: boardHeight)
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

