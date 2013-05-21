//
//  RecipePinterest.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipePinterest.h"
#import "CoreDataManager.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation AttatchItem
@synthesize image_url,width,height;
@end

@implementation PintrestItem
@synthesize title,attachItems,like_count,comment_count;
@end

@implementation RecipePinterest
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rectDic = [[NSMutableDictionary alloc] init];
        [self makeLayout];
        
        psCollectionView = [[PSCollectionView alloc] initWithFrame:frame];
        psCollectionView.backgroundColor = [UIColor clearColor];
        psCollectionView.autoresizingMask = ~UIViewAutoresizingNone;
        psCollectionView.collectionViewDataSource = self;
        psCollectionView.collectionViewDelegate = self;
        if( [SystemInfo isPad] ){
            psCollectionView.numColsPortrait = 3;
            psCollectionView.numColsLandscape = 3;
        }else{
            psCollectionView.numColsPortrait = 2;
            psCollectionView.numColsLandscape = 2;
        }
        [self  addSubview:psCollectionView];
        
        pintrestItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)makeLayout
{
    [rectDic setObject:@"{{0,0},{0,0}}" forKey:@"psCollectionView"];
    //value
    if( [SystemInfo isPad] ){
        [rectDic setObject:@"248" forKey:@"PHONE_TWO_CELL_WIDTH"];
        [rectDic setObject:@"240" forKey:@"PHONE_TWO_THUMB_WIDTH"];
        [rectDic setObject:@"15" forKey:@"HEART_AND_COMMENT_ICONWIDTH"];
        [rectDic setObject:@"40" forKey:@"THUMB_INFO_HEIGHT"];
        [rectDic setObject:@"40" forKey:@"DETAIL_INFO_HEIGHT"];
        [rectDic setObject:@"25" forKey:@"USER_THUMB_ICONWIDTH"];
    }else{
        [rectDic setObject:@"148" forKey:@"PHONE_TWO_CELL_WIDTH"];
        [rectDic setObject:@"140" forKey:@"PHONE_TWO_THUMB_WIDTH"];
        [rectDic setObject:@"15" forKey:@"HEART_AND_COMMENT_ICONWIDTH"];
        [rectDic setObject:@"40" forKey:@"THUMB_INFO_HEIGHT"];
        [rectDic setObject:@"40" forKey:@"DETAIL_INFO_HEIGHT"];
        [rectDic setObject:@"25" forKey:@"USER_THUMB_ICONWIDTH"];
    }
}

- (void)reloadPintRest
{
    [pintrestItems removeAllObjects];
    NSArray *posts = [[CoreDataManager getInstance] getPosts];
    if( [posts count] > 0 ){
        for( Post *item in posts )
        {
            PintrestItem *newPintrestItem = [[PintrestItem alloc] init];
            newPintrestItem.postId = item.post_id;
            newPintrestItem.title = item.title;
            newPintrestItem.like_count = [item.like_count integerValue];
            newPintrestItem.comment_count = [item.comment_count integerValue];
            if( [item.attatchments count] > 0 ){
                NSMutableArray *sortArray = [[NSMutableArray alloc] initWithArray:[item.attatchments allObjects]];
                [sortArray sortUsingFunction:intSortURL context:nil];
                newPintrestItem.attachItems = [[NSMutableArray alloc] init];
                for( AttatchMent *attatchItem in sortArray ){
                    AttatchItem *newAttatchItem = [[AttatchItem alloc] init];
                    newAttatchItem.image_url =  attatchItem.thumb_url;
                    newAttatchItem.width = [attatchItem.width intValue];
                    newAttatchItem.height = [attatchItem.height intValue];
                    [newPintrestItem.attachItems addObject:newAttatchItem];
                }
            }
            [pintrestItems addObject:newPintrestItem];
        }
    }
    [psCollectionView reloadData];
}

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [PSCollectionViewCell class];
}

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView {
    return [pintrestItems count];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    [[self delegate] selectRecipe:pintrestItem.postId];
}

