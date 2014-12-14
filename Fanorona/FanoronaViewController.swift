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
    var boardWidth: Int!
    var boardHeight: Int!
    var time: Int!
    var aiVersion: Int?
    var aiDepth: Int?
    var goalState: Board.GoalState!
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
    var isStoneSelected: Bool!
    var forceUserToMove: Bool!
    var mustDecideCaptureDirection: Bool!
    var isGameOver: Bool!
    var isOpponentAI: Bool!
    var isPaikaGlobal: Bool!
    var isSacrificeGlobal: Bool!
    var timer: NSTimer!
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var headerHeight: CGFloat{
        return navigationBar.frame.size.height
    }
    let boardFrameSize: CGFloat = 20
    var boardHeightSize: CGFloat!
    var boardWidthSize: CGFloat!
    var boardOriginX: CGFloat!
    var boardOriginY: CGFloat!
    var cellSize: CGFloat!
    var collectionView: UICollectionView!
    
    required init(coder aDecoder: NSCoder) {
        boardWidth = 9
        boardHeight = 5
        isOpponentAI = true
        if isOpponentAI! {
            aiVersion = 0
            aiDepth = 2
        }
        goalState = .Continue
        isStoneSelected = false
        forceUserToMove = false
        mustDecideCaptureDirection = false
        isGameOver = false
        board.reset(boardWidth, y: boardHeight)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        boardOriginX = boardFrameSize
        boardOriginY = headerHeight + boardFrameSize
        boardWidthSize = view.frame.size.width - boardFrameSize*2
        boardHeightSize = view.frame.size.height - headerHeight - boardFrameSize*2
        cellSize = boardHeightSize/CGFloat(boardHeight)
        if CGFloat(boardWidth)*cellSize > boardWidthSize {
            cellSize = boardWidthSize/CGFloat(boardWidth)
        }
    }
}

