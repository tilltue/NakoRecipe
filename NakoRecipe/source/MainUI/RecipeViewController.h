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
#import "HttpAsyncApi.h"
#import "LikeListViewController.h"
#import "BlogListViewController.h"

@interface RecipeViewController : UIViewController <UIGestureRecognizerDelegate,RecipeCommentDelegate,RecipeViewDelegate,RequestObserver>
{
    RecipeView *recipeView;
    RecipeCommentView *recipeCommentView;
    LikeListViewController *likeListViewController;
    BlogListViewController *blogListViewController;
}
@property (nonatomic, strong) NSString *currentPostId;
@property BOOL likeVCShow;
- (void)prepareWillAppear;
@end
