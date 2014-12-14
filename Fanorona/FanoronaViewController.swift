//
//  FanoronaViewController.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/9/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

class FanoronaViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
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
            println("hello")
        }
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: CGRect(x: boardOriginX, y: boardOriginY, width: boardWidthSize, height: boardHeightSize), collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
//        collectionView!.backgroundView = UIImageView(image: UIImage(named: "circle"))
        self.view.addSubview(collectionView!)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as CollectionViewCell
        cell.backgroundColor = UIColor.blueColor()
        cell.textLabel?.text = "\(indexPath.section):\(indexPath.row)"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        UIView.animateWithDuration(5.0, delay: 0, options: .AllowUserInteraction, animations: { () -> Void in
            cell!.backgroundColor = UIColor.greenColor()
            }, completion:{finished in
                cell!.backgroundColor = UIColor.whiteColor()
        })
    }
}

