//
//  RecipePinterest.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipePinterest.h"
#import "HttpApi.h"
#import "FileControl.h"
#import <QuartzCore/QuartzCore.h>

@implementation RecipePinterest

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
        psCollectionView.numColsPortrait = 2;
        psCollectionView.numColsLandscape = 2;
        [self  addSubview:psCollectionView];
        
        thumbUrlArr = [[NSMutableArray alloc] initWithObjects:
                       @"http://cfile237.uf.daum.net/image/266997465194682013C85F",
                       @"http://cfile230.uf.daum.net/image/236B8B46519468200F808A",
                       @"http://cfile205.uf.daum.net/image/016D374251946E201E2966",
                       @"http://cfile212.uf.daum.net/image/017080465194682002273B",
                       @"http://cfile226.uf.daum.net/image/276A994251946E2024A708",
                       @"http://cfile233.uf.daum.net/image/24659546519468201AE275",
                       @"http://cfile212.uf.daum.net/image/236B704651946820106289",
                       @"http://cfile215.uf.daum.net/image/2170B3465194682101DE66",
                       @"http://cfile228.uf.daum.net/image/23691D4651946821141F4B",
                       @"http://cfile233.uf.daum.net/image/276E754251946E2017542A",
                       @"http://cfile211.uf.daum.net/image/226E7C46519468210767DA",
                       @"http://cfile229.uf.daum.net/image/22632A465194682120E6A4",
                       nil];
        NSLog(@"%@",[[HttpApi getInstance] getRecipe]);
    }
    return self;
}

- (void)makeLayout
{
    [rectDic setObject:@"{{0,0},{0,0}}" forKey:@"psCollectionView"];
}


- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [PSCollectionViewCell class];
}

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView {
    return 10;
}

#define PHONE_TWO_CELL_WIDTH 148
#define PHONE_TWO_THUMB_WIDTH 140
#define HEART_AND_COMMENT_ICONWIDTH 15
#define THUMB_INFO_HEIGHT 40
#define DETAIL_INFO_HEIGHT 40
#define USER_THUMB_ICONWIDTH 25

- (UIView *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    CGFloat thumbMargin = (PHONE_TWO_CELL_WIDTH - PHONE_TWO_THUMB_WIDTH)/2;
    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    
    NSString *thumbUrl = [thumbUrlArr objectAtIndex:index];
    UIImageView *tempImageView = [[UIImageView alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbUrl]];
    UIImage *tempImage = [[UIImage alloc] initWithData:data];
    CGFloat resizeHeight = (PHONE_TWO_THUMB_WIDTH / tempImage.size.width ) * tempImage.size.height;
    [tempImageView setImage:tempImage];
    [tempView addSubview:tempImageView];
    [tempView setFrame:CGRectMake(0, 0, PHONE_TWO_CELL_WIDTH, resizeHeight+THUMB_INFO_HEIGHT+DETAIL_INFO_HEIGHT)];
    [tempImageView setFrame:CGRectMake(thumbMargin, thumbMargin, PHONE_TWO_THUMB_WIDTH, resizeHeight)];
    
    UILabel *menuLabel = [[UILabel alloc] init];
    menuLabel.textColor = [UIColor blackColor];
    menuLabel.backgroundColor = [UIColor clearColor];
    menuLabel.text = @"레시피 제목";
    menuLabel.alpha = .8f;
    menuLabel.font = [UIFont systemFontOfSize:9];
    [menuLabel setFrame:CGRectMake(thumbMargin, resizeHeight+thumbMargin+5, PHONE_TWO_THUMB_WIDTH, 10)];
    [tempView addSubview:menuLabel];
    
    UIButton *tempButton = [[UIButton alloc] init];
    tempButton.alpha = .4f;
    [tempButton setImage:[UIImage imageNamed:@"Icons-h_black"] forState:UIControlStateNormal];
    [tempButton setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-HEART_AND_COMMENT_ICONWIDTH, resizeHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempButton];
    
    tempButton = [[UIButton alloc] init];
    tempButton.alpha = .4f;
    [tempButton setImage:[UIImage imageNamed:@"Icons-comments_black"] forState:UIControlStateNormal];
    [tempButton setFrame:CGRectMake(PHONE_TWO_CELL_WIDTH-thumbMargin-(HEART_AND_COMMENT_ICONWIDTH*2), resizeHeight+THUMB_INFO_HEIGHT-HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH, HEART_AND_COMMENT_ICONWIDTH)];
    [tempView addSubview:tempButton];
    
    UIView *tempView2 = [[UIView alloc] init];
    tempView2.backgroundColor = [CommonUI getUIColorFromHexString:@"#F2F3F7"];
    
    tempImageView = [[UIImageView alloc] init];
    data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://cfile222.uf.daum.net/image/2304F15051949F031E7836"]];
    tempImage = [[UIImage alloc] initWithData:data];
    [tempImageView setImage:tempImage];
    [tempView2 addSubview:tempImageView];
    [tempView2 setFrame:CGRectMake(0, resizeHeight+THUMB_INFO_HEIGHT, PHONE_TWO_CELL_WIDTH, DETAIL_INFO_HEIGHT)];
    [tempImageView setFrame:CGRectMake(thumbMargin, DETAIL_INFO_HEIGHT/2-USER_THUMB_ICONWIDTH/2, USER_THUMB_ICONWIDTH, USER_THUMB_ICONWIDTH)];
    [tempView addSubview:tempView2];
    return tempView;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    NSString *thumbUrl = [thumbUrlArr objectAtIndex:index];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbUrl]];
    UIImage *tempImage = [[UIImage alloc] initWithData:data];
    CGFloat resizeHeight = (PHONE_TWO_THUMB_WIDTH / tempImage.size.width ) * tempImage.size.height;
    return resizeHeight+THUMB_INFO_HEIGHT+DETAIL_INFO_HEIGHT;
}
@end
