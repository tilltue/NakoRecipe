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
- (void)showLikeList:(NSArray *)likeList;
@end

@interface RecipeView : UIView <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,RequestObserver>
{
    NSMutableDictionary *rectDic;
    
    UIScrollView    *imageScrollView;
    UIPageControl   *imagePageControl;
    UILabel         *noImageLabel;
    NSMutableArray  *imageArr;
    
    UIView          *tvHeaderView;
    UIView          *tvFooterView;
    UIView          *recipeInfo;

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
    
    UIButton *btnLikeList;
    NSMutableArray *likeArr;
    
    UITableView *tvComment;
    NSMutableArray *commentArr;
    BOOL isKeyboardShow;
    float keyBoardHeight;
    BOOL refreshComment;
    
    ODRefreshControl *_refreshControl;
    dispatch_queue_t queue;
}
@property (nonatomic, unsafe_unretained) id <RecipeViewDelegate> recipe_delegate;
- (void)reset;
- (void)loadComment:(BOOL)moveScroll;
- (void)loadLike;
- (void)reloadRecipeView:(NSString *)postId;
- (void)keyBoardAnimated:(NSNotification *)notification;
@end
