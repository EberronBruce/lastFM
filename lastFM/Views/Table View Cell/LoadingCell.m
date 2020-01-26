//
//  LoadingCell.m
//  lastFM
//
//  Created by Bruce Burgess on 1/25/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

#import "LoadingCell.h"
#import "lastFM-Swift.h"

@implementation LoadingCell
const int CELL_CORNER_RADIUS = 5;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.cellStyleView.layer.cornerRadius = CELL_CORNER_RADIUS;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
