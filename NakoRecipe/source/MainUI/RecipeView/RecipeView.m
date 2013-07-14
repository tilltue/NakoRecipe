//
//  RecipeView.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeView.h"
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

        bgView = [[UIView alloc] init];
        bgView.layer.cornerRadius = 5;
        bgView.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
        bgView.layer.shadowRadius = 2;
        bgView.layer.shadowOpacity = 0.2;
        bgView.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
        [self addSubview:bgView];
        
        recipeInfo = [[UIView alloc] init];
        recipeInfo.layer.cornerRadius = 5;
        recipeInfo.layer.masksToBounds = YES;
        recipeInfo.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
        [bgView addSubview:recipeInfo];
        
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
        [imagePageControl setPageIndicatorTintColor:[CommonUI getUIColorFromHexString:@"#E4E3DC"]];
        [imagePageControl setCurrentPageIndicatorTintColor:[CommonUI getUIColorFromHexString:@"E04C30"]];
        [recipeInfo addSubview:imagePageControl];
        
        lineView_1 = [[UIView alloc] init];
        lineView_1.backgroundColor = [CommonUI getUIColorFromHexString:@"E4E3DC"];
        [recipeInfo addSubview:lineView_1];
        
        lineView_2 = [[UIView alloc] init];
        lineView_2.backgroundColor = [CommonUI getUIColorFromHexString:@"E4E3DC"];
        [recipeInfo addSubview:lineView_2];
        
        lineView_3 = [[UIView alloc] init];
        lineView_3.backgroundColor = [CommonUI getUIColorFromHexString:@"E4E3DC"];
        [recipeInfo addSubview:lineView_3];
        
        ivLike = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_like"]];
        [recipeInfo addSubview:ivLike];
        
        lblLike = [[UILabel alloc] init];
        lblLike.font = [UIFont systemFontOfSize:12];
        lblLike.textAlignment = NSTextAlignmentCenter;
        lblLike.textColor = [UIColor grayColor];
        lblLike.backgroundColor = [UIColor clearColor];
        [recipeInfo addSubview:lblLike];
        
        ivComment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_comment"]];
        [recipeInfo addSubview:ivComment];

        lblComment = [[UILabel alloc] init];
        lblComment.textAlignment = NSTextAlignmentCenter;
        lblComment.font = [UIFont systemFontOfSize:12];
        lblComment.textColor = [UIColor grayColor];
        lblComment.backgroundColor = [UIColor clearColor];
        [recipeInfo addSubview:lblComment];

        ivStuff = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_ingredients"]];
        [recipeInfo addSubview:ivStuff];
        
        lblStuff = [[UILabel alloc] init];
        lblStuff.font = [UIFont systemFontOfSize:15];
        lblStuff.textColor = [CommonUI getUIColorFromHexString:@"E04C30"];
        lblStuff.text = @"재료";
        lblStuff.backgroundColor = [UIColor clearColor];
        [recipeInfo addSubview:lblStuff];

        lblStuffDetail = [[UILabel alloc] init];
        lblStuffDetail.font = [UIFont systemFontOfSize:12];
        lblStuffDetail.textColor = [UIColor grayColor];
        lblStuffDetail.backgroundColor = [UIColor clearColor];
        lblStuffDetail.lineBreakMode = NSLineBreakByCharWrapping;
        lblStuffDetail.numberOfLines = 2;
        [recipeInfo addSubview:lblStuffDetail];
        
        youtubeButton = [[UIButton alloc] init];
        youtubeButton.layer.cornerRadius = 5;
        youtubeButton.layer.masksToBounds = YES;
        [youtubeButton addTarget:self action:@selector(handleYoutubeButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        [youtubeButton setImage:[UIImage imageNamed:@"btn_youtube"] forState:UIControlStateNormal];
        [recipeInfo addSubview:youtubeButton];
        
        ivRecipe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_directions"]];
        [recipeInfo addSubview:ivRecipe];
        
        lblRecipe = [[UILabel alloc] init];
        lblRecipe.font = [UIFont systemFontOfSize:15];
        lblRecipe.textColor = [CommonUI getUIColorFromHexString:@"E04C30"];
        lblRecipe.text = @"요리법";
        lblRecipe.backgroundColor = [UIColor clearColor];
        [recipeInfo addSubview:lblRecipe];
        
        recipeContent = [[UITextView alloc] init];
        recipeContent.textColor = [UIColor grayColor];
        recipeContent.editable = NO;
        recipeContent.backgroundColor = [UIColor clearColor];
        recipeContent.font = [UIFont fontWithName:UIFONT_NAME size:14];
        [recipeInfo addSubview:recipeContent];
        
        commentView = [[UIView alloc] init];
        commentView.layer.cornerRadius = 5;
        commentView.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
        commentView.layer.shadowRadius = 2;
        commentView.layer.shadowOpacity = 0.2;
        commentView.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
        [self addSubview:commentView];
        
        imageArr = [[NSMutableArray alloc] init];
        currentPostId = nil;
    }
    return self;
}

