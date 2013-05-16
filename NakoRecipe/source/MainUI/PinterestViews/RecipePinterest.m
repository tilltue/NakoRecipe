//
//  RecipePinterest.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipePinterest.h"
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

- (UIView *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    UIView *tempView = [[UIView alloc] init];
    tempView.backgroundColor = [UIColor whiteColor];
    
    NSString *thumbUrl = [thumbUrlArr objectAtIndex:index];
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    tempImageView.layer.borderWidth = 1.0f;
    tempImageView.alpha = .7f;
    tempImageView.backgroundColor = [UIColor blackColor];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbUrl]];
    UIImage *tempImage = [[UIImage alloc] initWithData:data];
    CGFloat resizeHeight = (150 / tempImage.size.width ) * tempImage.size.height;
    [tempImageView setImage:tempImage];
    [tempView addSubview:tempImageView];
    [tempView setFrame:CGRectMake(0, 0, 150, resizeHeight)];
    [tempImageView setFrame:CGRectMake(0, 0, 150, resizeHeight)];
    
    UILabel *menuLabel = [[UILabel alloc] init];
    menuLabel.textColor = [UIColor whiteColor];
    menuLabel.backgroundColor = [UIColor clearColor];
    menuLabel.text = @"레시피 제목";
    menuLabel.font = [UIFont systemFontOfSize:14];
    menuLabel.shadowColor = [UIColor grayColor];
    menuLabel.shadowOffset = CGSizeMake(0.8,0.8);
    [menuLabel setFrame:CGRectMake(5, 5, 100, 15)];
    [tempView addSubview:menuLabel];
    
    UIButton *tempButton = [[UIButton alloc] init];
    [tempButton setImage:[UIImage imageNamed:@"Icons-h"] forState:UIControlStateNormal];
    [tempButton setFrame:CGRectMake(150-15, resizeHeight - 15, 10, 10)];
    [tempView addSubview:tempButton];
    
    tempButton = [[UIButton alloc] init];
    [tempButton setImage:[UIImage imageNamed:@"Icons-comments"] forState:UIControlStateNormal];
    [tempButton setFrame:CGRectMake(150-30, resizeHeight - 15, 10, 10)];
    [tempView addSubview:tempButton];
    
    return tempView;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    NSString *thumbUrl = [thumbUrlArr objectAtIndex:index];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbUrl]];
    UIImage *tempImage = [[UIImage alloc] initWithData:data];
    CGFloat resizeHeight = (150 / tempImage.size.width ) * tempImage.size.height;
    return resizeHeight;
}
@end
