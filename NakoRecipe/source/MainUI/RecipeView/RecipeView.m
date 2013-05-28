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
#import <QuartzCore/QuartzCore.h>

@implementation RecipeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        // Initialization code
        rectDic = [[NSMutableDictionary alloc] init];
        [self makeLayout];
                
        recipeInfo = [[UIView alloc] init];
        recipeInfo.backgroundColor = [UIColor whiteColor];
        [self addSubview:recipeInfo];
        
        noImageLabel = [[UILabel alloc] init];
        noImageLabel.textColor = [CommonUI getUIColorFromHexString:@"#657383"];
        noImageLabel.backgroundColor = [CommonUI getUIColorFromHexString:@"#EFEDFA"];
        noImageLabel.textAlignment = NSTextAlignmentCenter;
        noImageLabel.text = @"No Image";
        noImageLabel.font = [UIFont fontWithName:UIFONT_NAME size:50];
        [recipeInfo addSubview:noImageLabel];
        
        imageScrollView = [[UIScrollView alloc] init];
        imageScrollView.backgroundColor = [CommonUI getUIColorFromHexString:@"#EFEDFA"];
        imageScrollView.scrollEnabled = NO;
        [self initGestureRecognizer:imageScrollView];
        [recipeInfo addSubview:imageScrollView];
        
        imagePageControl = [[UIPageControl alloc] init];
        imagePageControl.hidden = YES;
        [recipeInfo addSubview:imagePageControl];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        [recipeInfo addSubview:titleLabel];
        
        youtubeThumbImageView = [[AsyncImageView alloc] init];
        youtubeThumbImageView.backgroundColor = [UIColor clearColor];
        [recipeInfo addSubview:youtubeThumbImageView];
        
        youtubeButton = [[UIButton alloc] init];
        youtubeButton.layer.cornerRadius = 5;
        youtubeButton.layer.borderColor = [UIColor grayColor].CGColor;
        youtubeButton.layer.borderWidth = 1.0f;
        [youtubeButton addTarget:self action:@selector(handleYoutubeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [recipeInfo addSubview:youtubeButton];
        
//        likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icons-h_black"]];
//        likeImageView.alpha = .4f;
//        [recipeInfo addSubview:likeImageView];
//        
//        likeLabel = [[UILabel alloc] init];
//        likeLabel.textColor = [UIColor blackColor];
//        likeLabel.textAlignment = NSTextAlignmentCenter;
//        likeLabel.backgroundColor = [UIColor clearColor];
//        likeLabel.alpha = .4f;
//        likeLabel.font = [UIFont systemFontOfSize:10];
//        [recipeInfo addSubview:likeLabel];
//        
//        likeButton = [[UIButton alloc] init];
//        likeButton.alpha = .4f;
//        [likeButton addTarget:self action:@selector(handleHeartButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//        [recipeInfo addSubview:likeButton];
//
//        commentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icons-comments_black"]];
//        commentImageView.alpha = .4f;
//        [recipeInfo addSubview:commentImageView];

//        commentLabel = [[UILabel alloc] init];
//        commentLabel.textColor = [UIColor blackColor];
//        commentLabel.textAlignment = NSTextAlignmentCenter;
//        commentLabel.backgroundColor = [UIColor clearColor];
//        commentLabel.alpha = .4f;
//        commentLabel.font = [UIFont systemFontOfSize:10];
//        [recipeInfo addSubview:commentLabel];
//        
//        commentButton = [[UIButton alloc] init];
//        commentButton.alpha = .4f;
//        [commentButton addTarget:self action:@selector(handleCommentButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//        [recipeInfo addSubview:commentButton];
        
        recipeDetailInfo = [[UIView alloc] init];
        recipeDetailInfo.backgroundColor = [UIColor whiteColor];
        [self addSubview:recipeDetailInfo];
        
        recipeContent = [[UITextView alloc] init];
        recipeContent.textColor = [UIColor blackColor];
        recipeContent.editable = NO;
        recipeContent.backgroundColor = [UIColor clearColor];
        recipeContent.font = [UIFont fontWithName:UIFONT_NAME size:14];
        [recipeDetailInfo addSubview:recipeContent];
        
        imageArr = [[NSMutableArray alloc] init];
        currentPostId = nil;
    }
    return self;
}