- (void)makeLayout
{
    [rectDic setObject:@"{{10,10},{0,0}}"     forKey:@"imageScrollView"];
    [rectDic setObject:@"200"                forKey:@"RECIPE_INFO_HEIGHT"];
}

- (void)shapeView:(UIView *)view
{
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)].CGPath;
    
    view.layer.masksToBounds = YES;
    view.layer.mask = shapeLayer;
}

- (void)setLayout
{
    CGRect tempRect;
    CGFloat RECIPE_INFO_HEIGHT          = [[rectDic objectForKey:@"RECIPE_INFO_HEIGHT"] floatValue];
    
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    for( int i = 0; i < [imageArr count]; i++ )
    {
        UIImageView *tempSubImageView = [imageArr objectAtIndex:i];
        [tempSubImageView setFrame:CGRectMake((self.frame.size.width - tempRect.origin.x*2)*i, 0, self.frame.size.width - tempRect.origin.x*2, tempSubImageView.frame.size.height)];
    }
    if( [imageArr count] > imagePageControl.currentPage ){
        UIImageView *tempSubImageView = [imageArr objectAtIndex:imagePageControl.currentPage];
        [imageScrollView setFrame:CGRectMake(0,0, tempSubImageView.frame.size.width, tempSubImageView.frame.size.height)];
        [bgView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, imageScrollView.frame.size.height+tempRect.origin.y*4+RECIPE_INFO_HEIGHT)];
        recipeInfo.frame = CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height);
    }else{
        [bgView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height*.3+tempRect.origin.y*4+RECIPE_INFO_HEIGHT)];
        recipeInfo.frame = CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height);
        [noImageLabel setFrame:CGRectMake(0, 0, recipeInfo.frame.size.width - tempRect.origin.x*2, recipeInfo.frame.size.height * 0.8-RECIPE_INFO_HEIGHT+tempRect.origin.y)];
    }
    [imageScrollView setContentSize:CGSizeMake((imageScrollView.frame.size.width)*([imageArr count]), imageScrollView.frame.size.height)];
    
    tempRect.origin.x = 0;
    tempRect.origin.y = imageScrollView.frame.origin.y + imageScrollView.frame.size.height + 10;
    tempRect.size.width = recipeInfo.frame.size.width;
    tempRect.size.height = 10;
    
    imagePageControl.frame = tempRect;
    
    tempRect.origin.x = 0;
    tempRect.origin.y = imagePageControl.frame.origin.y + imagePageControl.frame.size.height + 10;
    tempRect.size.height = 1;
    lineView_1.frame = tempRect;
    
    tempRect.origin.x = 10;
    tempRect.origin.y = lineView_1.frame.origin.y + lineView_1.frame.size.height + 5;
    tempRect.size.width = 102;
    tempRect.size.height = 25;
    youtubeButton.frame = tempRect;
    
    tempRect.origin.x = recipeInfo.frame.size.width - 100;
    tempRect.origin.y = lineView_1.frame.origin.y + lineView_1.frame.size.height + 12;
    tempRect.size.width = 14;
    tempRect.size.height = 12;
    ivLike.frame = tempRect;
    
    tempRect.origin.x += 19;
    tempRect.size.width = 25;
    tempRect.size.height = 12;
    lblLike.frame = tempRect;
    lblLike.text = @"300";
    
    tempRect.origin.x += 30;
    tempRect.size.width = 12;
    ivComment.frame = tempRect;
    
    tempRect.origin.x += 17;
    tempRect.size.width = 25;
    tempRect.size.height = 12;
    lblComment.frame = tempRect;
    lblComment.text = @"300";
    
    tempRect.origin.x = 0;
    tempRect.origin.y = lineView_1.frame.origin.y + 35;
    tempRect.size.width = recipeInfo.frame.size.width;
    tempRect.size.height = 1;
    lineView_2.frame = tempRect;
    
    tempRect.origin.x = 10;
    tempRect.origin.y = lineView_2.frame.origin.y + 11;
    tempRect.size.width = 24;
    tempRect.size.height = 24;
    ivStuff.frame = tempRect;
    
    tempRect.origin.x = 44;
    tempRect.size.width = 30;
    tempRect.size.height = 24;
    lblStuff.frame = tempRect;
    
    tempRect.origin.x = 10;
    tempRect.origin.y = ivStuff.frame.origin.y + ivStuff.frame.size.height + 5;
    tempRect.size.width = recipeInfo.frame.size.width -20;
    tempRect.size.height = 48;
    lblStuffDetail.frame = tempRect;
    
    tempRect.origin.x = 0;
    tempRect.origin.y = lineView_2.frame.origin.y + 90;
    tempRect.size.width = recipeInfo.frame.size.width;
    tempRect.size.height = 1;
    lineView_3.frame = tempRect;
    
    tempRect.origin.x = 10;
    tempRect.origin.y = lineView_3.frame.origin.y + 11;
    tempRect.size.width = 24;
    tempRect.size.height = 24;
    ivRecipe.frame = tempRect;
    
    tempRect.origin.x = 44;
    tempRect.size.width = 50;
    tempRect.size.height = 24;
    lblRecipe.frame = tempRect;
    
    tempRect.origin.x = 5;
    tempRect.origin.y = ivRecipe.frame.origin.y + ivRecipe.frame.size.height + 10;
    tempRect.size.width = recipeInfo.frame.size.width - 10;
    tempRect.size.height = recipeContent.contentSize.height;
    recipeContent.frame = tempRect;
    
    tempRect = recipeInfo.frame;
    tempRect.size.height += recipeContent.contentSize.height-45;
    recipeInfo.frame = tempRect;
    
    [self setContentSize:CGSizeMake(self.frame.size.width,recipeInfo.frame.size.height + 60)];
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
//    NSLog(@"%d %d",imagePageControl.currentPage,imagePageControl.numberOfPages);
}

