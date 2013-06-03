//
//  RecipeCommentView.m
//  NakoRecipe
//
//  Created by nako on 5/30/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "RecipeCommentView.h"

@implementation RecipeCommentView
@synthesize comment_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        UIView *tempDimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        tempDimView.backgroundColor = [UIColor blackColor];
        tempDimView.alpha = .7;
        [self addSubview:tempDimView];
        
        commentWebView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, frame.size.height-20)];
        commentWebView.delegate = self;
        [commentWebView.scrollView setBounces:NO];
        [self addSubview:commentWebView];
        
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(commentWebView.frame.size.width/2-10, commentWebView.frame.size.height/2-10, 20,20)];
        [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [loadingIndicator setHidesWhenStopped:YES];
        [commentWebView addSubview:loadingIndicator];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow)
                                                    name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow)
                                                    name:UIKeyboardWillShowNotification object:nil];

    }
    return self;
}

- (void)loadCommentView:(NSString *)postId
{
    currentPostId = postId;
    [commentWebView setFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
    commentWebView.hidden = YES;
    [self loadFacebookSocialCommentWebView];
}

- (void)close
{
    [commentWebView endEditing:YES];
}

- (void)keyboardWillShow
{
    CATransition *transition = [CATransition animation];
    self.hidden = YES;
    if( self.hidden ){
        transition.duration = 1.3;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [self.window.layer addAnimation:transition forKey:nil];
        self.hidden = NO;
    }
}

- (void)keyboardShow
{
    if( !self.hidden ){
        [commentWebView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [commentWebView setFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20)];
        [commentWebView.scrollView setContentSize:CGSizeMake(commentWebView.frame.size.width, commentWebView.frame.size.height)];
    }
}

#pragma mark - facebook webview

- (void)loadFacebookSocialCommentWebView
{
	NSString *imagePath = [[NSBundle mainBundle] resourcePath];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	imagePath = [imagePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *facebookSocialString = [NSString stringWithFormat:@"<html xmlns:fb='http://ogp.me/ns/fb#'>\
                                      <head><style type='text/css'>.fb_ltr{height:auto !important;width:%f !important;}</style>\
                                      <script>(function(d, s, id) {var js, fjs = d.getElementsByTagName(s)[0];if (d.getElementById(id)) return;js = d.createElement(s); js.id = id;js.src = 'http://connect.facebook.net/ko_KR/all.js#xfbml=1&appId=557757880934097';fjs.parentNode.insertBefore(js, fjs);}(document, 'script', 'facebook-jssdk'));</script>\
                                      </head><body><div id=\"fb_root\"></div>\
                                      <fb:comments href='%@' width='%f' num_posts='3' order_by='time' mobile='false'></fb:comments>\
                                      </body></html>",self.frame.size.width-40,[NSString stringWithFormat:@"http://Nako_PostID_%@.com",currentPostId],self.frame.size.width-30];
	[commentWebView loadHTMLString:facebookSocialString baseURL:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [commentWebView setFrame:CGRectZero];
    commentWebView.hidden = YES;
    [loadingIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    commentWebView.hidden = NO;
    [commentWebView setFrame:CGRectMake(10,10,self.frame.size.width-20,self.frame.size.height-20)];
    [loadingIndicator stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( navigationType != UIWebViewNavigationTypeLinkClicked )
        [loadingIndicator startAnimating];
    if (webView == commentWebView) {
		//NSLog(@"root navigation type %d url tryed to call %@",navigationType,  [[request URL] absoluteString]);
		
		// FACEBOOK
		NSRange FBloginRequest = [[[request URL] absoluteString]
                                  rangeOfString:@"www.facebook.com/login.php"];
		if (FBloginRequest.location != NSNotFound) {
            [commentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.facebook.com/login.php"]]];
			return YES;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"m.facebook.com/login.php"];
		if (FBloginRequest.location != NSNotFound) {
			return YES;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"https://www.facebook.com/logout.php"];
		if (FBloginRequest.location != NSNotFound) {
            [commentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.facebook.com/logout.php"]]];
			return YES;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"m.facebook.com/logout.php"];
		if (FBloginRequest.location != NSNotFound) {
			return YES;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"https://open.login.yahooapis.com"];
		if (FBloginRequest.location != NSNotFound) {
            [self showAlert];
            [loadingIndicator stopAnimating];
			return NO;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"https://api.screenname.aol.com"];
		if (FBloginRequest.location != NSNotFound) {
            [self showAlert];
            [loadingIndicator stopAnimating];
			return NO;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"https://www.facebook.com/connect/oauthwrap_login.php"];
		if (FBloginRequest.location != NSNotFound) {
            [self showAlert];
            [loadingIndicator stopAnimating];
			return NO;
		}
        //현재는 임시로 이렇게 했는데... 정확한 로그인 완료에 대한 판단을 어떻게 해야 할지?
		FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"https://m.facebook.com/plugins/login_success.php?refsrc="];
		if (FBloginRequest.location != NSNotFound) {
			// mostro il popup
            [self loadFacebookSocialCommentWebView];
			return NO;
		}
        FBloginRequest = [[[request URL] absoluteString]
                          rangeOfString:@"http://m.facebook.com/home.php"];
		if (FBloginRequest.location != NSNotFound) {
			// mostro il popup
            [self loadFacebookSocialCommentWebView];
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
    //[[self comment_delegate] faceBookLogin:commentWebView withRequest:request];
}

- (CGSize)getWebContentSize:(UIWebView *)webView
{
    CGSize tempSize = CGSizeZero;
    tempSize = CGSizeMake([[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue], [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue]);
    return tempSize;
}

- (void)showAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림"
                                                    message:@"현재는 FaceBook 계정으로만 가능합니다." delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"확인", nil];
    [alert show];
}
@end
