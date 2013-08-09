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
#import "FileControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation AttatchItem
@synthesize image_url,width,height;
@end

@implementation PintrestItem
@synthesize title,attachItems,like_count,comment_count,creatorThumb,tags,count;
@end

@implementation LikeCommentItem
@synthesize postId,count,like_count,comment_count;
@end

@implementation RecipePinterest
@synthesize recipe_delegate;
@synthesize likeCommentArr;
@synthesize alignType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _gridView = [[GMGridView alloc] initWithFrame:frame];
        _gridView.backgroundColor = [UIColor clearColor];
        _gridView.autoresizingMask = ~UIViewAutoresizingNone;
        _gridView.dataSource = self;
        _gridView.actionDelegate = self;
        _gridView.delegate = self;
        _gridView.showsHorizontalScrollIndicator = NO;
        _gridView.showsVerticalScrollIndicator = NO;
        [self  addSubview:_gridView];

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
                                                 
        _refreshControl = [[ODRefreshControl alloc] initInScrollView:_gridView activityIndicatorView:activityIndicatorView];
        [_refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        [_refreshControl setTintColor:[CommonUI getUIColorFromHexString:@"E04C30"]];
        pintrestItems = [[NSMutableArray alloc] init];
        
        queue = dispatch_queue_create("yourOwnQueueName", NULL);
        _decelerating = NO;
        likeCommentArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)getItemCount
{
    return [pintrestItems count];
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
    [_gridView reloadData];
}

- (void)updatePintrestItemForLike
{
    for( LikeCommentItem *item in likeCommentArr ){
        PintrestItem *pintrestItem = [self getPintrestItem:item.postId];
        if( pintrestItem != nil ){
            pintrestItem.like_count = item.like_count;
            pintrestItem.comment_count = item.comment_count;
            pintrestItem.count = item.count;
        }
    }
    NSMutableArray *sortArray = pintrestItems;
    switch (alignType) {
        case 0:
            [sortArray sortUsingFunction:intSortNew context:nil];
            break;
        case 1:
            [sortArray sortUsingFunction:intSortCount context:nil];
            break;
        case 2:
            [sortArray sortUsingFunction:intSortLikeCount context:nil];
            break;
        case 3:
            [sortArray sortUsingFunction:intSortCommenctCount context:nil];
            break;
        default:
            break;
    }
}