- (UIView *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    CGFloat PHONE_TWO_CELL_WIDTH        = [[rectDic objectForKey:@"PHONE_TWO_CELL_WIDTH"] floatValue];
    CGFloat PHONE_TWO_THUMB_WIDTH       = [[rectDic objectForKey:@"PHONE_TWO_THUMB_WIDTH"] floatValue];
    CGFloat THUMB_INFO_HEIGHT           = [[rectDic objectForKey:@"THUMB_INFO_HEIGHT"] floatValue];
    CGFloat DETAIL_INFO_HEIGHT          = [[rectDic objectForKey:@"DETAIL_INFO_HEIGHT"] floatValue];
    CGFloat HEART_AND_COMMENT_ICONWIDTH = [[rectDic objectForKey:@"HEART_AND_COMMENT_ICONWIDTH"] floatValue];
    //CGFloat USER_THUMB_ICONWIDTH        = [[rectDic objectForKey:@"USER_THUMB_ICONWIDTH"] floatValue];
    
    CGFloat thumbMargin = (PHONE_TWO_CELL_WIDTH - PHONE_TWO_THUMB_WIDTH)/2;
    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    AttatchItem *tempAttatchItem = [pintrestItem.attachItems objectAtIndex:0];
    AsyncImageView *tempAsyncImageView = [[AsyncImageView alloc] init];
    [tempAsyncImageView loadImageFromURL:tempAttatchItem.image_url withResizeWidth:PHONE_TWO_THUMB_WIDTH*4];
    CGFloat resizeHeight = (PHONE_TWO_THUMB_WIDTH / (float)tempAttatchItem.width ) * (float)tempAttatchItem.height;
    [tempView addSubview:tempAsyncImageView];
    [tempView setFrame:CGRectMake(0, 0, PHONE_TWO_CELL_WIDTH, resizeHeight+THUMB_INFO_HEIGHT+DETAIL_INFO_HEIGHT)];
    [tempAsyncImageView setFrame:CGRectMake(thumbMargin, thumbMargin, PHONE_TWO_THUMB_WIDTH, resizeHeight)];
    
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.text = pintrestItem.title;
    tempLabel.alpha = .8f;
    tempLabel.font = [UIFont systemFontOfSize:9];
    [tempLabel setFrame:CGRectMake(thumbMargin, resizeHeight+thumbMargin+5, PHONE_TWO_THUMB_WIDTH, 10)];
    [tempView addSubview:tempLabel];
    
    UIButton *tempButton = [[UIButton alloc] init];
    tempButton.alpha = .4f;
    [tempButton setImage:[UIImage imageNamed:@"Icons-h_black"] forState:UIControlStateNormal];
    [tempButton setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*2), resizeHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempButton];
    
    tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.text = [NSString stringWithFormat:@"%d",pintrestItem.like_count];
    tempLabel.alpha = .4f;
    tempLabel.font = [UIFont systemFontOfSize:10];
    [tempLabel setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH), resizeHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempLabel];
    
    tempButton = [[UIButton alloc] init];
    tempButton.alpha = .4f;
    [tempButton setImage:[UIImage imageNamed:@"Icons-comments_black"] forState:UIControlStateNormal];
    [tempButton setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*4), resizeHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempButton];
    
    tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.text = [NSString stringWithFormat:@"%d",pintrestItem.comment_count];
    tempLabel.alpha = .4f;
    tempLabel.font = [UIFont systemFontOfSize:10];
    [tempLabel setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*3), resizeHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempLabel];
    
    UIView *tempView2 = [[UIView alloc] init];
    tempView2.backgroundColor = [CommonUI getUIColorFromHexString:@"#F2F3F7"];
    /*
    UIImageView *tempImageView = [[UIImageView alloc] init];
    NSData *data = [[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://cfile222.uf.daum.net/image/2304F15051949F031E7836"]];
    UIImage *tempImage = [[UIImage alloc] initWithData:data];
    [tempImageView setImage:tempImage];
    [tempView2 addSubview:tempImageView];
    [tempView2 setFrame:CGRectMake(0, resizeHeight+THUMB_INFO_HEIGHT, PHONE_TWO_CELL_WIDTH, DETAIL_INFO_HEIGHT)];
    [tempImageView setFrame:CGRectMake(thumbMargin, DETAIL_INFO_HEIGHT/2-USER_THUMB_ICONWIDTH/2, USER_THUMB_ICONWIDTH, USER_THUMB_ICONWIDTH)];
    [tempView addSubview:tempView2];*/
    return tempView;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    CGFloat PHONE_TWO_THUMB_WIDTH       = [[rectDic objectForKey:@"PHONE_TWO_THUMB_WIDTH"] floatValue];
    CGFloat THUMB_INFO_HEIGHT           = [[rectDic objectForKey:@"THUMB_INFO_HEIGHT"] floatValue];
    CGFloat DETAIL_INFO_HEIGHT          = [[rectDic objectForKey:@"DETAIL_INFO_HEIGHT"] floatValue];
    
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    AttatchItem *tempAttatchItem = [pintrestItem.attachItems objectAtIndex:0];
    CGFloat resizeHeight = (PHONE_TWO_THUMB_WIDTH / (float)tempAttatchItem.width ) * (float)tempAttatchItem.height;
    //NSLog(@"%d %d %f",tempAttatchItem.width,tempAttatchItem.height,resizeHeight);
    return resizeHeight+THUMB_INFO_HEIGHT+DETAIL_INFO_HEIGHT;
}
@end
