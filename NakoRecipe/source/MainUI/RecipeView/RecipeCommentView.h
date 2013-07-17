//
//  RecipeCommentView.h
//  NakoRecipe
//
//  Created by nako on 5/30/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecipeCommentDelegate <NSObject>
- (void)sendComment:(NSString *)comment;
- (void)keyBoardAnimated:(NSNotification *)notification;
@end

@interface MyUITextField : UITextField
@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;
@end

@interface RecipeCommentView : UIView <UITextFieldDelegate,UIAlertViewDelegate>
{
    UIButton *btnClose;
    UIButton *btnLike;
    MyUITextField *tfComment;
    UIButton *btnSend;
}
@property (nonatomic, unsafe_unretained) id <RecipeCommentDelegate> comment_delegate;
- (void)reset;
- (void)sendComplete:(BOOL)state;
@end
