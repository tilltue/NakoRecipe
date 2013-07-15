//
//  RecipeCommentView.m
//  NakoRecipe
//
//  Created by nako on 5/30/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "RecipeCommentView.h"

@implementation MyUITextField
@synthesize horizontalPadding, verticalPadding;
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + horizontalPadding, bounds.origin.y + verticalPadding, bounds.size.width - horizontalPadding*2, bounds.size.height - verticalPadding*2);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end

@implementation RecipeCommentView
@synthesize comment_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        btnLike = [[UIButton alloc] init];
        btnLike.backgroundColor = [UIColor clearColor];
        btnLike.tag = 2;
        [btnLike setImage:[UIImage imageNamed:@"btn_unlike"] forState:UIControlStateNormal];
        [btnLike setImage:[UIImage imageNamed:@"btn_like"]  forState:UIControlStateSelected];
        [self addSubview:btnLike];
        tfComment = [[MyUITextField alloc] init];
        tfComment.backgroundColor = [UIColor clearColor];
        tfComment.horizontalPadding = 5;
        tfComment.verticalPadding = 4;
        tfComment.layer.borderWidth = .5;
        tfComment.layer.borderColor = [UIColor grayColor].CGColor;
        tfComment.layer.cornerRadius = 5;
        tfComment.placeholder = @"댓글 쓰기";
        [self addSubview:tfComment];
        
        btnSend = [[UIButton alloc] init];
        [btnSend setImage:[UIImage imageNamed:@"btn_send"] forState:UIControlStateNormal];
        [self addSubview:btnSend];
        [self setLayout];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)setLayout
{
    CGRect tempRect;
    tempRect.origin.y = self.frame.size.height/2 - 12;
    tempRect.origin.x = tempRect.origin.y;
    tempRect.size.width = 24;
    tempRect.size.height = 24;
    btnLike.frame = tempRect;
    
    tempRect.origin.x = self.frame.size.width - 52;
    tempRect.origin.y = self.frame.size.height/2 - 15;
    tempRect.size.width = 42;
    tempRect.size.height = 30;
    btnSend.frame = tempRect;
    
    tempRect.origin.x = btnLike.frame.origin.x + btnLike.frame.size.width + 5;
    tempRect.origin.y = self.frame.size.height/2 - 15;
    tempRect.size.height = 30;
    tempRect.size.width = self.frame.size.width - btnLike.frame.size.width - btnSend.frame.size.width - 30;
    tfComment.frame = tempRect;
}

- (void)reset
{
    btnLike.selected = NO;
    tfComment.text = @"";
    [tfComment resignFirstResponder];
}

- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    CGRect frame = self.frame;
    if([notification name] == UIKeyboardWillShowNotification)
    {
        frame.origin.y -= keyboardBounds.size.height;
        self.frame = frame;
        [[self comment_delegate] keyBoardAnimated:notification];
    }
    else if([notification name] == UIKeyboardWillHideNotification)
    {
        frame.origin.y += keyboardBounds.size.height;
        self.frame = frame;
        [[self comment_delegate] keyBoardAnimated:notification];
    }
    [UIView commitAnimations];
}
@end
