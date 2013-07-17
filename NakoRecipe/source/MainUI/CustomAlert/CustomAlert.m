//
//  CustomAlert.m
//  NakoRecipe
//
//  Created by nako on 7/16/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "CustomAlert.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)show
{
    [super show];
    for (UIView* view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {  // SubView가 UIImageView이면 -> 바탕
            UIImage *bg = [[UIImage alloc] init];
            ((UIImageView*)view).image = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(50,10,10,10)];
            view.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
            view.layer.cornerRadius = 5;
            if( [SystemInfo shadowOptionModel]){
                view.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
                view.layer.shadowRadius = 2;
                view.layer.shadowOpacity = 0.2;
            }
        }
        else if ([view isKindOfClass:[UIButton class]]) { // Button type 이면
            [(UIButton*)view setBackgroundImage:nil forState:UIControlStateNormal];
            [(UIButton*)view setBackgroundColor:[UIColor grayColor]];
            view.layer.cornerRadius = 5;
            if( [SystemInfo shadowOptionModel]){
                view.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
                view.layer.shadowRadius = 2;
                view.layer.shadowOpacity = 0.2;
            }
        }
        else if ([view isKindOfClass:[UILabel class]]) {  // UILabel이면.
            UILabel *label = (UILabel*)view; //Cast From UIView to UILabel
            label.textColor = [UIColor grayColor];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0.0f, 0.0f);
        }
    }
    
}

@end