- (void)makeLayout
{
    [rectDic setObject:@"{{10,10},{0,0}}"   forKey:@"imageScrollView"];
    [rectDic setObject:@"20"                forKey:@"DETAIL_INFO_MARGIN"];
    [rectDic setObject:@"30"                forKey:@"RECIPE_INFO_HEIGHT"];
    [rectDic setObject:@"30"                forKey:@"YOUTUBE_BTN_HEIGHT"];
    [rectDic setObject:@"300"               forKey:@"RECIPE_DETAIL_INFO_HEIGHT"];
    [rectDic setObject:@"15"                forKey:@"IMAGE_PAGECONTROL_HEIGHT"];
}

- (void)setLayout
{
    CGRect tempRect;
    CGFloat youtubeThumbMargin = 3.0f;
    CGFloat iconSize = 15.0f;
    CGFloat DETAIL_INFO_MARGIN          = [[rectDic objectForKey:@"DETAIL_INFO_MARGIN"] floatValue];
    CGFloat RECIPE_INFO_HEIGHT          = [[rectDic objectForKey:@"RECIPE_INFO_HEIGHT"] floatValue];
    CGFloat RECIPE_DETAIL_INFO_HEIGHT   = [[rectDic objectForKey:@"RECIPE_DETAIL_INFO_HEIGHT"] floatValue];
    CGFloat YOUTUBE_BTN_HEIGHT          = [[rectDic objectForKey:@"YOUTUBE_BTN_HEIGHT"] floatValue];
    
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    for( int i = 0; i < [imageArr count]; i++ )
    {
        AsyncImageView *tempSubImageView = [imageArr objectAtIndex:i];
        [tempSubImageView setFrame:CGRectMake((self.frame.size.width - tempRect.origin.x*4)*i, 0, self.frame.size.width - tempRect.origin.x*4, tempSubImageView.frame.size.height)];
    }
    if( [imageArr count] > imagePageControl.currentPage ){
        AsyncImageView *tempSubImageView = [imageArr objectAtIndex:imagePageControl.currentPage];
        [imageScrollView setFrame:CGRectMake(tempRect.origin.x,tempRect.origin.y, tempSubImageView.frame.size.width, tempSubImageView.frame.size.height)];
        [recipeInfo setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, imageScrollView.frame.size.height+tempRect.origin.y*4+RECIPE_INFO_HEIGHT+YOUTUBE_BTN_HEIGHT)];
        [titleLabel setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y*2+imageScrollView.frame.size.height, recipeInfo.frame.size.width - tempRect.origin.x*2-iconSize*6, RECIPE_INFO_HEIGHT)];
    }else{
        [recipeInfo setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height*.3+tempRect.origin.y*4+RECIPE_INFO_HEIGHT+YOUTUBE_BTN_HEIGHT)];
        [noImageLabel setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, recipeInfo.frame.size.width - tempRect.origin.x*2, recipeInfo.frame.size.height * 0.8-RECIPE_INFO_HEIGHT-YOUTUBE_BTN_HEIGHT+tempRect.origin.y)];
        [titleLabel setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y*2+noImageLabel.frame.size.height, recipeInfo.frame.size.width - tempRect.origin.x*2-iconSize*6, RECIPE_INFO_HEIGHT)];
    }
    [imageScrollView setContentSize:CGSizeMake((imageScrollView.frame.size.width)*([imageArr count]), imageScrollView.frame.size.height)];
    if([SystemInfo isPad]){
        [youtubeButton      setFrame:CGRectMake(tempRect.origin.y, titleLabel.frame.origin.y+titleLabel.frame.size.height+tempRect.origin.y, 100, YOUTUBE_BTN_HEIGHT)];
        [youtubeThumbImageView setFrame:CGRectMake(youtubeButton.frame.origin.x+youtubeThumbMargin, youtubeButton.frame.origin.y+youtubeThumbMargin, youtubeButton.frame.size.width/3,youtubeButton.frame.size.height-youtubeThumbMargin*2)];
    }else{
        [youtubeButton      setFrame:CGRectMake(tempRect.origin.y, titleLabel.frame.origin.y+titleLabel.frame.size.height+tempRect.origin.y, (recipeInfo.frame.size.width - tempRect.origin.x*2)*(0.35), YOUTUBE_BTN_HEIGHT)];
        [youtubeThumbImageView setFrame:CGRectMake(youtubeButton.frame.origin.x+youtubeThumbMargin, youtubeButton.frame.origin.y+youtubeThumbMargin, youtubeButton.frame.size.width/3,youtubeButton.frame.size.height-youtubeThumbMargin*2)];
    }
    //    [likeImageView      setFrame:CGRectMake(imageScrollView.frame.size.width-(iconSize*2), recipeInfo.frame.size.height-iconSize*2, iconSize, iconSize)];
    //    [likeLabel          setFrame:CGRectMake(imageScrollView.frame.size.width-(iconSize*1), recipeInfo.frame.size.height-iconSize*2, iconSize*2, iconSize)];
    //    [likeButton         setFrame:CGRectMake(imageScrollView.frame.size.width-(iconSize*2), recipeInfo.frame.size.height-iconSize*2, iconSize*3, iconSize)];
    //
    //    [commentImageView   setFrame:CGRectMake(imageScrollView.frame.size.width-(iconSize*5), recipeInfo.frame.size.height-iconSize*2, iconSize, iconSize)];
    //    [commentLabel       setFrame:CGRectMake(imageScrollView.frame.size.width-(iconSize*4), recipeInfo.frame.size.height-iconSize*2, iconSize*2, iconSize)];
    //    [commentButton      setFrame:CGRectMake(imageScrollView.frame.size.width-(iconSize*5), recipeInfo.frame.size.height-iconSize*2, iconSize*3, iconSize)];
    
    [recipeDetailInfo setFrame:CGRectMake(10, recipeInfo.frame.size.height+DETAIL_INFO_MARGIN+10, recipeInfo.frame.size.width,RECIPE_DETAIL_INFO_HEIGHT)];
    [recipeContent setFrame:CGRectMake(10, 10, recipeDetailInfo.frame.size.width-20, recipeDetailInfo.frame.size.height-20)];
    [recipeContent sizeToFit];
    [self setContentSize:CGSizeMake(self.frame.size.width,recipeInfo.frame.size.height+DETAIL_INFO_MARGIN+10+RECIPE_DETAIL_INFO_HEIGHT+10)];
}

