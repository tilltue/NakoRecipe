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
@synthesize title,attachItems,like_count,comment_count,creatorThumb,tags;
@end

@implementation RecipePinterest
@synthesize recipe_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rectDic = [[NSMutableDictionary alloc] init];
        [self makeLayout];
        _gridView = [[GMGridView alloc] initWithFrame:frame];
        _gridView.backgroundColor = [UIColor clearColor];
        _gridView.autoresizingMask = ~UIViewAutoresizingNone;
        _gridView.dataSource = self;
        _gridView.actionDelegate = self;
        [self  addSubview:_gridView];
        /*
        _tableView = [[UITableView alloc] initWithFrame:frame];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        testArr = [[NSMutableArray alloc] init];
        [self addSubview:_tableView];*/
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pintrestItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scoreListTable"];
    CGSize size = CGSizeMake(100, 100);
    size.height -= 65;
    
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:indexPath.row];
    UIImageView *ivRecipeThumb;
    UILabel     *lblLoading;
    CGFloat thumbMargin = 6;
    float fontSize = [SystemInfo isPad]?23:13;
    CGFloat USER_THUMB_ICONWIDTH        = [[rectDic objectForKey:@"USER_THUMB_ICONWIDTH"] floatValue];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scoreListTable"];
        ivRecipeThumb = [[UIImageView alloc] init];
        ivRecipeThumb.tag = 3;
        [ivRecipeThumb setFrame:CGRectMake(0, 0, size.width, size.height)];
        
        lblLoading = [[UILabel alloc] init];
        lblLoading.frame = ivRecipeThumb.frame;
        lblLoading.tag = 4;
        lblLoading.text = @"Image loading...";
        lblLoading.textAlignment = NSTextAlignmentCenter;
        lblLoading.textColor = [UIColor grayColor];
        [cell.contentView addSubview:lblLoading];
        [cell.contentView addSubview:ivRecipeThumb];
    }else{
        ivRecipeThumb = (UIImageView *)[cell.contentView viewWithTag:3];
        lblLoading = (UILabel *)[cell.contentView viewWithTag:4];
    }
    
    if( [pintrestItem.attachItems count] > 0){
        NSString *test = nil;
        if( [testArr count] > indexPath.row ){
            test = [testArr objectAtIndex:indexPath.row];
        }else{
            AttatchItem *tempAttatchItem = [self getThumbNailItem:pintrestItem];
            [testArr addObject:tempAttatchItem.image_url];
            test = tempAttatchItem.image_url;
        }
        
        ivRecipeThumb.backgroundColor = [UIColor clearColor];
        //        [tempAsyncImageView setImageWithURL:[NSURL URLWithString:tempAttatchItem.image_url] placeholderImage:nil];
        UIImage *tempImage = [FileControl checkCachedImage:test withDir:pintrestItem.postId];
        if( tempImage != nil ){
            ivRecipeThumb.image = tempImage;
        }else{
            [ivRecipeThumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:test]]
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              //ivRecipeThumb.image = image;
                                              UIImage *saveImage = [CommonUI ImageResize:image withSize:CGSizeMake(image.size.width/4, image.size.height/4)];
                                              ivRecipeThumb.image = saveImage;
                                              [FileControl cacheImage:test withImage:saveImage withDir:pintrestItem.postId];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              ;
                                          }];
        }
    }
    return cell;
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [pintrestItems count];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:position];
    [[self recipe_delegate] selectRecipe:pintrestItem.postId];
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

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if([SystemInfo isPad])
        return CGSizeMake(300, 200);
    else
        return CGSizeMake(150, 200);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    size.height -= 65;
    
    PintrestItem *pintrestItem = [pintrestItems objectAtIndex:index];
    UIImageView *ivRecipeThumb;
    UILabel     *lblLoading;
    CGFloat thumbMargin = 6;
    float fontSize = [SystemInfo isPad]?23:13;
    CGFloat USER_THUMB_ICONWIDTH        = [[rectDic objectForKey:@"USER_THUMB_ICONWIDTH"] floatValue];
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.layer.masksToBounds = NO;
        if( [SystemInfo shadowOptionModel])
            view.layer.cornerRadius = 8;
        
        cell.contentView = view;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    ivRecipeThumb = [[UIImageView alloc] init];
    ivRecipeThumb.tag = 3;
    [ivRecipeThumb setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    lblLoading = [[UILabel alloc] init];
    lblLoading.frame = ivRecipeThumb.frame;
    lblLoading.tag = 4;
    lblLoading.text = @"Image loading...";
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.textColor = [UIColor grayColor];
    
    if( [pintrestItem.attachItems count] > 0){
        AttatchItem *tempAttatchItem = [self getThumbNailItem:pintrestItem];
        ivRecipeThumb.backgroundColor = [UIColor clearColor];
        //        [tempAsyncImageView setImageWithURL:[NSURL URLWithString:tempAttatchItem.image_url] placeholderImage:nil];
        UIImage *tempImage = [FileControl checkCachedImage:tempAttatchItem.image_url withDir:pintrestItem.postId];
        if( tempImage != nil ){
            ivRecipeThumb.image = tempImage;
        }else{
            [ivRecipeThumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempAttatchItem.image_url]]
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              UIImage *saveImage = [CommonUI ImageResize:image withSize:CGSizeMake(image.size.width/4, image.size.height/4)];
                                              ivRecipeThumb.image = saveImage;
                                              [FileControl cacheImage:tempAttatchItem.image_url withImage:image withDir:pintrestItem.postId];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              ;
                                          }];
        }
    }
    [cell.contentView addSubview:lblLoading];
    [cell.contentView addSubview:ivRecipeThumb];
    return cell;
}

@end
