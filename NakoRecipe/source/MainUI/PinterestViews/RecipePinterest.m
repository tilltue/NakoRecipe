//
//  RecipePinterest.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipePinterest.h"

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
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    tempView.backgroundColor = [UIColor grayColor];
    return tempView;
    return nil;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index {
    return 50.0f;
}
@end
