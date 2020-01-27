//
//  WebViewController.m
//  lastFM
//
//  Created by Bruce Burgess on 1/26/20.
//  Copyright © 2020 Red Raven Computing Studios. All rights reserved.
//

#import "WebViewController.h"

/*
 This web vies is used in place of a artist bio information.
 So the artist bio link is sent here and this loads.
 */


@interface WebViewController ()

@end

@implementation WebViewController
WKWebView *webView;
bool needDismissed = NO;
UIActivityIndicatorView *spinner;
const NSString *ErrorMessage = @"NO URL STRING MUST ABORT";

-(id)initWithString: (NSString *)url {
    self = [super init];
    if (self) {
        _urlString = url;
    }
    return self;
}

- (void)loadView {
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    webView = [[WKWebView alloc] initWithFrame: CGRectZero configuration: webConfiguration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    self.view = webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(_urlString == NULL) {
        NSLog(@"%@", ErrorMessage);
        needDismissed = YES;
    } else {
        NSURL *url = [[NSURL alloc] initWithString:_urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [webView loadRequest:request];
        [self createActivitySpinner];
    }
}

//Creates a spinner to notifiy the user the webpage is still loading
- (void)createActivitySpinner {
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    spinner.color = UIColor.blackColor;
    CGRect frame = CGRectMake((webView.frame.size.width / 2 - spinner.frame.size.width / 2),
     (webView.frame.size.height / 2 - spinner.frame.size.height / 2),
     spinner.frame.size.width,
     spinner.frame.size.height
    );
    spinner.frame = frame;
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    [self.view addSubview:spinner];
    [spinner startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    if(needDismissed) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [spinner stopAnimating];
    [spinner isHidden];
}


@end
