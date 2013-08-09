//
//  RecipePinterest.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "ODRefreshControl.h"

@interface AttatchItem : NSObject
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@end

@interface PintrestItem : NSObject
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *creatorThumb;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSMutableArray *attachItems;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger comment_count;
@property (nonatomic, assign) NSInteger count;
@end

@interface LikeCommentItem : NSObject
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger comment_count;
@end

@protocol RecipePinterestDelegate <NSObject>
- (void)selectRecipe:(NSString *)recipeId;
- (void)update;
@end

@interface RecipePinterest : UIView <GMGridViewActionDelegate,GMGridViewDataSource,UIScrollViewDelegate>
{
    GMGridView *_gridView;
    NSMutableArray *pintrestItems;
    ODRefreshControl *_refreshControl;
    dispatch_queue_t queue;
    BOOL _decelerating;
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
}
@property (nonatomic, unsafe_unretained) id <RecipePinterestDelegate> recipe_delegate;
@property (nonatomic, strong) NSMutableArray *likeCommentArr;
@property int alignType;
- (void)startLoading;
- (void)stopLoading;
- (NSInteger)getItemCount;
- (void)reloadPintRest;
- (void)reloadLikePintRest;
- (void)algin:(int)type;
@end
