//
//  RecipeCommentView.h
//  NakoRecipe
//
//  Created by nako on 5/30/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecipeCommentDelegate <NSObject>
- (void)faceBookLogin:(UIWebView *)webView withRequest:(NSURLRequest *)request;
@end

@interface RecipeCommentView : UIView <UIWebViewDelegate>
{
    NSString    *currentPostId;
    UIWebView   *commentWebView;
    UIActivityIndicatorView *loadingIndicator;
}
- (void)loadCommentView:(NSString *)postId;
- (void)close;
@property (nonatomic, unsafe_unretained) id <RecipeCommentDelegate> comment_delegate;
@end
