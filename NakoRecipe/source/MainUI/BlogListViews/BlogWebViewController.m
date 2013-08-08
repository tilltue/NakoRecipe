//
//  BlogWebViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 8..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "BlogWebViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface BlogWebViewController ()

@end

@implementation BlogWebViewController
@synthesize url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        // Custom initialization
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        
        CGRect rect = self.view.bounds;
        rect.size.height -= 44;
        _webView.frame = rect;
        UIImage *tempImage = [UIImage imageNamed:@"ic_loading.png"];
        activityIndicatorView = [[UIImageView alloc] init];
        float imageSize = [SystemInfo isPad]?50:50;
        activityIndicatorView.image = tempImage;
        activityIndicatorView.frame = CGRectMake(_webView.frame.size.width/2-imageSize/2, _webView.frame.size.height/2-imageSize/2, imageSize, imageSize);
        [self.view addSubview:_webView];
        [_webView addSubview:activityIndicatorView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if([SystemInfo isPad])
        [self setUserAgent:@"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"];
}

- (void)viewWillAppear:(BOOL)animated
{
    if( url != nil ){
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        activityIndicatorView.alpha = .9;
        [activityIndicatorView.layer removeAllAnimations];
        [self runSpinAnimationOnView:activityIndicatorView duration:2 rotations:1 repeat:3];
    }
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)setUserAgent:(NSString*)userAgent
{
    NSDictionary *userAgentReplacement = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentReplacement];
}

- (void)viewDidDisappear:(BOOL)animated
{
    url = nil;
    [_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoadingAnimation];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoadingAnimation];
}

- (void)stopLoadingAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    activityIndicatorView.alpha = 0;
    [UIView commitAnimations];
}

@end
