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
    var aiColor: UIColor?
    var aiInit: Bool?
    var aiVersion: AI.UtilType?
    var ai: AI?
    var aiMove: Move?
    var goalState = Board.GoalState.Continue
    var fromX: Int!
    var fromY: Int!
    var captureX: Int!
    var captureY: Int!
    var toX: Int!
    var toY: Int!
    var moveType = MoveType.Err
    var networkToPositions = [Position]()
    var networkFromPositions = [Position]()
    var networkMoveTypes = [MoveType]()
    var approachRemoveX: Int!
    var approachRemoveY: Int!
    var withdrwalRemoveX: Int!
    var withdrwalRemoveY: Int!
    var stoneIsSelected = false
    var forceUserToMove = false
    var mustDecideCaptureDirection = false
    var isGameOver = false
    var opponentIsAI: Bool
    var isPaikaGlobal: Bool!
    var isSacrificeGlobal: Bool!
    var timer: NSTimer!
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
        boardWidth = GameSettings.boardWidth
        boardHeight = GameSettings.boardHeight
        opponentIsAI = GameSettings.opponentIsAI
        if opponentIsAI {
            aiVersion = GameSettings.aiLevel
            aiColor = GameSettings.aiColor
            aiInit = aiColor == UIColor.whiteColor()
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
        initFieldButtons()
        for stone in board.state {
            stone.buttonSize = stoneSize
            stone.initButton()
            stone.button.addTarget(self, action: Selector("vsOpponent:"), forControlEvents: .TouchUpInside)
            boardView.addSubview(stone.button)
        }
        view.addSubview(boardView)
    }
    
    func initFieldButtons(){
        var fieldButton: UIButton
        let sqrtDiff = (boardWidth - boardHeight) * (boardWidth - boardHeight)
        let invertIntersection = (sqrtDiff == 4 || sqrtDiff == 36 || sqrtDiff == 100)
        var isStrongIntersection: Bool
        for var x = 0; x < boardWidth; ++x{
            for var y = 0; y < boardHeight; ++y{
                if invertIntersection {
                    isStrongIntersection = ((x + y) % 2 == 1)
                } else {
                    isStrongIntersection = ((x + y) % 2 == 0)
                }
                fieldButton = UIButton.buttonWithType(.Custom) as UIButton
                fieldButton.frame = CGRectMake(CGFloat(x)*stoneSize, CGFloat(y)*stoneSize, stoneSize, stoneSize)
                if isStrongIntersection {
                    fieldButton.setImage(UIImage(named: "strongIntersect"), forState: .Normal)
                } else {
                    fieldButton.setImage(UIImage(named: "weakIntersect"), forState: .Normal)
                }
                fieldButton.adjustsImageWhenHighlighted = false
                fieldButton.addTarget(self, action: Selector("vsOpponent:"), forControlEvents: .TouchUpInside)
                boardView.addSubview(fieldButton)
            }
        }
    }
    
    func vsOpponent(sender: UIButton){
        if !opponentIsAI {
            vsPlayer(sender)
        } else {
            vsAI(sender)
        }
    }
    
    func vsPlayer(sender: UIButton){
        if !stoneIsSelected {
            attempToSelectStone(sender)
        } else {
            attemptToMoveStone(sender)
        }
        checkGoalState()
    }
    
    func vsAI(sender: UIButton){
        if aiColor == UIColor.whiteColor() && aiInit!{
            self.attemptAIMove()
            aiInit = false
        }
        if board.turn != aiColor! && !aiInit! {
            if !stoneIsSelected {
                attempToSelectStone(sender)
            } else {
                attemptToMoveStone(sender)
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                if self.board.turn == self.aiColor! && self.checkGoalState() == .Continue {
                    self.attemptAIMove()
                }
            })
        }
    }
    
    func attempToSelectStone(sender: UIButton){
        fromX = Int(sender.frame.origin.x) / Int(stoneSize)
        fromY = Int(sender.frame.origin.y) / Int(stoneSize)
        println("Button \(fromX), \(fromY) clicked.")
        if !board.posIsEmpty(fromX, y: fromY) {
            selectedStone = board.getStone(fromX, y: fromY)!
            if selectedStone!.color != board.turn {
                println("Not your turn")
                return
            }
            stoneIsSelected = true
            println("Game is now in selected state.")
        } else {
            println("Empty position.")
        }
    }
    
    func attemptToMoveStone(sender: UIButton){
        if !mustDecideCaptureDirection {
            toX = Int(sender.frame.origin.x) / Int(stoneSize)
            toY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(toX), \(toY) clicked.")
        } else {
            println("hello1")
            captureX = Int(sender.frame.origin.x) / Int(stoneSize)
            captureY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(captureX), \(captureY) clicked.")
        }
        let initialTurn = board.turn
        let destinationStone = board.getStone(toX, y: toY)
        if destinationStone != nil {
            println("Stone already exists there.")
            if destinationStone!.x == fromX && destinationStone!.y == fromY && !forceUserToMove {
                stoneIsSelected = false
                selectedStone = nil
                println("You deselected your stone")
            }
            return
        }
        var stoneMoved = false
        println("Attempting to move stone from \(fromX), \(fromY) to \(toX), \(toY)")
        if !mustDecideCaptureDirection {
            moveType = board.moveStone(selectedStone!, nextX: toX, nextY: toY)
        }
        if moveType != .Err {
            if mustDecideCaptureDirection {
                println("hello2")
                if (captureX == approachRemoveX && captureY == approachRemoveY) {
                    moveType = .Approach
                    mustDecideCaptureDirection = false
                } else if (captureX == withdrwalRemoveX && captureY == withdrwalRemoveY) {
                    moveType = .Withdrawal
                    mustDecideCaptureDirection = false
                }
            } else if moveType == .CaptureDecision {
                let diffX = toX - fromX
                let diffY = toY - fromY
                approachRemoveX = fromX + 2 * diffX
                approachRemoveY = fromY + 2 * diffY
                withdrwalRemoveX = fromX - diffX
                withdrwalRemoveY = fromY - diffY
                println("Either (\(approachRemoveX), \(approachRemoveY)) by approach or (\(withdrwalRemoveX), \(withdrwalRemoveY)) by withdrwal will be removed.")
                mustDecideCaptureDirection = true
            }
            if !mustDecideCaptureDirection{
                board.updateBoard(moveType, stone: selectedStone!, nextX: toX, nextY: toY)
                stoneMoved = true
            }
        }
        if initialTurn == board.turn && !mustDecideCaptureDirection {
            if stoneMoved {
                networkFromPositions.append(Position(x: fromX, y: fromY))
                networkToPositions.append(Position(x: toX, y: toY))
                networkMoveTypes.append(moveType)
                fromX = toX
                fromY = toY
                forceUserToMove = true
            } else if !forceUserToMove {
                println("That is not a legal move.")
            }
        } else if(!mustDecideCaptureDirection){
            networkFromPositions.append(Position(x: fromX, y: fromY))
            networkToPositions.append(Position(x: toX, y: toY))
            networkMoveTypes.append(moveType)
            forceUserToMove = false
            stoneIsSelected = false
            selectedStone = nil
            println("User's turn complete.")
        }
    }
    
    func attemptAIMove(){
        let turn = board.turn
        networkToPositions.removeAll()
        networkFromPositions.removeAll()
        networkMoveTypes.removeAll()
        while board.turn == turn {
            if !self.isGameOver {
                NSThread.sleepForTimeInterval(1.0)
                self.ai = AI(aiColor: self.aiColor!, utilType: self.aiVersion!, gameBoard: self.board)
                self.aiMove = self.ai!.getBestMove()
                self.networkFromPositions.append(Position(x: self.aiMove!.stone.x, y:self.aiMove!.stone.y))
                self.networkToPositions.append(self.aiMove!.nextPos)
                println("AI moved from (\(self.aiMove!.stone.x),\(self.aiMove!.stone.y)) to (\(self.aiMove!.nextPos.x),\(self.aiMove!.nextPos.y))")
                self.networkMoveTypes.append(self.aiMove!.moveType)
                self.board.updateBoard(self.aiMove!)
                self.fromX = self.aiMove!.nextPos.x
                self.fromY = self.aiMove!.nextPos.y
                self.stoneIsSelected = true
                println("AI move done.")
                checkGoalState()
            }
            stoneIsSelected = false
        }
    }
    
    func checkGoalState() -> Board.GoalState {
        switch(board.checkGoalState()){
        case .Draw:
            isGameOver = true
            alertView("Draw!")
            return .Draw
        case .BlackWon:
            isGameOver = true
            alertView("Black Won!")
            return .BlackWon
        case .WhiteWon:
            isGameOver = true
            alertView("White Won!")
            return .WhiteWon
        default:
            return .Continue
        }
    }
    
    func alertView(msg: String){
        var alert = UIAlertController(title: "Game Over", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{ action in
            let start = self.storyboard?.instantiateViewControllerWithIdentifier("Start") as ViewController
            self.showViewController(start, sender: self)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}