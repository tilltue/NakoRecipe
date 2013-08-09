//
//  PinterestViewController.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipePinterest.h"
#import "RecipeViewController.h"
#import "HttpAsyncApi.h"
#import "GADBannerView.h"
#import "AlignPopView.h"

@interface PinterestViewController : UIViewController <RecipePinterestDelegate,RequestObserver,AlignPopViewDelegate>
{
    RecipePinterest *recipePinterest;
    RecipeViewController *recipeViewController;
    GADBannerView *bannerView;
    AlignPopView *popView;
}
@property BOOL loginState;
- (void)loginComplete:(BOOL)state;
@end
