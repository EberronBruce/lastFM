//
//  LoadingCell.h
//  lastFM
//
//  Created by Bruce Burgess on 1/25/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIView *cellStyleView;

@end

NS_ASSUME_NONNULL_END