NSInteger intSortNew(PintrestItem *item1, PintrestItem *item2, void *context)
{
    int v1 = [item1.postId intValue];
    int v2 = [item2.postId intValue];
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

NSInteger intSortCount(PintrestItem *item1, PintrestItem *item2, void *context)
{
    int v1 = item1.count;
    int v2 = item2.count;
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

NSInteger intSortLikeCount(PintrestItem *item1, PintrestItem *item2, void *context)
{
    int v1 = item1.like_count;
    int v2 = item2.like_count;
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

NSInteger intSortCommenctCount(PintrestItem *item1, PintrestItem *item2, void *context)
{
    int v1 = item1.comment_count;
    int v2 = item2.comment_count;
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


- (void)reloadLikePintRest
{
    if( [likeCommentArr count] > 0 )
        [self updatePintrestItemForLike];
    if( !_refreshControl.refreshing ){
        [_gridView reloadData];
    }
}

- (void)sortAlign
{
    
}

- (void)algin:(int)type
{
    if( alignType != type ){
        alignType = type;
        if( !_refreshControl.refreshing ){
            [self updatePintrestItemForLike];
            [_gridView reloadData];
        }
    }
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [[self recipe_delegate] update];
}

- (void)startLoading
{
    [_refreshControl beginRefreshing];
}

- (void)stopLoading
{
    [_refreshControl endRefreshing];
}


- (AttatchItem *)getThumbNailItem:(PintrestItem *)pintrestItem
{
    for( AttatchItem *item in pintrestItem.attachItems )
        if( [[item.image_url lastPathComponent] hasPrefix:@"thumbnail"] )
            return item;
    return nil;
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

#pragma mark - grid delegate

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [pintrestItems count];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:position];
    [[self recipe_delegate] selectRecipe:pintrestItem.postId];
}

- (void)shapeView:(UIView *)view
{
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)].CGPath;
    
    view.layer.masksToBounds = YES;
    view.layer.mask = shapeLayer;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if([SystemInfo isPad])
        return CGSizeMake(245, 310);
    else
        return CGSizeMake(150, 200);
}

- (PintrestItem *)getPintrestItem:(NSString *)postId
{
    for( PintrestItem *item in pintrestItems )
        if( [item.postId isEqualToString:postId] )
            return item;
    return nil;
}

- (LikeCommentItem *)getLikeItem:(NSString *)postId
{
    for( LikeCommentItem *item in likeCommentArr )
        if( [item.postId isEqualToString:postId] )
            return item;
    return nil;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    size.height -= [SystemInfo isPad]?60:40;
    
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    UIImageView *ivRecipeThumb;
    UILabel     *lblLoading;
    UIImageView *ivCreatorThumb;
    UILabel *lblRecipeName;
    UILabel *lblCreator;
    UILabel *lblCount;
    UIImageView *ivLike;
    UIImageView *ivComment;
    UILabel *lblLike;
    UILabel *lblComment;
    
    CGFloat thumbMargin = 5;
    CGFloat iconSize = [SystemInfo isPad]?50:37;
    float fontSize = [SystemInfo isPad]?23:13;
    CGRect rect = CGRectZero;
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.cornerRadius = 5;
        if( [SystemInfo shadowOptionModel]){
            view.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
            view.layer.shadowRadius = 2;
            view.layer.shadowOpacity = 0.2;
        }
        view.backgroundColor = [CommonUI getUIColorFromHexString:@"F4F3F4"];
        cell.contentView = view;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
    ivRecipeThumb = [[UIImageView alloc] init];
    ivRecipeThumb.tag = 4;
    ivRecipeThumb.clipsToBounds = YES;
    ivRecipeThumb.contentMode = UIViewContentModeScaleAspectFill;
    [ivRecipeThumb setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    lblLoading = [[UILabel alloc] init];
    lblLoading.frame = ivRecipeThumb.frame;
    lblLoading.tag = 5;
    lblLoading.text = @"Image loading...";
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.textColor = [UIColor grayColor];
    
    rect = [SystemInfo isPad]?CGRectMake(0, 0, 70, 35):CGRectMake(0, 0, 40, 20);
    lblCount = [[UILabel alloc] init];
    lblCount.tag = 6;
    lblCount.textAlignment = NSTextAlignmentCenter;
    lblCount.backgroundColor = [CommonUI getUIColorFromHexString:@"E04C30"];
    lblCount.textColor = [UIColor whiteColor];
    lblCount.font = [UIFont systemFontOfSize:fontSize];
    lblCount.frame = rect;
    
    rect.origin = CGPointMake(thumbMargin, size.height-iconSize-thumbMargin);
    rect.size = CGSizeMake(iconSize, iconSize);
    ivCreatorThumb = [[UIImageView alloc] init];
    ivCreatorThumb.tag = 7;
    ivCreatorThumb.clipsToBounds = YES;
    ivCreatorThumb.layer.cornerRadius = 5;
    ivCreatorThumb.contentMode = UIViewContentModeScaleAspectFill;
    ivCreatorThumb.frame = rect;
    ivCreatorThumb.backgroundColor = [UIColor clearColor];
    
    rect.origin = CGPointMake(thumbMargin, size.height+thumbMargin+2);
    rect.size = [SystemInfo isPad]?CGSizeMake(200, 30):CGSizeMake(100, 15);
    lblRecipeName = [[UILabel alloc] init];
    lblRecipeName.backgroundColor = [UIColor clearColor];
    lblRecipeName.textColor = [UIColor darkGrayColor];
    lblRecipeName.frame = rect;
    lblRecipeName.text = pintrestItem.title;
    lblRecipeName.font = [UIFont systemFontOfSize:fontSize];
    
    rect.origin.y += rect.size.height;
    rect.size = [SystemInfo isPad]?CGSizeMake(100, 20):CGSizeMake(50, 14);
    lblCreator = [[UILabel alloc] init];
    lblCreator.backgroundColor = [UIColor clearColor];
    lblCreator.textColor = [UIColor grayColor];
    lblCreator.frame = rect;
    lblCreator.font = [UIFont systemFontOfSize:fontSize-([SystemInfo isPad]?3:1)];
    
    rect.origin.x = [SystemInfo isPad]?130:70;
    rect.origin.y = size.height+thumbMargin+([SystemInfo isPad]?38:17);
    rect.size = CGSizeMake(14, 12);
    ivLike = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_like"]];
    ivLike.frame = rect;
    
    LikeCommentItem *tempLikeItem = [self getLikeItem:pintrestItem.postId];
    rect.origin.x += 17;
    rect.size = [SystemInfo isPad]?CGSizeMake(30, 12):CGSizeMake(20, 12);
    lblLike = [[UILabel alloc] init];
    lblLike.backgroundColor = [UIColor clearColor];
    lblLike.textColor = [UIColor darkGrayColor];
    lblLike.font = [UIFont systemFontOfSize:fontSize-([SystemInfo isPad]?8:2)];
    lblLike.frame = rect;
    lblLike.tag = 8;
    lblLike.textAlignment = NSTextAlignmentCenter;
    lblLike.text = tempLikeItem!=nil?[NSString stringWithFormat:@"%d",tempLikeItem.like_count]:@"0";
    
    rect.origin.x += [SystemInfo isPad]?32:22;
    rect.size = CGSizeMake(14, 12);
    ivComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_comment"]];
    ivComment.frame = rect;
    
    rect.origin.x += 17;
    rect.size = [SystemInfo isPad]?CGSizeMake(30, 12):CGSizeMake(20, 12);
    lblComment = [[UILabel alloc] init];
    lblComment.backgroundColor = [UIColor clearColor];
    lblComment.textColor = [UIColor darkGrayColor];
    lblComment.font = [UIFont systemFontOfSize:fontSize-([SystemInfo isPad]?8:2)];
    lblComment.frame = rect;
    lblComment.tag = 9;
    lblComment.textAlignment = NSTextAlignmentCenter;
    lblComment.text = tempLikeItem!=nil?[NSString stringWithFormat:@"%d",tempLikeItem.comment_count]:@"0";
    
    UIImage *tempImage = [FileControl checkCachedImage:pintrestItem.creatorThumb withDir:pintrestItem.postId];
    if( tempImage != nil ){
        if( !_decelerating )
            ivCreatorThumb.image = tempImage;
    }else{
        [ivCreatorThumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pintrestItem.creatorThumb]]
                             placeholderImage:nil
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          int scale = [SystemInfo imageResizeScale];
                                          UIImage *saveImage;
                                          if( image.size.width < iconSize || image.size.height < iconSize){
                                              saveImage = image;
                                          }else{
                                              saveImage = [CommonUI ImageResize:image
                                                                       withSize:CGSizeMake(image.size.width/scale,
                                                                                           image.size.height/scale)];
                                              
                                          }
                                          GMGridViewCell *cell = [_gridView cellForItemAtIndex:index];
                                          UIImageView *tempImageView = (UIImageView *)[cell.contentView viewWithTag:4];
                                          tempImageView = (UIImageView *)[tempImageView viewWithTag:7];
                                          tempImageView.image = image;
                                          dispatch_async( queue ,
                                                         ^ {
                                                             [FileControl cacheImage:pintrestItem.creatorThumb withImage:image withDir:pintrestItem.postId];
                                                         });
                                      }
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          ;
                                      }];
    }
    NSArray *infoTextArr = [pintrestItem.tags componentsSeparatedByString:@"|"];
    if( [infoTextArr count] > 3){
        lblCount.text = [NSString stringWithFormat:@"%@호",[infoTextArr objectAtIndex:0]];
        lblCreator.text = [infoTextArr objectAtIndex:2];
    }
    if( [pintrestItem.attachItems count] > 0){
        AttatchItem *tempAttatchItem = [self getThumbNailItem:pintrestItem];
        ivRecipeThumb.backgroundColor = [UIColor clearColor];
        UIImage *tempImage = [FileControl checkCachedImage:tempAttatchItem.image_url withDir:pintrestItem.postId];
        if( tempImage != nil ){
            if( !_decelerating )
                ivRecipeThumb.image = tempImage;
            else{
                lblLoading.text = @"";
                lblLoading.backgroundColor = [CommonUI getUIColorFromHexString:@"F4F3F4"];
            }
        }else{
            NSLog(@"%d %@",index,tempAttatchItem.image_url);
            [ivRecipeThumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempAttatchItem.image_url]]
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              int scale = [SystemInfo imageResizeScale];
                                              UIImage *saveImage;
                                              if( image.size.width < size.width * 2 || image.size.height < size.height * 2){
                                                  saveImage = image;
                                              }else{
                                                  saveImage = [CommonUI ImageResize:image
                                                                           withSize:CGSizeMake(image.size.width/scale,
                                                                                               image.size.height/scale)];
                                                  
                                              }
                                              GMGridViewCell *cell = [_gridView cellForItemAtIndex:index];
                                              UIImageView *tempImageView = (UIImageView *)[cell.contentView viewWithTag:4];
                                              tempImageView.image = saveImage;
                                              dispatch_async( queue ,
                                                             ^ {
                                                                 [FileControl cacheImage:tempAttatchItem.image_url withImage:saveImage withDir:pintrestItem.postId];
                                                             });
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              ;
                                          }];
        }
    }

    [ivRecipeThumb addSubview:ivCreatorThumb];
    [cell.contentView addSubview:ivLike];
    [cell.contentView addSubview:lblLike];
    [cell.contentView addSubview:ivComment];
    [cell.contentView addSubview:lblComment];
    
    [cell.contentView addSubview:lblRecipeName];
    [cell.contentView addSubview:lblCreator];
    [cell.contentView addSubview:lblLoading];
    [cell.contentView addSubview:ivRecipeThumb];
    [cell.contentView addSubview:lblCount];
    return cell;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if( [SystemInfo shadowOptionModel] )
        return;
    CGPoint currentOffset = _gridView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabsf(scrollSpeedNotAbs);
        if (scrollSpeed > 0.5) {
            isScrollingFast = YES;
            //NSLog(@"Fast");
        } else {
            if( isScrollingFast ){
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadImage) object:nil];
                [self performSelector:@selector(loadImage)];
            }
            isScrollingFast = NO;
            //NSLog(@"Slow");
        }
        
        lastOffset = currentOffset;
        lastOffsetCapture = currentTime;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if( ![SystemInfo shadowOptionModel] )
        _decelerating = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( ![SystemInfo shadowOptionModel] ){
        _decelerating = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadImage) object:nil];
        [self performSelector:@selector(loadImage)];
    }
}

