//
//  AI.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/10/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import Foundation

class AI {
    class AINode {
        var utilVal: Int!
        var node: Board
        var subNodes = [Board]()
        
        init(node:Board){
            self.node = node
        }
    }
}