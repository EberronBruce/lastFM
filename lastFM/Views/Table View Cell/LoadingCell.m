//
//  LoadingCell.m
//  lastFM
//
//  Created by Bruce Burgess on 1/25/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

#import "LoadingCell.h"
/*
 This is used for the loading indicator on the table view.
 */

@implementation LoadingCell
const int CellCornerRadius = 5;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.cellStyleView.layer.cornerRadius = CellCornerRadius;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
