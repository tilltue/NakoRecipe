//
//  RecipeView.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "HttpAsyncApi.h"
#import "ODRefreshControl.h"

@protocol RecipeViewDelegate <NSObject>
- (void)keyboardHide;
- (void)likeUpdate:(BOOL)state;
@end

@interface RecipeView : UIView <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,RequestObserver>
{
    NSMutableDictionary *rectDic;
    
    UIScrollView    *imageScrollView;
    UIPageControl   *imagePageControl;
    UILabel         *noImageLabel;
    NSMutableArray  *imageArr;
    
    UIView          *tvHeaderView;
    UIView          *bgView;
    UIView          *recipeInfo;
    
    /*
    UIImageView *likeImageView;
    UIButton    *likeButton;
    UILabel     *likeLabel;
    UIImageView *commentImageView;
    UIButton    *commentButton;
    UILabel     *commentLabel;
    */
    NSString    *currentPostId;
    
    UIView      *lineView_1;
    UIView      *lineView_2;
    UIView      *lineView_3;
    UIButton    *youtubeButton;
    UIImageView *ivLike;
    UILabel     *lblLike;
    UIImageView *ivComment;
    UILabel     *lblComment;
    
    UIImageView *ivStuff;
    UILabel     *lblStuff;
    UILabel     *lblStuffDetail;
    UIImageView *ivRecipe;
    UILabel     *lblRecipe;
    UITextView  *recipeContent;
    
    UITableView *tvComment;
    NSMutableArray *commentArr;
    BOOL isKeyboardShow;
    float keyBoardHeight;
    BOOL refreshComment;
    
    ODRefreshControl *_refreshControl;
}
@property (nonatomic, unsafe_unretained) id <RecipeViewDelegate> recipe_delegate;
- (void)reset;
- (void)loadComment;
- (void)loadLike;
- (void)reloadRecipeView:(NSString *)postId;
- (void)keyBoardAnimated:(NSNotification *)notification;
@end
