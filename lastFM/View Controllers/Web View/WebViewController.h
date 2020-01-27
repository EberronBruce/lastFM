//
//  WebViewController.h
//  lastFM
//
//  Created by Bruce Burgess on 1/26/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface WebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate> 
   

@property (weak, nonatomic) NSString *urlString;
-(id)initWithString: (NSString *)url;

@end

NS_ASSUME_NONNULL_END
