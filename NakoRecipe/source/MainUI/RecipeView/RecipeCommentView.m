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
#import "CustomAlert.h"

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
        tfComment.delegate = self;
        [self addSubview:tfComment];
        
        btnSend = [[UIButton alloc] init];
        [btnSend setImage:[UIImage imageNamed:@"btn_send"] forState:UIControlStateNormal];
        [self addSubview:btnSend];
        [btnSend addTarget:self action:@selector(btnSend) forControlEvents:UIControlEventTouchUpInside];
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

- (void)btnSend
{
    if( [tfComment.text length] > 0 ){
        [[self comment_delegate] sendComment:tfComment.text];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://확인
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate openSession];
        }
            break;
        case 1://취소
            break;
        default:
            break;
    }
    if( buttonIndex == 0 ){
        
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if( ![appDelegate loginCheck] ){
        CustomAlert *alert = [[CustomAlert alloc]initWithTitle:@"" message:@"페이스북 계정으로 로그인 하시겠습니까?" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
        alert.delegate = self;
        [alert show];
    }
    return [appDelegate loginCheck];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if ([textField isEqual:tfComment]) {
		//일단 backspace이면 YES
		if (range.length==1) {
			return YES;
		}
		
		//새로 만들어지는 문자열
		NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
		if ([string length]>1) {
			return NO; //복사해서 붙여넣기는 금지한다.
		} else {
			if ([newString length]==1) { //첫번째  문자에	공백이 들어가면 안됨
				if ([@" " isEqualToString:string]) {
					return NO;
				}
			} else if([newString length]>2) { //2이상의 길이가 되었을때 space가 2개 이상되는 것은 금지시킨다.
				NSRange newRange = {range.location-1,2};
				if ([@"  " isEqualToString:[newString substringWithRange:newRange ]] ) {
					return NO;
				}
			}
		}
		return YES;
	}
	return YES;
}


@end
