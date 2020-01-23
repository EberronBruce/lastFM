//
//  MusicCell.swift
//  lastFM
//
//  Created by Bruce Burgess on 1/21/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

import UIKit

class MusicCell: UITableViewCell {
    @IBOutlet weak var cellStyleView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellStyleView.layer.cornerRadius = 5
    }

    func configureCell(title text : String, subTitle : String) {
        self.cellTitle.text = text
        self.subTitle.text = subTitle
    }

}
