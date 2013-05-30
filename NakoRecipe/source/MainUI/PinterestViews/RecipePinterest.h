//
//  RecipePinterest.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"

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
- (NSArray *)getShowIndex;
@end
