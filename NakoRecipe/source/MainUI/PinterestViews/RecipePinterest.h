//
//  RecipePinterest.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"

#define PHONE_TWO_CELL_WIDTH 148
#define PHONE_TWO_THUMB_WIDTH 140
#define HEART_AND_COMMENT_ICONWIDTH 15
#define THUMB_INFO_HEIGHT 40
#define DETAIL_INFO_HEIGHT 40
#define USER_THUMB_ICONWIDTH 25

@interface AttatchItem : NSObject
@property (nonatomic, strong) NSString *image_url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@end

@interface PintrestItem : NSObject
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *attachItems;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) NSInteger comment_count;
@end

@protocol RecipePinterestDelegate <NSObject>
- (void)selectRecipe:(NSString *)recipeId;
@end


@interface RecipePinterest : UIView <PSCollectionViewDataSource,PSCollectionViewDelegate>
{
    NSMutableDictionary *rectDic;
    PSCollectionView *psCollectionView;
    NSMutableArray *pintrestItems;
}
@property (nonatomic, unsafe_unretained) id <RecipePinterestDelegate> delegate;
- (void)reloadPintRest;
@end
