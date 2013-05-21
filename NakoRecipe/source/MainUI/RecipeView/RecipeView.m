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
        imageScrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageScrollView];
        
        recipeInfo = [[UIView alloc] init];
        recipeInfo.backgroundColor = [UIColor whiteColor];
        [self addSubview:recipeInfo];

        recipeContent = [[UILabel alloc] init];
        [self addSubview:recipeInfo];
        
        likeButton = [[UIButton alloc] init];
        likeButton.alpha = .4f;
        [likeButton setImage:[UIImage imageNamed:@"Icons-h_black"] forState:UIControlStateNormal];
        [recipeInfo addSubview:likeButton];
        
        likeLabel = [[UILabel alloc] init];
        likeLabel.textColor = [UIColor blackColor];
        likeLabel.textAlignment = NSTextAlignmentCenter;
        likeLabel.backgroundColor = [UIColor clearColor];
        likeLabel.alpha = .4f;
        likeLabel.font = [UIFont systemFontOfSize:10];
        [recipeInfo addSubview:likeLabel];
        
        commentButton = [[UIButton alloc] init];
        commentButton.alpha = .4f;
        [commentButton setImage:[UIImage imageNamed:@"Icons-comments_black"] forState:UIControlStateNormal];
        [recipeInfo addSubview:commentButton];
        
        commentLabel = [[UILabel alloc] init];
        commentLabel.textColor = [UIColor blackColor];
        commentLabel.textAlignment = NSTextAlignmentCenter;
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.alpha = .4f;
        commentLabel.font = [UIFont systemFontOfSize:10];
        [recipeInfo addSubview:commentLabel];
        
        
        recipeDetailInfo = [[UIView alloc] init];
        recipeDetailInfo.backgroundColor = [UIColor whiteColor];
        [self addSubview:recipeDetailInfo];
        
        recipeContent = [[UILabel alloc] init];
        recipeContent.textColor = [UIColor blackColor];
        recipeContent.backgroundColor = [UIColor clearColor];
        recipeContent.lineBreakMode = NSLineBreakByWordWrapping;
        recipeContent.numberOfLines = 0;
        recipeContent.font = [UIFont systemFontOfSize:12];
        [recipeDetailInfo addSubview:recipeContent];
        
        imageArr = [[NSMutableArray alloc] init];
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
    for( int i = 0; i < [imageArr count]; i++ )
    {
        AsyncImageView *tempSubImageView = [imageArr objectAtIndex:i];
        [tempSubImageView setFrame:CGRectMake((imageScrollView.frame.size.width)*i+10, (imageScrollView.frame.size.height)/2-tempSubImageView.frame.size.height/2, imageScrollView.frame.size.width-20, tempSubImageView.frame.size.height)];
    }
    [imageScrollView setContentSize:CGSizeMake((imageScrollView.frame.size.width)*([imageArr count]), imageScrollView.frame.size.height)];
    [recipeInfo setFrame:CGRectMake(10, imageScrollView.frame.size.height, imageScrollView.frame.size.width, RECIPE_THUMB_INFO_HEIGHT)];
    CGFloat iconSize = 15.0f;
    [likeButton setFrame:CGRectMake(imageScrollView.frame.size.width-10-(iconSize*2), iconSize, iconSize, iconSize)];
    [likeLabel setFrame:CGRectMake(imageScrollView.frame.size.width-10-(iconSize*1), iconSize, iconSize, iconSize)];
    [commentButton setFrame:CGRectMake(imageScrollView.frame.size.width-10-(iconSize*4), iconSize, iconSize, iconSize)];
    [commentLabel setFrame:CGRectMake(imageScrollView.frame.size.width-10-(iconSize*3), iconSize, iconSize, iconSize)];
    
    [recipeDetailInfo setFrame:CGRectMake(10, imageScrollView.frame.size.height+RECIPE_THUMB_INFO_HEIGHT+10, imageScrollView.frame.size.width,RECIPE_DETAIL_INFO_HEIGHT)];
    [recipeContent setFrame:CGRectMake(10, 10, recipeDetailInfo.frame.size.width-20, recipeDetailInfo.frame.size.height-20)];
    [recipeContent sizeToFit];
    [self setContentSize:CGSizeMake(self.frame.size.width,imageScrollView.frame.size.height+RECIPE_THUMB_INFO_HEIGHT+10+RECIPE_DETAIL_INFO_HEIGHT+10)];
}

- (void)reloadRecipeView:(NSString *)postId
{
    CGRect tempRect;
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    [imageScrollView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height * 0.8)];
    
    for( AsyncImageView *tempSubImageView in imageArr )
        [tempSubImageView removeFromSuperview];
    [imageArr removeAllObjects];
    
    Post *tempPost = [[CoreDataManager getInstance] getPost:postId];
    if( [tempPost.attatchments count] > 0 ){
        NSMutableArray *sortArray = [[NSMutableArray alloc] initWithArray:[tempPost.attatchments allObjects]];
        [sortArray sortUsingFunction:intSortURL context:nil];
        for( int i = 0; i < [sortArray count]; i++ ){
            AttatchMent *attachItem = [sortArray objectAtIndex:i];
            CGFloat resizeHeight = ((imageScrollView.frame.size.width-40) / (float)[attachItem.width integerValue] ) * (float)[attachItem.height intValue];
            AsyncImageView *tempAsyncImageview = [[AsyncImageView alloc] init];
            [tempAsyncImageview loadImageFromURL:attachItem.thumb_url withResizeWidth:imageScrollView.frame.size.width*4];
            [imageScrollView addSubview:tempAsyncImageview];
            [imageArr addObject:tempAsyncImageview];
            [tempAsyncImageview setFrame:CGRectMake((imageScrollView.frame.size.width)*i+10, (imageScrollView.frame.size.height)/2-resizeHeight/2, imageScrollView.frame.size.width-20,resizeHeight)];
        }
        [imageScrollView setContentSize:CGSizeMake((imageScrollView.frame.size.width)*([imageArr count]), imageScrollView.frame.size.height)];
        likeLabel.text = [NSString stringWithFormat:@"%d",[tempPost.like_count intValue]];
        commentLabel.text = [NSString stringWithFormat:@"%d",[tempPost.comment_count intValue]];
        recipeContent.text = tempPost.content;
    }
}

@end
