//
//  PictureCellCollectionViewCell.swift
//  PictureGenerator
//
//  Created by Ahmad Hamed Rangeen on 12/10/18.
//  Copyright © 2018 Ahmad Hamed Rangeen. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    // override the initilizer of the frame
    override init(frame : CGRect){
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init() has not been implemented")
    }
    
    // above two func are required if you want to use custom UIColllectionView cell
}