- (NSString *)splitEnter:(NSString*)string
{
    NSRange range;
    range = [string rangeOfString:@"서]"];
    if( range.length )
        string = [string substringFromIndex:range.location+range.length];
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
    CGRect tempRect;
    tempRect = [CommonUI getRectFromDic:rectDic withKey:@"imageScrollView"];
    [bgView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, self.frame.size.width - tempRect.origin.x*2, self.frame.size.height * 0.8)];
    [recipeInfo setFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
    [noImageLabel setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, recipeInfo.frame.size.width - tempRect.origin.x*2, recipeInfo.frame.size.height * 0.8)];
    [imageScrollView setFrame:CGRectMake(tempRect.origin.x, tempRect.origin.y, recipeInfo.frame.size.width - tempRect.origin.x*2, recipeInfo.frame.size.height * 0.8)];
    for( UIImageView *tempSubImageView in imageArr )
        [tempSubImageView removeFromSuperview];
    [imageArr removeAllObjects];
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
                UIImageView *tempAsyncImageview = [[UIImageView alloc] init];
                [tempAsyncImageview setImageWithURL:[NSURL URLWithString:attachItem.thumb_url]];
                [imageScrollView addSubview:tempAsyncImageview];
                [imageArr addObject:tempAsyncImageview];
                [tempAsyncImageview setFrame:CGRectMake((imageScrollView.frame.size.width)*i, 0, imageScrollView.frame.size.width,resizeHeight+40)];
            }else{
                AttatchMent *attachItem = [sortArray objectAtIndex:i];
                if( ![[attachItem.thumb_url lastPathComponent] hasPrefix:@"thumbnail"] )
                    continue;
                CGFloat resizeHeight = ((imageScrollView.frame.size.width-40) / (float)[attachItem.width integerValue] ) * (float)([attachItem.height intValue]);
                UIImageView *tempAsyncImageview = [[UIImageView alloc] init];
                [tempAsyncImageview setImageWithURL:[NSURL URLWithString:attachItem.thumb_url]];
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
    if( [infoTextArr count] > 5 ){
        NSString *stuffString = [infoTextArr objectAtIndex:5];
        lblStuffDetail.text = [stuffString stringByReplacingOccurrencesOfString:@"$" withString:@", "];
        [lblStuffDetail sizeToFit];
    }

    recipeContent.text = [self splitEnter:tempPost.content];
    imagePageControl.currentPage    = 0;
    imagePageControl.numberOfPages  = [imageArr count];
    [imageScrollView setContentOffset:CGPointMake(imagePageControl.currentPage*imageScrollView.frame.size.width, 0) animated:YES];
    [self setLayout];
}

@end
