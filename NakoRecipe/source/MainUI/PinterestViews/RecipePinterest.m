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
        [rectDic setObject:@"10" forKey:@"HEART_AND_COMMENT_ICONWIDTH"];
        [rectDic setObject:@"40" forKey:@"THUMB_INFO_HEIGHT"];
        [rectDic setObject:@"40" forKey:@"DETAIL_INFO_HEIGHT"];
        [rectDic setObject:@"25" forKey:@"USER_THUMB_ICONWIDTH"];
    }else{
        [rectDic setObject:@"148" forKey:@"PHONE_TWO_CELL_WIDTH"];
        [rectDic setObject:@"140" forKey:@"PHONE_TWO_THUMB_WIDTH"];
        [rectDic setObject:@"10" forKey:@"HEART_AND_COMMENT_ICONWIDTH"];
        [rectDic setObject:@"30" forKey:@"THUMB_INFO_HEIGHT"];
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
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#3EA99F"] range:NSMakeRange(0, colorRocation)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(0, colorRocation)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(colorRocation, [infoString length]-colorRocation)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(colorRocation, [infoString length]-colorRocation)];
    if( textWidth > titleLabelSize.width && titleLabelSize.width != 0 ){
        return [self makeAttrString:tagTextArr withInfoHeight:CGSizeMake(titleLabelSize.width, titleLabelSize.height*.9)];
    }
    return attrStr;
}

