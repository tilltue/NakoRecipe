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

@interface PinterestViewController : UIViewController <RecipePinterestDelegate>
{
    RecipePinterest *recipePinterest;
    RecipeViewController *recipeViewController;
}
@end
