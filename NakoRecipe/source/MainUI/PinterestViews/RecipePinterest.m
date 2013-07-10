//
//  RecipePinterest.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipePinterest.h"
#import "CoreDataManager.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation AttatchItem
@synthesize image_url,width,height;
@end

@implementation PintrestItem
@synthesize title,attachItems,like_count,comment_count,creatorThumb,tags;
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
        
        UIImage *tempImage = [UIImage imageNamed:@"ic_loading.png"];
        UIImageView *activityIndicatorView = [[UIImageView alloc] init];
        float imageSize = [SystemInfo isPad]?35:24;
        activityIndicatorView.frame = CGRectMake(0, 0, imageSize, imageSize);
        activityIndicatorView.animationImages = [[NSArray alloc] initWithObjects:
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:0],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:20],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:40],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:60],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:80],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:100],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:120],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:140],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:160],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:180],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:200],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:220],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:240],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:260],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:280],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:300],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:320],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:340],
                                                 [CommonUI imageRotatedByDegrees:tempImage deg:360],
                                                 nil];
        activityIndicatorView.animationDuration = 1.5;
        [activityIndicatorView startAnimating];
                                                 
        refreshControl = [[ODRefreshControl alloc] initInScrollView:psCollectionView activityIndicatorView:activityIndicatorView];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        [refreshControl setTintColor:[CommonUI getUIColorFromHexString:@"E04C30"]];
        pintrestItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)makeLayout
{
    [rectDic setObject:@"{{0,0},{0,0}}" forKey:@"psCollectionView"];
    //value
    if( [SystemInfo isPad] ){
        [rectDic setObject:@"245" forKey:@"CELL_WIDTH"];
        [rectDic setObject:@"240" forKey:@"PHONE_TWO_THUMB_WIDTH"];
        [rectDic setObject:@"10" forKey:@"HEART_AND_COMMENT_ICONWIDTH"];
        [rectDic setObject:@"40" forKey:@"THUMB_INFO_HEIGHT"];
        [rectDic setObject:@"32" forKey:@"USER_THUMB_ICONWIDTH"];
    }else{
        [rectDic setObject:@"148" forKey:@"CELL_WIDTH"];
        [rectDic setObject:@"140" forKey:@"PHONE_TWO_THUMB_WIDTH"];
        [rectDic setObject:@"10" forKey:@"HEART_AND_COMMENT_ICONWIDTH"];
        [rectDic setObject:@"30" forKey:@"THUMB_INFO_HEIGHT"];
        [rectDic setObject:@"32" forKey:@"USER_THUMB_ICONWIDTH"];
    }
}

- (void)reloadPintRest
{
    [pintrestItems removeAllObjects];
    NSArray *posts = [[CoreDataManager getInstance] getPosts];
    if( [posts count] > 0 ){
        for( Post *item in posts )
        {
            PintrestItem *newPintrestItem   = [[PintrestItem alloc] init];
            newPintrestItem.postId          = item.post_id;
            newPintrestItem.title           = item.title;
            newPintrestItem.like_count      = [item.like_count integerValue];
            newPintrestItem.comment_count   = [item.comment_count integerValue];
            newPintrestItem.creatorThumb    = item.creator_url;
            newPintrestItem.tags            = item.tags;
            if( [item.attatchments count] > 0 ){
                NSMutableArray *sortArray = [[NSMutableArray alloc] initWithArray:[item.attatchments allObjects]];
                [sortArray sortUsingFunction:intSortURL context:nil];
                newPintrestItem.attachItems     = [[NSMutableArray alloc] init];
                for( AttatchMent *attatchItem in sortArray ){
                    AttatchItem *newAttatchItem = [[AttatchItem alloc] init];
                    newAttatchItem.image_url    =  attatchItem.thumb_url;
                    newAttatchItem.width        = [attatchItem.width intValue];
                    newAttatchItem.height       = [attatchItem.height intValue];
                    [newPintrestItem.attachItems addObject:newAttatchItem];
                }
            }
            [pintrestItems addObject:newPintrestItem];
        }
    }
    [psCollectionView reloadData];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [[self delegate] update];
}

- (void)startLoading
{
    [refreshControl beginRefreshing];
}

- (void)stopLoading
{
    [refreshControl endRefreshing];
}


- (AttatchItem *)getThumbNailItem:(PintrestItem *)pintrestItem
{
    for( AttatchItem *item in pintrestItem.attachItems )
        if( [[item.image_url lastPathComponent] hasPrefix:@"thumbnail"] )
            return item;
    return nil;
}

