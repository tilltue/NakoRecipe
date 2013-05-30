//
//  RecipeCommentView.h
//  NakoRecipe
//
//  Created by nako on 5/30/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeCommentView : UIView <UIWebViewDelegate>
{
    NSString    *currentPostId;
    UIWebView   *commentWebView;
}
@end
