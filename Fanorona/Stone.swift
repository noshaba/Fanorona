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

class Stone : Equatable {
    
    var x: Int
    var y: Int
    var color: UIColor
    var invertIntersection: Bool
    var isStrongIntersection: Bool
    var prevPositions = [Position]()
    var prevDirection: Position?
    var button = UIButton.buttonWithType(.Custom) as UIButton
    var buttonSize: CGFloat!
    
    init(x: Int, y: Int, stoneColor: UIColor){
        self.x = x
        self.y = y
        self.color = stoneColor
        self.invertIntersection = false
        self.isStrongIntersection = false
    }
    
    func initButton(){
        button.frame = CGRectMake(CGFloat(x)*buttonSize, CGFloat(y)*buttonSize, buttonSize, buttonSize)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.backgroundColor = color
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
    
    func clearHistory(){
        prevPositions.removeAll()
        prevDirection = nil
    }
    
}

func == (left: Stone, right: Stone) -> Bool {
    return left.x == right.x && left.y == right.y && left.color == right.color
}
