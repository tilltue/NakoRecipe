//
//  RecipeView.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface RecipeView : UIScrollView
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
    UIImageView *commentImageView;
    UIButton    *likeButton;
    UIButton    *commentButton;
    UILabel     *likeLabel;
    UILabel     *commentLabel;
    */
    NSString    *currentPostId;
    
    AsyncImageView *youtubeThumbImageView;
}
- (void)reloadRecipeView:(NSString *)postId;
@end
