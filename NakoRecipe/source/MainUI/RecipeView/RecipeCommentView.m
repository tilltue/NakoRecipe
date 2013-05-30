//
//  RecipeCommentView.m
//  NakoRecipe
//
//  Created by nako on 5/30/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "RecipeCommentView.h"

@implementation RecipeCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *tempDimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        tempDimView.backgroundColor = [UIColor blackColor];
        tempDimView.alpha = .7;
        [self addSubview:tempDimView];
        
        commentWebView = [[UIWebView alloc] init];
        commentWebView.delegate = self;
        [self addSubview:commentWebView];
    }
    return self;
}

- (void)loadFacebookComment:(NSString *)postId
{
    currentPostId = postId;
    [commentWebView setFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
    commentWebView.hidden = YES;
    [self loadFacebookSocialCommentWebView];
}

#pragma mark - facebook webview

- (void)loadFacebookSocialCommentWebView
{
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *facebookSocialString = [NSString stringWithFormat:@"<html xmlns:fb='http://ogp.me/ns/fb#'>\
                                      <head><style type='text/css'>.fb_ltr{height:auto !important;}</style>\
                                      <script>(function(d, s, id) {var js, fjs = d.getElementsByTagName(s)[0];if (d.getElementById(id)) return;js = d.createElement(s); js.id = id;js.src = 'http://connect.facebook.net/ko_KR/all.js#xfbml=1';fjs.parentNode.insertBefore(js, fjs);}(document, 'script', 'facebook-jssdk'));</script>\
                                      </head><body>\
                                      <fb:comments href='%@' width='%f' num_posts='3'></fb:comments>\
                                      </body></html>",[NSString stringWithFormat:@"http://Recipe_id_%@.html",currentPostId],self.frame.size.width-20];
	[commentWebView loadHTMLString:facebookSocialString baseURL:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [commentWebView setFrame:CGRectZero];
    commentWebView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    commentWebView.hidden = NO;
    [commentWebView setFrame:CGRectMake(10,10,self.frame.size.width-20,self.frame.size.height-20)];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (webView == commentWebView) {
		NSLog(@"root navigation type %d url tryed to call %@",navigationType,  [[request URL] absoluteString]);
		
		// FACEBOOK
		NSRange FBloginRequest = [[[request URL] absoluteString]
                                  rangeOfString:@"www.facebook.com/login.php"];
		
		if (FBloginRequest.location != NSNotFound) {
			// mostro il popup
			NSLog(@"asd");
            //			[self loadAndPresentPopupWithRequest:request];
			return NO;
		}
		
		NSRange loggedInBackUrlRange = [[[request URL] absoluteString]
                                        rangeOfString:@"www.facebook.com/connect/window_comm.php"];
		
		if (loggedInBackUrlRange.location != NSNotFound) {
            //			[self loadHtmlWidget];
			return NO;
		}
		
	}
	return navigationType != UIWebViewNavigationTypeLinkClicked;
}

- (void) loadAndPresentPopupWithRequest:(NSURLRequest *)request
{
	UIViewController *popupView = [[UIViewController alloc] init];
	popupView.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 540, 576)];
	popupView.view.backgroundColor = [UIColor yellowColor];
	
	UIWebView *popupWebView = [[UIWebView alloc] initWithFrame:popupView.view.bounds];
	popupWebView.delegate = self;
	[popupView.view addSubview:popupWebView];
	[popupWebView loadRequest:request];
    
	UINavigationController *popupNavController = [[UINavigationController alloc] initWithRootViewController:popupView];
	popupNavController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	popupView.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                   target:self
                                                   action:@selector(closePopup)];
	
	//[self presentModalViewController:popupNavController animated:YES];
}

- (CGSize)getWebContentSize:(UIWebView *)webView
{
    CGSize tempSize = CGSizeZero;
    tempSize = CGSizeMake([[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue], [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue]);
    return tempSize;
}

@end