- (void)layoutSubviews
{
    [self setLayout];
}

- (void)handleHeartButtonTap:(UIButton *)paramSender
{
    NSLog(@"Heart Button :%d",paramSender.tag);
}

- (void)handleCommentButtonTap:(UIButton *)paramSender
{
    NSLog(@"Comment Button :%d",paramSender.tag);
}

- (void)handleYoutubeButtonTap:(UIButton *)paramSender
{
    NSLog(@"Youtube Button :%d",paramSender.tag);
    Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
    NSArray *infoTextArr = [tempPost.tags componentsSeparatedByString:@"|"];
    if( [infoTextArr count] > 4 ){
        NSString *videoName = [infoTextArr objectAtIndex:4];
        if( [videoName isEqualToString:@"null"] ){
        }else{
            NSString *string = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoName];
            NSURL *url = [NSURL URLWithString:string];
            UIApplication *app = [UIApplication sharedApplication];
            [app openURL:url];
        }
    }
}

#pragma mark - swipe handler

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        imagePageControl.currentPage -=1;
        [imageScrollView setContentOffset:CGPointMake(imagePageControl.currentPage*imageScrollView.frame.size.width, 0) animated:YES];
    }else if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        imagePageControl.currentPage +=1;
        [imageScrollView setContentOffset:CGPointMake(imagePageControl.currentPage*imageScrollView.frame.size.width, 0) animated:YES];
    }

    [self setLayout];
}

- (void)initGestureRecognizer:(UIView *)view
{
    UISwipeGestureRecognizer *swipeRecognizer;
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:swipeRecognizer];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swipeRecognizer];
    
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [view addGestureRecognizer:tapRecognizer];
}

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state==UIGestureRecognizerStateEnded)
    {
        CGPoint point = [gestureRecognizer locationInView:recipeInfo];
        if( point.x < imageScrollView.frame.size.width/2 ){
            imagePageControl.currentPage -=1;
            [imageScrollView setContentOffset:CGPointMake(imagePageControl.currentPage*imageScrollView.frame.size.width, 0) animated:YES];
        }else{
            imagePageControl.currentPage +=1;
            [imageScrollView setContentOffset:CGPointMake(imagePageControl.currentPage*imageScrollView.frame.size.width, 0) animated:YES];
        }
    }
}


