//
//  RecipeView.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RECIPE_THUMB_INFO_HEIGHT    40
#define RECIPE_DETAIL_INFO_HEIGHT   300

@interface RecipeView : UIScrollView
{
    NSMutableDictionary *rectDic;
    
    UILabel         *titleLabel;
    UIScrollView    *imageScrollView;
    NSMutableArray  *imageArr;
    
    UIView      *recipeInfo;
    UIView      *recipeDetailInfo;
    UITextView     *recipeContent;
    
    UIImageView *likeImageView;
    UIImageView *commentImageView;
    UIButton    *likeButton;
    UIButton    *commentButton;
    UILabel     *likeLabel;
    UILabel     *commentLabel;
}
- (void)reloadRecipeView:(NSString *)postId;
@end