- (NSArray *)getShowIndex
{
    NSArray *visibles = [psCollectionView getVisibleIndex];
    return visibles;
}

#pragma mark - handle Button

- (void)handleHeartButtonTap:(UIButton *)paramSender
{
    NSLog(@"Heart Button :%d",paramSender.tag);
}

- (void)handleCommentButtonTap:(UIButton *)paramSender
{
    NSLog(@"Comment Button :%d",paramSender.tag);
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

- (NSMutableAttributedString *)makeAttrString:(NSString *)text withTitleHeight:(CGSize)titleLabelSize
{
    CGFloat textWidth = 0;
    textWidth += [[text substringToIndex:1] sizeWithFont:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height]].width;
    textWidth += [[text substringFromIndex:1] sizeWithFont:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height*.9]].width;
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#FFA500"] range:NSMakeRange(0, 1)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(0, 1)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(1, [text length]-1)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height*.9] range:NSMakeRange(1, [text length]-1)];
    if( textWidth > titleLabelSize.width && titleLabelSize.width != 0 ){
        return [self makeAttrString:text withTitleHeight:CGSizeMake(titleLabelSize.width, titleLabelSize.height*.9)];
    }
    return attrStr;
}

- (NSMutableAttributedString *)makeAttrString:(NSArray *)tagTextArr withInfoHeight:(CGSize)titleLabelSize
{
    if( [tagTextArr count] < 3 )
        return nil;
    CGFloat textWidth = 0;
    NSString *infoString    = nil;
    NSString *broadCastNum  = [tagTextArr objectAtIndex:0];
    NSString *creator       = [tagTextArr objectAtIndex:2];
    
    infoString = broadCastNum;
    infoString = [infoString stringByAppendingString:@"회 "];
    infoString = [infoString stringByAppendingString:creator];
    textWidth += [infoString sizeWithFont:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height]].width;
    
    NSInteger colorRocation = [broadCastNum length];
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:infoString];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(0, colorRocation)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(0, colorRocation)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(colorRocation, [infoString length]-colorRocation)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(colorRocation, [infoString length]-colorRocation)];
    if( textWidth > titleLabelSize.width && titleLabelSize.width != 0 ){
        return [self makeAttrString:tagTextArr withInfoHeight:CGSizeMake(titleLabelSize.width, titleLabelSize.height*.9)];
    }
    return attrStr;
}

- (void)shapeView:(UIView *)view
{
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)].CGPath;
    
    view.layer.masksToBounds = YES;
    view.layer.mask = shapeLayer;
}

