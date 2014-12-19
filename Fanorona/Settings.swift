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
}

class Settings: UIViewController {
    
    @IBOutlet weak var boardWidth: UILabel!
    @IBOutlet weak var boardHeight: UILabel!
    
    @IBOutlet weak var aiColorLabel: UILabel!
    @IBOutlet weak var aiColorControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    @IBAction func changeOpponentColor(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            GameSettings.aiColor = UIColor.blackColor()
        } else {
            GameSettings.aiColor = UIColor.whiteColor()
        }
    }
}
