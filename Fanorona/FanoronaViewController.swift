//
//  FanoronaViewController.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

/**
    FanoronaViewController handles the user input and updates the UI
*/

class FanoronaViewController: UIViewController{
    // board settings
    let board = Board()
    var boardWidth: Int!
    var boardHeight: Int!
    var goalState = Board.GoalState.Continue
    var isGameOver = false
    // AI settings
    var aiColor: UIColor?
    var aiInit: Bool?
    var aiVersion: AI.UtilType?
    var ai: AI?
    var aiMove: Move?
    var opponentIsAI: Bool
    // to calculate the next move
    var fromX: Int!
    var fromY: Int!
    var captureX: Int!
    var captureY: Int!
    var toX: Int!
    var toY: Int!
    var moveType = MoveType.Err
    // if approach or withdrawal capture (or both)
    var approachRemoveX: Int!
    var approachRemoveY: Int!
    var withdrwalRemoveX: Int!
    var withdrwalRemoveY: Int!
    var mustDecideCaptureDirection = false
    // when successive capture is possible
    var forceUserToMove = false
    // selected stone fomr the user
    var stoneIsSelected = false
    var selectedStone: Stone?
    
    // needed for board settings
    @IBOutlet weak var navigationBar: UINavigationBar!
    var headerHeight: CGFloat{
        return navigationBar.frame.size.height
    }
    let boardFrameSize: CGFloat = 20
    var boardHeightSize: CGFloat!
    var boardWidthSize: CGFloat!
    var stoneSize: CGFloat!
    var boardView: UIView!
    
    /**
        Initializes the game.
    
        @param aDecoder A decoder for the super class.
    */
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
    
    /**
        Additional set up after the screen has loaded.
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init board
        view.backgroundColor = UIColor(red: 0, green: 55.0/255.0 , blue: 97.0/255.0, alpha: 1.0)
        boardWidthSize = view.frame.size.width - boardFrameSize*2
        boardHeightSize = view.frame.size.height - headerHeight - boardFrameSize*2
        stoneSize = boardHeightSize/CGFloat(boardHeight)
        if CGFloat(boardWidth)*stoneSize > boardWidthSize {
            stoneSize = boardWidthSize/CGFloat(boardWidth)
        }
        boardView = UIView(frame: CGRectMake(0, 0, stoneSize*CGFloat(boardWidth), stoneSize*CGFloat(boardHeight)))
        boardView.backgroundColor = UIColor(red: 131.0/255.0, green: 208.0/255.0 , blue: 245.0/255.0, alpha: 1.0)
        boardView.center = CGPoint(x: view.center.x, y: view.center.y + headerHeight/2)
        // init fields without stones
        initFieldButtons()
        // init stones
        for stone in board.state {
            stone.buttonSize = stoneSize
            stone.initButton()
            stone.button.addTarget(self, action: Selector("vsOpponent:"), forControlEvents: .TouchUpInside)
            boardView.addSubview(stone.button)
        }
        // add to board
        view.addSubview(boardView)
    }
    
    /**
        Initializes the fields without the stones.
    */
    
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
    
    /**
        Target function for the stones and fields. If a stone or field is clicked then it is either another human player's or the computer's turn after your own turn.
    
        @param Stone or Field button
    */
    
    func vsOpponent(sender: UIButton){
        if !opponentIsAI {
            vsPlayer(sender)
        } else {
            vsAI(sender)
        }
    }
    
    /**
        Target function for stones and fiels. If a stone or field is clicked then it's another human players turn after your turn.
    
        @param Stone or Field button
    */
    
    func vsPlayer(sender: UIButton){
        if !stoneIsSelected {
            attempToSelectStone(sender)
        } else {
            attemptToMoveStone(sender)
        }
        checkGoalState()
    }
    
    /**
        Target function for stones and fiels. If a stone or field is clicked then it's another human players turn after your turn.
    
        @param Stone or Field button
    */
    
