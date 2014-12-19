//
//  Settings.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/19/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

struct GameSettings{
    static var boardWidth = 9
    static var boardHeight = 5
    static var opponentIsAI = true
    static var aiColor = UIColor.blackColor()
    static var aiLevel = AI.UtilType.Medium
}

class Settings: UIViewController {
    
    @IBOutlet weak var boardWidth: UILabel!
    @IBOutlet weak var boardHeight: UILabel!
    @IBOutlet weak var widthStepper: UIStepper!
    @IBOutlet weak var heightStepper: UIStepper!
    
    
    @IBOutlet weak var aiColorLabel: UILabel!
    @IBOutlet weak var aiColorControl: UISegmentedControl!
    
    @IBOutlet weak var aiLevelLabel: UILabel!
    @IBOutlet weak var aiLevelControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        boardWidth.text = "\(GameSettings.boardWidth)"
        boardHeight.text = "\(GameSettings.boardHeight)"
        
        widthStepper.value = Double(GameSettings.boardWidth)
        heightStepper.value = Double(GameSettings.boardWidth)
        
        if GameSettings.aiColor == UIColor.blackColor() {
            aiColorControl.selectedSegmentIndex = 0
        } else {
            aiColorControl.selectedSegmentIndex = 1
        }
        
        switch GameSettings.aiLevel {
        case AI.UtilType.Easy: aiLevelControl.selectedSegmentIndex = 0
            break
        case AI.UtilType.Medium: aiLevelControl.selectedSegmentIndex = 1
            break
        case AI.UtilType.Hard: aiLevelControl.selectedSegmentIndex = 2
            break
        }
    }
    
    @IBAction func changeWidth(sender: UIStepper) {
        boardWidth.text = "\(Int(sender.value))"
        GameSettings.boardWidth = Int(sender.value)
        
    }
    @IBAction func changeHeight(sender: UIStepper) {
        boardHeight.text = "\(Int(sender.value))"
        GameSettings.boardHeight = Int(sender.value)
    }
    @IBAction func changeOpponent(sender: UISegmentedControl) {
        GameSettings.opponentIsAI = sender.selectedSegmentIndex == 0
        if GameSettings.opponentIsAI {
            aiColorLabel.hidden = false
            aiColorControl.hidden = false
            aiLevelLabel.hidden = false
            aiLevelControl.hidden = false
        } else {
            aiColorLabel.hidden = true
            aiColorControl.hidden = true
            aiLevelLabel.hidden = true
            aiLevelControl.hidden = true
        }
    }
    @IBAction func changeOpponentColor(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            GameSettings.aiColor = UIColor.blackColor()
        } else {
            GameSettings.aiColor = UIColor.whiteColor()
        }
    }
    @IBAction func changeAILevel(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: GameSettings.aiLevel = AI.UtilType.Easy
            break
        case 1: GameSettings.aiLevel = AI.UtilType.Medium
            break
        case 2: GameSettings.aiLevel = AI.UtilType.Hard
            break
        default:
            GameSettings.aiLevel = AI.UtilType.Medium
            break
        }
    }
    
}
