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
    var goalState = Board.GoalState.Continue
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
    var stoneIsSelected = false
    var forceUserToMove = false
    var mustDecideCaptureDirection = false
    var isGameOver = false
    var isOpponentAI = false
    var isPaikaGlobal: Bool!
    var isSacrificeGlobal: Bool!
    var timer: NSTimer!
    var possibleMoveButtons = [UIButton]()
    var selectedStone: Stone?
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var headerHeight: CGFloat{
        return navigationBar.frame.size.height
    }
    let boardFrameSize: CGFloat = 20
    var boardHeightSize: CGFloat!
    var boardWidthSize: CGFloat!
    var stoneSize: CGFloat!
    var boardView: UIView!
    
    required init(coder aDecoder: NSCoder) {
        boardWidth = 9
        boardHeight = 5
        if isOpponentAI {
            aiVersion = 0
            aiDepth = 2
        }
        board.reset(boardWidth, y: boardHeight)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.blueColor()
        boardWidthSize = view.frame.size.width - boardFrameSize*2
        boardHeightSize = view.frame.size.height - headerHeight - boardFrameSize*2
        stoneSize = boardHeightSize/CGFloat(boardHeight)
        if CGFloat(boardWidth)*stoneSize > boardWidthSize {
            stoneSize = boardWidthSize/CGFloat(boardWidth)
        }
        boardView = UIView(frame: CGRectMake(0, 0, stoneSize*CGFloat(boardWidth), stoneSize*CGFloat(boardHeight)))
        boardView.backgroundColor = UIColor.redColor()
        boardView.center = CGPoint(x: view.center.x, y: view.center.y + headerHeight/2)
        for stone in board.state {
            stone.buttonSize = stoneSize
            stone.initButton()
            stone.button.addTarget(self, action: Selector("vsModeLocalPlayer:"), forControlEvents: .TouchUpInside)
            boardView.addSubview(stone.button)
        }
        view.addSubview(boardView)
    }
    
    func vsModeLocalPlayer(sender: UIButton){
        attempToSelectStone(sender)
    }
    
    func showPossibleMoves(stone: Stone){
        let possibleMoves = board.getPossibleMoves(stone)
        var moveButton: UIButton
        for move in possibleMoves {
            moveButton = UIButton.buttonWithType(.Custom) as UIButton
            moveButton.frame = CGRectMake(CGFloat(move.x)*stoneSize, CGFloat(move.y)*stoneSize, stoneSize, stoneSize)
            moveButton.layer.cornerRadius = 0.5 * moveButton.bounds.size.width
            moveButton.backgroundColor = UIColor.yellowColor()
            moveButton.contentMode = .Redraw
            moveButton.addTarget(self, action: Selector("attemptToMoveStone:"), forControlEvents: .TouchUpInside)
            boardView.addSubview(moveButton)
            possibleMoveButtons.append(moveButton)
        }
    }
    
    func hidePossibleMoves(){
        for button in possibleMoveButtons {
            button.removeFromSuperview()
        }
        possibleMoveButtons.removeAll()
    }
    
    func attempToSelectStone(sender: UIButton){
        if !stoneIsSelected {
            fromX = Int(sender.frame.origin.x) / Int(stoneSize)
            fromY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(fromX), \(fromY) clicked.")
            selectedStone = board.getStone(fromX, y: fromY)!
            if selectedStone!.color != board.turn {
                println("Not your turn")
                return
            }
            stoneIsSelected = true
            showPossibleMoves(selectedStone!)
            println("Game is now in selected state.")
        } else {
            stoneIsSelected = false
            selectedStone = nil
            hidePossibleMoves()
            println("You deselected your stone")
        }
    }
    
    func attemptToMoveStone(sender: UIButton){
        if !mustDecideCaptureDirection {
            toX = Int(sender.frame.origin.x) / Int(stoneSize)
            toY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(toX), \(toY) clicked.")
        } else {
            captureX = Int(sender.frame.origin.x) / Int(stoneSize)
            captureY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(captureX), \(captureY) clicked.")
        }
        let destinationStone = board.getStone(toX, y: toY)
    }
}