    func vsAI(sender: UIButton){
        // if AI is white then it makes the first move
        if aiColor == UIColor.whiteColor() && aiInit!{
            self.attemptAIMove()
            aiInit = false
        }
        if board.turn != aiColor! && !aiInit! {
            // if not AI's turn then the player has to select
            if !stoneIsSelected {
                attempToSelectStone(sender)
            } else {
                attemptToMoveStone(sender)
            }
            // after the player has selected it's the AI's turn
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                if self.board.turn == self.aiColor! && self.checkGoalState() == .Continue {
                    self.attemptAIMove()
                }
            })
        }
    }
    
    /**
        The function determines whether the stone chosen is a valid stone to chose from or not.
    
        @param Stone button
    */
    
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
            selectedStone?.selectStone()
            stoneIsSelected = true
            println("Game is now in selected state.")
        } else {
            println("Empty position.")
        }
    }
    
    /**
        The function determines whether the move the player is trying to is a valid one or not.
        If it is a valid move then the move is done and the UI is updated.
        At first it is checked whether the current move is a move where the player has to decide whether they want to do a withdrawal or approach capture.
        If it is not a dicision move like that it is check whether the selcted field is a valid one or not.
        If it is a valid one, then the move type is generated. If the move type is '.DecisionCapture' then the player has to decide in which direction they want to do the capture.
    
        @param Field button after a stone has been successfully selected
    */
    
    func attemptToMoveStone(sender: UIButton){
        // check if the current move is not a move where the player has to decide whether they want to do a withdrawal or approach capture.
        if !mustDecideCaptureDirection {
            toX = Int(sender.frame.origin.x) / Int(stoneSize)
            toY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(toX), \(toY) clicked.")
        } else {
            captureX = Int(sender.frame.origin.x) / Int(stoneSize)
            captureY = Int(sender.frame.origin.y) / Int(stoneSize)
            println("Button \(captureX), \(captureY) clicked.")
        }
        let initialTurn = board.turn
        // check if the field is valid if not a dicision move
        let destinationStone = board.getStone(toX, y: toY)
        if destinationStone != nil {
            println("Stone already exists there.")
            if destinationStone!.x == fromX && destinationStone!.y == fromY {
                // deselect stone when you click on yourself.
                stoneIsSelected = false
                println("You deselected your stone")
                if forceUserToMove {
                // if the player could do a successive capturing move, then it is withdrawn and it is also the player's turn
                    selectedStone!.clearHistory()
                    board.alternateTurn(board.turn)
                    board.multiMovePos = nil
                    forceUserToMove = false
                    println("User's move complete.")
                }
                selectedStone?.deselectStone()
                stoneIsSelected = false
                selectedStone = nil
            }
            return
        }
        // stone is being moved if field was a valid one
        var stoneMoved = false
        println("Attempting to move stone from \(fromX), \(fromY) to \(toX), \(toY)")
        if !mustDecideCaptureDirection {
            // if the player does not have to decide the capture direction then the move type is generated
            moveType = board.moveStone(selectedStone!, nextX: toX, nextY: toY)
        }
        if moveType != .Err {
            // if move does not return an error
            if mustDecideCaptureDirection {
                // if the move type returns .CaptureDecision then the player has to decide in which direction they want to do the capturing move
                if (captureX == approachRemoveX && captureY == approachRemoveY) {
                    moveType = .Approach
                    mustDecideCaptureDirection = false
                } else if (captureX == withdrwalRemoveX && captureY == withdrwalRemoveY) {
                    moveType = .Withdrawal
                    mustDecideCaptureDirection = false
                }
                // unhighlight the moves the player could chose from
                board.getStone(approachRemoveX, y: approachRemoveY)?.deselectStone()
                board.getStone(withdrwalRemoveX, y: withdrwalRemoveY)?.deselectStone()
            } else if moveType == .CaptureDecision {
                // highlight the moves the player can chose from when he can decide in which direction he wants to do a capture
                let diffX = toX - fromX
                let diffY = toY - fromY
                approachRemoveX = fromX + 2 * diffX
                approachRemoveY = fromY + 2 * diffY
                withdrwalRemoveX = fromX - diffX
                withdrwalRemoveY = fromY - diffY
                board.getStone(approachRemoveX, y: approachRemoveY)?.captureDecision()
                board.getStone(withdrwalRemoveX, y: withdrwalRemoveY)?.captureDecision()
                println("Either (\(approachRemoveX), \(approachRemoveY)) by approach or (\(withdrwalRemoveX), \(withdrwalRemoveY)) by withdrwal will be removed.")
                mustDecideCaptureDirection = true
            }
            if !mustDecideCaptureDirection{
                // if the player has decided what they wanted, the board is updated according to the players move
                board.updateBoard(moveType, stone: selectedStone!, nextX: toX, nextY: toY)
                stoneMoved = true
            }
        }
        if initialTurn == board.turn && !mustDecideCaptureDirection {
            // if it is still the player's turn then they can do a successive capture
            if stoneMoved {
                fromX = toX
                fromY = toY
                forceUserToMove = true
            } else if !forceUserToMove {
                println("That is not a legal move.")
            }
        } else if(!mustDecideCaptureDirection){
            // completed user move
            forceUserToMove = false
            stoneIsSelected = false
            selectedStone?.deselectStone()
            selectedStone = nil
            println("User's turn complete.")
        }
    }
    
    func attemptAIMove(){
        let turn = board.turn
        while board.turn == turn {
            if !self.isGameOver {
                NSThread.sleepForTimeInterval(1.0)
                self.ai = AI(aiColor: self.aiColor!, utilType: self.aiVersion!, gameBoard: self.board)
                self.aiMove = self.ai!.getBestMove()
                println("AI moved from (\(self.aiMove!.stone.x),\(self.aiMove!.stone.y)) to (\(self.aiMove!.nextPos.x),\(self.aiMove!.nextPos.y))")
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