- (UIView *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
//    NSLog(@"show : %d",index);
    CGFloat CELL_WIDTH                  = [[rectDic objectForKey:@"CELL_WIDTH"] floatValue];
    CGFloat USER_THUMB_ICONWIDTH        = [[rectDic objectForKey:@"USER_THUMB_ICONWIDTH"] floatValue];
    
    CGFloat thumbMargin = 6;
    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor clearColor];
    tempView.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
    tempView.layer.shadowRadius = 2;
    tempView.layer.shadowOpacity = 0.2;
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [CommonUI getUIColorFromHexString:@"F4F3F4"];
    bgView.layer.cornerRadius = 5;
    [tempView addSubview:bgView];
    
    CGFloat resizeHeight = 0;
    CGFloat titleHeight = 0;
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    if( [pintrestItem.attachItems count] > 0){
        AttatchItem *tempAttatchItem = [self getThumbNailItem:pintrestItem];
        UIImageView *tempAsyncImageView = [[UIImageView alloc] init];
        [tempAsyncImageView setImageWithURL:[NSURL URLWithString:tempAttatchItem.image_url]];
        if( tempAttatchItem != nil ){
            resizeHeight = (CELL_WIDTH / (float)tempAttatchItem.width ) * (float)tempAttatchItem.height;
            titleHeight = resizeHeight>CELL_WIDTH?resizeHeight*.2:CELL_WIDTH*.2;
        }else{
            resizeHeight = CELL_WIDTH;
            titleHeight = CELL_WIDTH*.2;
        }
        [tempView addSubview:tempAsyncImageView];
        [tempAsyncImageView setFrame:CGRectMake(0, 0, CELL_WIDTH, resizeHeight)];
        [self shapeView:tempAsyncImageView];
    }else{
        UILabel *noImageLabel = [[UILabel alloc] init];
        noImageLabel.textColor = [CommonUI getUIColorFromHexString:@"#657383"];
        noImageLabel.backgroundColor = [CommonUI getUIColorFromHexString:@"#EFEDFA"];
        noImageLabel.textAlignment = NSTextAlignmentCenter;
        noImageLabel.text = @"No Image";
        noImageLabel.font = [UIFont fontWithName:UIFONT_NAME size:20];
        [noImageLabel setFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_WIDTH)];
        [tempView addSubview:noImageLabel];
        [self shapeView:noImageLabel];
        resizeHeight = CELL_WIDTH;
        titleHeight = CELL_WIDTH*.2;
    }
    
    float fontSize = [SystemInfo isPad]?23:13;
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.attributedText = [self makeAttrString:pintrestItem.title withTitleHeight:CGSizeMake(CELL_WIDTH-10, fontSize)];
    [tempLabel setFrame:CGRectMake(10, resizeHeight, CELL_WIDTH-20, [tempLabel.attributedText size].height+5)];
    [tempView addSubview:tempLabel];
    [bgView setFrame:CGRectMake(0, 0, CELL_WIDTH, resizeHeight+tempLabel.frame.size.height)];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, resizeHeight + tempLabel.frame.size.height, CELL_WIDTH, 1)];
    lineView.backgroundColor = [CommonUI getUIColorFromHexString:@"#E4E3DC"];
    [tempView addSubview:lineView];
    
    NSArray *infoTextArr = [pintrestItem.tags componentsSeparatedByString:@"|"];
    
    UIImageView *tempAsyncImageView = [[UIImageView alloc] init];
    tempAsyncImageView.contentMode = UIViewContentModeScaleAspectFill;
    tempAsyncImageView.clipsToBounds = YES;
    tempAsyncImageView.layer.cornerRadius = 5;
    [tempAsyncImageView setImageWithURL:[NSURL URLWithString:pintrestItem.creatorThumb]];
    [tempAsyncImageView setFrame:CGRectMake(thumbMargin, resizeHeight+tempLabel.frame.size.height+thumbMargin, USER_THUMB_ICONWIDTH, USER_THUMB_ICONWIDTH)];
    [tempView addSubview:tempAsyncImageView];
    [bgView setFrame:CGRectMake(0, 0, CELL_WIDTH, bgView.frame.size.height + 1 + USER_THUMB_ICONWIDTH + thumbMargin*2)];

    float subFontSize = [SystemInfo isPad]?15:10;
    tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor grayColor];
    tempLabel.backgroundColor = [UIColor clearColor];
    if( [infoTextArr count] > 1 )
        tempLabel.text = [NSString stringWithFormat:@"%@ 방영",[infoTextArr objectAtIndex:1]];
    tempLabel.font = [UIFont systemFontOfSize:subFontSize];
    [tempLabel setFrame:CGRectMake(thumbMargin*2 + USER_THUMB_ICONWIDTH, bgView.frame.size.height - 20, CELL_WIDTH-thumbMargin*2, subFontSize)];
    [tempView addSubview:tempLabel];

    if( [infoTextArr count] > 3 ){
        CGSize infoTextSize = CGSizeMake(CELL_WIDTH-thumbMargin*3-USER_THUMB_ICONWIDTH, subFontSize);
        tempLabel = [[UILabel alloc] init];
        tempLabel.attributedText = [self makeAttrString:infoTextArr withInfoHeight:infoTextSize];
        tempLabel.backgroundColor = [UIColor clearColor];
        [tempLabel setFrame:CGRectMake(thumbMargin*2 + USER_THUMB_ICONWIDTH, bgView.frame.size.height - 35, infoTextSize.width, subFontSize)];
        [tempView addSubview:tempLabel];
    }
//    NSLog(@"%@",pintrestItem.tags);
    
    return tempView;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    CGFloat CELL_WIDTH                  = [[rectDic objectForKey:@"CELL_WIDTH"] floatValue];
    CGFloat DETAIL_INFO_HEIGHT          = [SystemInfo isPad]?50:40;
    
    CGFloat resizeHeight = 0;
    CGFloat titleHeight = 0;
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    if( [pintrestItem.attachItems count] > 0 ){
        AttatchItem *tempAttatchItem = [self getThumbNailItem:pintrestItem];
        if( tempAttatchItem != nil ){
            resizeHeight = (CELL_WIDTH / (float)tempAttatchItem.width ) * (float)tempAttatchItem.height;
            titleHeight = resizeHeight>CELL_WIDTH?resizeHeight*.2:CELL_WIDTH*.2;
        }else{
            resizeHeight = CELL_WIDTH;
            titleHeight = CELL_WIDTH*.2;
        }
    }else{
        resizeHeight = CELL_WIDTH;
        titleHeight = CELL_WIDTH*.2;
    }
    return resizeHeight+titleHeight+DETAIL_INFO_HEIGHT;
}
@end
