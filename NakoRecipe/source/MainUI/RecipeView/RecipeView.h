//
//  RecipeView.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface RecipeView : UIScrollView <UIWebViewDelegate>
{
    NSMutableDictionary *rectDic;
    
    UIView          *imageBgView;
    UILabel         *titleLabel;
    UIScrollView    *imageScrollView;
    UIPageControl   *imagePageControl;
    UILabel         *noImageLabel;
    NSMutableArray  *imageArr;
    
    UIView          *recipeInfo;
    UIView          *recipeDetailInfo;
    UITextView      *recipeContent;
    
    UIButton    *youtubeButton;
    /*
    UIImageView *likeImageView;
    UIButton    *likeButton;
    UILabel     *likeLabel;
    UIImageView *commentImageView;
    UIButton    *commentButton;
    UILabel     *commentLabel;
    */
    NSString    *currentPostId;
    UIWebView   *commentWebView;
    AsyncImageView *youtubeThumbImageView;
}
- (void)reloadRecipeView:(NSString *)postId;
@end