- (NSString *)splitEnter:(NSString*)string
{
    if (string){
        if( [string length] && [string characterAtIndex:0] == '\n'){
            return [self splitEnter:[string substringFromIndex:1]];
        }else
            return string;
    }else
        return string;
}

- (void)makeYoutubeButton:(BOOL)enable
{
    if( enable ){
        UIEdgeInsets textInset = [SystemInfo isPad]?UIEdgeInsetsMake(10, 30, 0, 0):UIEdgeInsetsMake(10, 31, 0, 0);
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:@"YouTube"];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(0, 3)];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME_HA size:24] range:NSMakeRange(0, 3)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#C11B17"] range:NSMakeRange(3, 4)];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME_HA size:20] range:NSMakeRange(3, 4)];
        [youtubeButton setAttributedTitle:attrStr forState:UIControlStateNormal];
        [youtubeButton setTitleEdgeInsets:textInset];
    }else{
        UIEdgeInsets textInset = [SystemInfo isPad]?UIEdgeInsetsMake(3, 0, 0, 0):UIEdgeInsetsMake(3, 0, 0, 0);
        NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:@"Youtube영상없음"];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(0, 3)];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME_HA size:18] range:NSMakeRange(0, 3)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#C11B17"] range:NSMakeRange(3, 4)];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME_HA size:18] range:NSMakeRange(3, 4)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(7, 4)];
        [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME_HA size:18] range:NSMakeRange(7, 4)];
        [youtubeButton setAttributedTitle:attrStr forState:UIControlStateNormal];
        [youtubeButton setTitleEdgeInsets:textInset];
    }
}

- (NSMutableAttributedString *)makeAttrString:(NSArray *)tagTextArr withInfoHeight:(CGSize)titleLabelSize
{
    if( [tagTextArr count] < 4 )
        return nil;
    CGFloat textWidth = 0;
    NSString *infoString    = nil;
    NSString *creator       = [tagTextArr objectAtIndex:2];
    NSString *foodName      = [tagTextArr objectAtIndex:3];
    
    infoString = creator;
    infoString = [infoString stringByAppendingString:@"의 "];
    infoString = [infoString stringByAppendingString:foodName];
    textWidth += [infoString sizeWithFont:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height]].width;
    
    NSInteger colorRocation = [creator length];
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:infoString];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#FFA500"] range:NSMakeRange(0, colorRocation)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(0, colorRocation)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[CommonUI getUIColorFromHexString:@"#696565"] range:NSMakeRange(colorRocation, [infoString length]-colorRocation)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:UIFONT_NAME size:titleLabelSize.height] range:NSMakeRange(colorRocation, [infoString length]-colorRocation)];
    if( textWidth > titleLabelSize.width && titleLabelSize.width != 0 ){
        return [self makeAttrString:tagTextArr withInfoHeight:CGSizeMake(titleLabelSize.width, titleLabelSize.height*.9)];
    }
    return attrStr;
}

- (void)reloadRecipeView:(NSString *)postId
{
    currentPostId = postId;
    [self setContentOffset:CGPointMake(0, 0)];
    CGFloat iconSize = 15.0f;
    CGRect tempRect;
    CGFloat RECIPE_INFO_HEIGHT          = [[rectDic objectForKey:@"RECIPE_INFO_HEIGHT"] floatValue];
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    [recipeInfo setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height * 0.8)];
    [noImageLabel setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, recipeInfo.frame.size.width - tempRect.origin.x*2, recipeInfo.frame.size.height * 0.8)];
    [imageScrollView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, recipeInfo.frame.size.width - tempRect.origin.x*2, recipeInfo.frame.size.height * 0.8)];
    [titleLabel setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y*2+imageScrollView.frame.size.height, recipeInfo.frame.size.width - tempRect.origin.x*2-iconSize*6, RECIPE_INFO_HEIGHT)];
    
    for( AsyncImageView *tempSubImageView in imageArr )
        [tempSubImageView removeFromSuperview];
    [imageArr removeAllObjects];
