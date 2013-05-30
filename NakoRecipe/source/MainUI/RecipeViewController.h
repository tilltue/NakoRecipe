//
//  RecipeViewController.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeView.h"
#import "RecipeCommentView.h"

@interface RecipeViewController : UIViewController <UIGestureRecognizerDelegate>
{
    RecipeView *recipeView;
    RecipeCommentView *recipeCommentView;
}
@property (nonatomic, strong) NSString *currentPostId;
@end
