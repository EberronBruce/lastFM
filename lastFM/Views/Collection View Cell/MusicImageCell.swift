//
//  MusicImageCollectionViewCell.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

class MusicImageCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var styleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleView.layer.cornerRadius = CELL_STYLE_CORNER_RADIUS
    }
    
    func configureCell(image : UIImage) {
        imageView.frame.size = CGSize(width: 100, height: 100)
        imageView?.image = image
    }
}
