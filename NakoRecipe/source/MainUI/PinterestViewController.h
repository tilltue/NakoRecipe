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

@interface PinterestViewController : UIViewController <RecipePinterestDelegate,RequestObserver>
{
    RecipePinterest *recipePinterest;
    RecipeViewController *recipeViewController;
    GADBannerView *bannerView;
    UIView *popView;
    __strong UIActivityIndicatorView *_activityIndicatorView;
}
@end
