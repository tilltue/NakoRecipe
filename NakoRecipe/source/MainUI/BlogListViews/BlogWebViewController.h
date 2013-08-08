//
//  BlogWebViewController.h
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 8..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogWebViewController : UIViewController <UIWebViewDelegate>
{
    UIWebView *_webView;
    UIImageView *activityIndicatorView;
}
@property (nonatomic, strong) NSString *url;
@end
