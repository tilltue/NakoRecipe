//
//  RecipePinterest.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"

@interface RecipePinterest : UIView <PSCollectionViewDataSource,PSCollectionViewDelegate>
{
    NSMutableDictionary *rectDic;
    PSCollectionView *psCollectionView;
    NSMutableArray *thumbUrlArr;
}
@end