- (UIView *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    NSLog(@"show : %d",index);
    CGFloat PHONE_TWO_CELL_WIDTH        = [[rectDic objectForKey:@"PHONE_TWO_CELL_WIDTH"] floatValue];
    CGFloat PHONE_TWO_THUMB_WIDTH       = [[rectDic objectForKey:@"PHONE_TWO_THUMB_WIDTH"] floatValue];
    CGFloat THUMB_INFO_HEIGHT           = [[rectDic objectForKey:@"THUMB_INFO_HEIGHT"] floatValue];
    CGFloat DETAIL_INFO_HEIGHT          = [[rectDic objectForKey:@"DETAIL_INFO_HEIGHT"] floatValue];
//    CGFloat HEART_AND_COMMENT_ICONWIDTH = [[rectDic objectForKey:@"HEART_AND_COMMENT_ICONWIDTH"] floatValue];
    CGFloat USER_THUMB_ICONWIDTH        = [[rectDic objectForKey:@"USER_THUMB_ICONWIDTH"] floatValue];
    
    CGFloat thumbMargin = (PHONE_TWO_CELL_WIDTH - PHONE_TWO_THUMB_WIDTH)/2;
    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    
    CGFloat resizeHeight = 0;
    CGFloat titleHeight = 0;
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    if( [pintrestItem.attachItems count] > 0){
        AttatchItem *tempAttatchItem = [pintrestItem.attachItems objectAtIndex:[pintrestItem.attachItems count]-1];
        AsyncImageView *tempAsyncImageView = [[AsyncImageView alloc] init];
        [tempAsyncImageView loadImageFromURL:tempAttatchItem.image_url withResizeWidth:PHONE_TWO_THUMB_WIDTH*4];
        
        resizeHeight = (PHONE_TWO_THUMB_WIDTH / (float)tempAttatchItem.width ) * (float)tempAttatchItem.height;
        titleHeight = resizeHeight>PHONE_TWO_THUMB_WIDTH?resizeHeight*.2:PHONE_TWO_THUMB_WIDTH*.2;
        [tempView addSubview:tempAsyncImageView];
        [tempAsyncImageView setFrame:CGRectMake(thumbMargin, thumbMargin, PHONE_TWO_THUMB_WIDTH, resizeHeight)];
    }else{
        UILabel *noImageLabel = [[UILabel alloc] init];
        noImageLabel.textColor = [CommonUI getUIColorFromHexString:@"#657383"];
        noImageLabel.backgroundColor = [CommonUI getUIColorFromHexString:@"#EFEDFA"];
        noImageLabel.textAlignment = NSTextAlignmentCenter;
        noImageLabel.text = @"No Image";
        noImageLabel.font = [UIFont fontWithName:UIFONT_NAME size:20];
        [noImageLabel setFrame:CGRectMake(thumbMargin, thumbMargin, PHONE_TWO_THUMB_WIDTH, PHONE_TWO_THUMB_WIDTH)];
        [tempView addSubview:noImageLabel];
        
        resizeHeight = PHONE_TWO_THUMB_WIDTH;
        titleHeight = PHONE_TWO_THUMB_WIDTH*.2;
    }
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.attributedText = [self makeAttrString:pintrestItem.title withTitleHeight:CGSizeMake(PHONE_TWO_CELL_WIDTH-10, titleHeight)];
    [tempLabel setFrame:CGRectMake(thumbMargin, resizeHeight+thumbMargin+5, PHONE_TWO_THUMB_WIDTH, [tempLabel.attributedText size].height+5)];
    [tempView addSubview:tempLabel];

    /*
    UIImageView *heartIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icons-h_black"]];
    heartIcon.alpha = .4f;
    [heartIcon setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*4), resizeHeight+titleHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:heartIcon];
    
    tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.text = [NSString stringWithFormat:@"%d",pintrestItem.like_count];
    tempLabel.alpha = .4f;
    tempLabel.font = [UIFont systemFontOfSize:10];
    [tempLabel setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*2), resizeHeight+titleHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH*2, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempLabel];
    
    UIButton *tempButton = [[UIButton alloc] init];
    //tempButton.backgroundColor = [UIColor redColor];
    tempButton.alpha = .4f;
    tempButton.tag = index;
    [tempButton setFrame:CGRectMake(heartIcon.frame.origin.x-3, heartIcon.frame.origin.y-3, heartIcon.frame.size.width+tempLabel.frame.size.width+6, heartIcon.frame.size.height+6)];
    [tempButton addTarget:self action:@selector(handleHeartButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [tempView addSubview:tempButton];
    
    
    UIImageView *commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icons-comments_black"]];
    commentIcon.alpha = .4f;
    [commentIcon setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*8), resizeHeight+titleHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:commentIcon];
    
    tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.text = [NSString stringWithFormat:@"%d",pintrestItem.comment_count];
    tempLabel.alpha = .4f;
    tempLabel.font = [UIFont systemFontOfSize:10];
    [tempLabel setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*6), resizeHeight+titleHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH*2, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempLabel];
    
    tempButton = [[UIButton alloc] init];
    //tempButton.backgroundColor = [UIColor blueColor];
    tempButton.tag = index;
    [tempButton setFrame:CGRectMake(commentIcon.frame.origin.x-3, commentIcon.frame.origin.y-3, commentIcon.frame.size.width+tempLabel.frame.size.width+6, commentIcon.frame.size.height+6)];
    [tempButton addTarget:self action:@selector(handleCommentButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [tempView addSubview:tempButton];
    */
    
    NSArray *infoTextArr = [pintrestItem.tags componentsSeparatedByString:@"|"];
    
    tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = [UIColor blackColor];
    tempLabel.textAlignment = NSTextAlignmentRight;
    tempLabel.backgroundColor = [UIColor clearColor];
    if( [infoTextArr count] > 1 )
        tempLabel.text = [NSString stringWithFormat:@"%@ 방영",[infoTextArr objectAtIndex:1]];
    tempLabel.font = [UIFont systemFontOfSize:10];
    [tempLabel setFrame:CGRectMake(thumbMargin, resizeHeight+thumbMargin+titleHeight+thumbMargin, PHONE_TWO_CELL_WIDTH-thumbMargin*2, THUMB_INFO_HEIGHT)];
    [tempView addSubview:tempLabel];

    UIView *tempView2 = [[UIView alloc] init];
    tempView2.backgroundColor = [CommonUI getUIColorFromHexString:@"#F2F3F7"];
    [tempView2 setFrame:CGRectMake(0, resizeHeight+thumbMargin+titleHeight+THUMB_INFO_HEIGHT, PHONE_TWO_CELL_WIDTH, DETAIL_INFO_HEIGHT)];
    [tempView addSubview:tempView2];
    
    AsyncImageView *tempAsyncImageView = [[AsyncImageView alloc] init];
    tempAsyncImageView.contentMode = UIViewContentModeScaleAspectFill;
    tempAsyncImageView.clipsToBounds = YES;
    [tempAsyncImageView loadImageFromURL:pintrestItem.creatorThumb withResizeWidth:USER_THUMB_ICONWIDTH*4];
    [tempAsyncImageView setFrame:CGRectMake(thumbMargin, DETAIL_INFO_HEIGHT/2-USER_THUMB_ICONWIDTH/2, USER_THUMB_ICONWIDTH, USER_THUMB_ICONWIDTH)];
    [tempView2 addSubview:tempAsyncImageView];
    
    if( [infoTextArr count] > 3 ){
        CGSize infoTextSize = CGSizeMake(PHONE_TWO_CELL_WIDTH-thumbMargin*3-USER_THUMB_ICONWIDTH, DETAIL_INFO_HEIGHT*.6-thumbMargin*2);
        tempLabel = [[UILabel alloc] init];
        tempLabel.attributedText = [self makeAttrString:infoTextArr withInfoHeight:infoTextSize];
        tempLabel.backgroundColor = [UIColor clearColor];
        [tempLabel setFrame:CGRectMake(thumbMargin*2+USER_THUMB_ICONWIDTH, DETAIL_INFO_HEIGHT/2-infoTextSize.height/3, infoTextSize.width, infoTextSize.height)];
        [tempView2 addSubview:tempLabel];
    }
    [tempView addSubview:tempView2];
//    NSLog(@"%@",pintrestItem.tags);
    
    return tempView;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    CGFloat PHONE_TWO_THUMB_WIDTH       = [[rectDic objectForKey:@"PHONE_TWO_THUMB_WIDTH"] floatValue];
    CGFloat THUMB_INFO_HEIGHT           = [[rectDic objectForKey:@"THUMB_INFO_HEIGHT"] floatValue];
    CGFloat DETAIL_INFO_HEIGHT          = [[rectDic objectForKey:@"DETAIL_INFO_HEIGHT"] floatValue];
    
    CGFloat resizeHeight = 0;
    CGFloat titleHeight = 0;
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    if( [pintrestItem.attachItems count] > 0 ){
        AttatchItem *tempAttatchItem = [pintrestItem.attachItems objectAtIndex:[pintrestItem.attachItems count]-1];
        resizeHeight = (PHONE_TWO_THUMB_WIDTH / (float)tempAttatchItem.width ) * (float)tempAttatchItem.height;
        titleHeight = resizeHeight>PHONE_TWO_THUMB_WIDTH?resizeHeight*.2:PHONE_TWO_THUMB_WIDTH*.2;
    }else{
        resizeHeight = PHONE_TWO_THUMB_WIDTH;
        titleHeight = PHONE_TWO_THUMB_WIDTH*.2;
    }
    return resizeHeight+titleHeight+THUMB_INFO_HEIGHT+DETAIL_INFO_HEIGHT;
}
@end
