//
//  CollectionViewCell.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

extension Array {
    func contains<T : Equatable>(obj: T) -> Bool {
        let filtered = self.filter {$0 as? T == obj}
        return filtered.count > 0
    }
}

class Stone {
    
    var x: Int
    var y: Int
    var color: UIColor
    var sacrifice: Bool
    var invertIntersection: Bool
    var isStrongIntersection: Bool
    var prevPositions = [Position]()
    var prevDirection: Position?
    
    init(x: Int, y: Int, stoneColor: UIColor){
        self.x = x
        self.y = y
        self.color = stoneColor
        self.sacrifice = false
        self.invertIntersection = false
        self.isStrongIntersection = false
        self.sacrifice = false
    }
    
    func setInvertIntersectionType(size_x: Int, size_y: Int) {
        let sqrtDiff = (size_x - size_y) * (size_x - size_y)
        self.invertIntersection = (sqrtDiff == 4 || sqrtDiff == 36 || sqrtDiff == 100)
    }
    
    func setIntersectionType() {
        if invertIntersection {
            self.isStrongIntersection = ((x + y) % 2 == 1)
        } else {
            self.isStrongIntersection = ((x + y) % 2 == 0)
        }
    }
    
    func posIsVisited(pos: Position) -> Bool{
        return prevPositions.contains(pos)
    }
    
    func isSameDirection(pos: Position) -> Bool{
        return prevDirection == pos
    }

    
}