//    likeLabel.text      = @"0";
//    commentLabel.text   = @"0";
    recipeContent.text  = @"";
    
    Post *tempPost = [[CoreDataManager getInstance] getPost:postId];
    if( [tempPost.attatchments count] > 0 ){
        NSMutableArray *sortArray = [[NSMutableArray alloc] initWithArray:[tempPost.attatchments allObjects]];
        [sortArray sortUsingFunction:intSortURL context:nil];
        for( int i = 0; i < [sortArray count]; i++ ){
            if( [AppPreference getValid] ){
                AttatchMent *attachItem = [sortArray objectAtIndex:i];
                if( [[attachItem.thumb_url lastPathComponent] hasPrefix:@"thumbnail"] )
                    continue;
                CGFloat resizeHeight = ((imageScrollView.frame.size.width-40) / (float)[attachItem.width integerValue] ) * (float)([attachItem.height intValue]);
                AsyncImageView *tempAsyncImageview = [[AsyncImageView alloc] init];
                [tempAsyncImageview loadImageFromURL:attachItem.thumb_url withResizeWidth:imageScrollView.frame.size.width*4];
                [imageScrollView addSubview:tempAsyncImageview];
                [imageArr addObject:tempAsyncImageview];
                [tempAsyncImageview setFrame:CGRectMake((imageScrollView.frame.size.width)*i, 0, imageScrollView.frame.size.width,resizeHeight+40)];
            }else{
                AttatchMent *attachItem = [sortArray objectAtIndex:i];
                if( ![[attachItem.thumb_url lastPathComponent] hasPrefix:@"thumbnail"] )
                    continue;
                CGFloat resizeHeight = ((imageScrollView.frame.size.width-40) / (float)[attachItem.width integerValue] ) * (float)([attachItem.height intValue]);
                AsyncImageView *tempAsyncImageview = [[AsyncImageView alloc] init];
                [tempAsyncImageview loadImageFromURL:attachItem.thumb_url withResizeWidth:imageScrollView.frame.size.width*4];
                [imageScrollView addSubview:tempAsyncImageview];
                [imageArr addObject:tempAsyncImageview];
                [tempAsyncImageview setFrame:CGRectMake((imageScrollView.frame.size.width)*i, 0, imageScrollView.frame.size.width,resizeHeight+40)];
            }
        }
        [imageScrollView setContentSize:CGSizeMake((imageScrollView.frame.size.width)*([imageArr count]), imageScrollView.frame.size.height)];
        //NSLog(@"%@ : %@",postId,recipeContent.text);
        noImageLabel.hidden = YES;
        imageScrollView.hidden = NO;
    }else{
        //첨부 이미지가 없을때
        noImageLabel.hidden = NO;
        imageScrollView.hidden = YES;
    }
    NSArray *infoTextArr = [tempPost.tags componentsSeparatedByString:@"|"];
    if( [infoTextArr count] > 4 ){
        //NSLog(@"%@",tempPost.tags);
        titleLabel.attributedText = [self makeAttrString:infoTextArr withInfoHeight:titleLabel.frame.size];
        if( ![[infoTextArr objectAtIndex:4] isEqualToString:@"null"] ){
            NSString *thumbImageUrl = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg",[infoTextArr objectAtIndex:4]];
            youtubeThumbImageView.uniqueDir = nil;
            youtubeThumbImageView.uniqueDir = [NSString stringWithFormat:@"/%@",[infoTextArr objectAtIndex:4]];
            [youtubeThumbImageView loadImageFromURL:thumbImageUrl withResizeWidth:youtubeThumbImageView.frame.size.width*4];
            [self makeYoutubeButton:YES];
        }else{
            youtubeThumbImageView.uniqueDir = nil;
            [youtubeThumbImageView setImage:nil];
            [self makeYoutubeButton:NO];
        }
    }else{
        titleLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
    }

    recipeContent.text = [self splitEnter:tempPost.content];
    imagePageControl.currentPage    = 0;
    imagePageControl.numberOfPages  = [imageArr count];
    [imageScrollView setContentOffset:CGPointMake(imagePageControl.currentPage*imageScrollView.frame.size.width, 0) animated:YES];
    [self layoutIfNeeded];
}

@end