- (void)loadImage
{
    NSRange range = [_gridView getRangeOfPosition];
    CGSize size = [self GMGridView:_gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    size.height -= 40;
    for( int i = range.location; i < range.location+range.length; i++){
        if( i > [pintrestItems count]-1 )
            break;
        PintrestItem *pintrestItem = [pintrestItems objectAtIndex:i];
        UIImageView *ivRecipeThumb;
        UIImageView *ivCreatorThumb;
        GMGridViewCell *cell = [_gridView cellForItemAtIndex:i];
        ivRecipeThumb = (UIImageView *)[cell.contentView viewWithTag:4];
        ivCreatorThumb = (UIImageView *)[ivRecipeThumb viewWithTag:7];
        
        if( ivCreatorThumb.image == nil ){
            UIImage *tempImage = [FileControl checkCachedImage:pintrestItem.creatorThumb withDir:pintrestItem.postId];
            if( tempImage != nil ){
                ivCreatorThumb.image = tempImage;
            }
        }
            
        if( ivRecipeThumb.image != nil )
            continue;
        if( [pintrestItem.attachItems count] > 0){
            AttatchItem *tempAttatchItem = [self getThumbNailItem:pintrestItem];
            ivRecipeThumb.backgroundColor = [UIColor clearColor];
            UIImage *tempImage = [FileControl checkCachedImage:tempAttatchItem.image_url withDir:pintrestItem.postId];
            if( tempImage != nil ){
                ivRecipeThumb.alpha = 0;
                ivRecipeThumb.image = tempImage;
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1+(i%5)*.1];
                [ivRecipeThumb setAlpha:1];
                [UIView commitAnimations];
            }else{
            }
        }
    }
}
@end
