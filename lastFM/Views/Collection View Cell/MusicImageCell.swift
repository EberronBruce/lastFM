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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(imageName : String) {
        imageView.frame.size = CGSize(width: 100, height: 100)
        imageView?.image = UIImage(named: imageName)
    }
}
