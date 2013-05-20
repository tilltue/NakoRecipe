//
//  RecipeView.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeView.h"
#import "AsyncImageView.h"
#import "CoreDataManager.h"

@implementation RecipeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rectDic = [[NSMutableDictionary alloc] init];
        [self makeLayout];
        
        titleLabel = [[UILabel alloc] init];
        [self addSubview:titleLabel];
        
        imageScrollView = [[UIScrollView alloc] init];
        imageScrollView.backgroundColor = [UIColor redColor];
        [self addSubview:imageScrollView];
        
        recipeInfo = [[UIView alloc] init];
        [self addSubview:recipeInfo];

        recipeContent = [[UILabel alloc] init];
        [self addSubview:recipeInfo];
    }
    return self;
}

- (void)makeLayout
{
    [rectDic setObject:@"{{10,10},{0,0}}" forKey:@"imageScrollView"];
}

- (void)layoutSubviews
{
    CGRect tempRect;
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    [imageScrollView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height * 0.8)];
    for( int i = 0; i < [imageScrollView.subviews count]; i++ )
    {
        AsyncImageView *tempSubImageView = [imageScrollView.subviews objectAtIndex:i];
        [tempSubImageView setFrame:CGRectMake(imageScrollView.frame.size.width*i, 0, imageScrollView.frame.size.width, tempSubImageView.frame.size.height)];
    }
}

- (void)reloadRecipeView:(NSString *)postId
{
    CGRect tempRect;
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    [imageScrollView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height * 0.8)];
    
    for( UIImageView *tempSubImageView in imageScrollView.subviews )
        [tempSubImageView removeFromSuperview];
    Post *tempPost = [[CoreDataManager getInstance] getPost:postId];
    if( [tempPost.attatchments count] > 0 ){
        int i = 0;
        for( AttatchMent *attachItem in tempPost.attatchments ){
            CGFloat resizeHeight = (imageScrollView.frame.size.width / (float)[attachItem.width integerValue] ) * (float)[attachItem.height intValue];
            AsyncImageView *tempAsyncImageview = [[AsyncImageView alloc] init];
            [tempAsyncImageview loadImageFromURL:attachItem.thumb_url withResizeWidth:imageScrollView.frame.size.width];
            [imageScrollView addSubview:tempAsyncImageview];
            [tempAsyncImageview setFrame:CGRectMake(imageScrollView.frame.size.width*i, 0, [attachItem.width intValue],resizeHeight)];
            i++;
        }
    }
}

@end
