//
//  CollectionViewCell.swift
//  Fanorona
//
//  Created by Noshaba Cheema on 12/13/14.
//  Copyright (c) 2014 Noshaba Cheema. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let textLabel: UILabel!
    let imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let textFrame = CGRect(x: 0, y: frame.size.height/2, width: frame.size.width, height: frame.size.height/3)
        textLabel = UILabel(frame: textFrame)
        textLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
    }
}