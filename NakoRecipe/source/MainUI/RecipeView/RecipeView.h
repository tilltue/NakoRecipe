//
//  RecipeView.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeView : UIScrollView
{
    NSMutableDictionary *rectDic;
    UILabel *titleLabel;
    UIScrollView *imageScrollView;
    UIView *recipeInfo;
    UILabel *recipeContent;
}
- (void)reloadRecipeView:(NSString *)postId;
@end
