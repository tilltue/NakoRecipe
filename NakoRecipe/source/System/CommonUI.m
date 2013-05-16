//
//  CommonUI.m
//  eBookMall
//
//  Created by nako on 1/2/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import "CommonUI.h"
#import <QuartzCore/QuartzCore.h>

#define FT_CALL_DELEGATE_WITH_ARG(_delegate, _selector, _argument) \
do { \
id _theDelegate = _delegate; \
if(_theDelegate != nil && [_theDelegate respondsToSelector:_selector]) { \
[_theDelegate performSelector:_selector withObject:_argument]; \
} \
} while(0);

@implementation CommonUI

+(UIColor *)getUIColorFromHexString:(NSString *)hexString
{
    NSString *str = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([str length] < 6)  // 일단 6자 이하면 말이 안되니까 검은색을 리턴해주자.
        return [UIColor blackColor];
    // 0x로 시작하면 0x를 지워준다.
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    // #으로 시작해도 #을 지워준다.
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6) //그랫는데도 6자 이하면 이것도 이상하니 그냥 검은색을 리턴해주자.
        return [UIColor blackColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rcolorString = [str substringWithRange:range];
    range.location = 2;
    NSString *gcolorString = [str substringWithRange:range];
    range.location = 4;
    NSString *bcolorString = [str substringWithRange:range];
    unsigned int red, green, blue;
    [[NSScanner scannerWithString: rcolorString] scanHexInt:&red];
    [[NSScanner scannerWithString: gcolorString] scanHexInt:&green];
    [[NSScanner scannerWithString: bcolorString] scanHexInt:&blue];
    
    return [UIColor colorWithRed:((float) red / 255.0f) green:((float) green / 255.0f) blue:((float) blue / 255.0f) alpha:1.0f];
}

+ (CGRect)getRectFromDic:(NSMutableDictionary *)rectDic withKey:(NSString *)key
{
    CGRect retRect = CGRectZero;
    //NSLog(@"%@",[rectDic objectForKey:[NSString stringWithFormat:@"%d",e_numVal]]);
    if( [rectDic objectForKey:key] != nil )
        retRect = CGRectFromString([rectDic objectForKey:key]);
    return retRect;
}

+ (UIButton *)createTempButtonWithBgImage:(UIImage *)bgImage pressImage:(UIImage *)pressBgImage selectedImage:(UIImage *)selectedBgImage
{
    UIButton *tempButton = [[UIButton alloc] init];
    [tempButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    [tempButton setBackgroundImage:pressBgImage forState:UIControlStateHighlighted];
    [tempButton setBackgroundImage:selectedBgImage forState:UIControlStateSelected];
    return tempButton;
}

+ (UIImage *)ImageResize:(UIImage * )image withSize:(CGSize)size
{
    if( image == nil )
        return nil;
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage*scaledImage = nil;
    scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

/*
 + (UIImage *)scaledToSizeImage:(UIImage *)image
 {
 if( [SystemInfo isPad])
 return image;
 CGSize tempSize = image.size;
 if( [[UIScreen mainScreen] scale] == 2.0 ){
 tempSize = CGSizeMake(tempSize.width/2, tempSize.height/2);
 }else{
 tempSize = CGSizeMake(tempSize.width/2, tempSize.height/2);
 }
 UIGraphicsBeginImageContext(tempSize);
 [image drawInRect:CGRectMake(0, 0, tempSize.width, tempSize.height)];
 UIImage *im = nil;
 im = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return im;
 }
 
 + (UIImage *)imageFileOpen:(NSString *)filename withContId:(NSString *)contId
 {
 NSString *imagePath = [NSString stringWithFormat:@"%@/%@/%@",[FileControl getBooksDirectory],contId,filename];
 
 UIImage *tempImage = nil;
 tempImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
 //[Nako]혹시라도 파일이 없을 경우를 대비해야 할것.
 return tempImage;
 }
 
 + (UIImage *)makeShadowImage:(UIColor *)color withSize:(CGSize)dstSize
 {
 UIGraphicsBeginImageContext(dstSize);
 CGContextRef context = UIGraphicsGetCurrentContext();
 CGContextSetFillColor(context, [color CGColor]);
 CGContextFillRect(context, CGRectMake(0, 0, dstSize.width, dstSize.height));
 UIImage *im = nil;
 im = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return im;
 }
 
 
 */

+ (UIImage *)addLabelToImage:(UIImage *)bgImage inLabel:(UILabel *)inLabel withInRect:(CGRect)dstRect
{
    UIGraphicsBeginImageContext(bgImage.size);
    [bgImage drawAtPoint: CGPointZero];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), inLabel.textColor.CGColor);
    [inLabel.text drawAtPoint: CGPointMake(dstRect.origin.x,dstRect.origin.y) withFont:inLabel.font];
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return im;
}

+ (BOOL)imageSizeValid:(CGSize)size
{
    if( size.width == 0 || size.height == 0 )
        return FALSE;
    return YES;
}

+ (UIImage *)makeRetinaImageDotFill:(UIImage *)dotImage withSize:(CGSize)dstSize
{
    CGSize dsz = CGSizeMake(dotImage.size.width*2, dotImage.size.height*2);
    
    if( ![self imageSizeValid:dsz] )
        return nil;
    
    CGImageRef dotRef   = CGImageCreateWithImageInRect([dotImage CGImage],
                                                       CGRectMake(0, 0, dsz.width, dsz.height));
    UIGraphicsBeginImageContext(CGSizeMake(dsz.width, dsz.height));
    for( float i = 0; i < dstSize.height; i+=dsz.height)
    {
        for( float j = 0; j < dstSize.width; j+= dstSize.width )
        {
            [[UIImage imageWithCGImage:dotRef] drawAtPoint:CGPointMake(j, i)];
        }
    }
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(dotRef);
    
    return im;
}

+ (UIImage *)makeTwoPartImage:(UIImage *)bgImage inImage:(UIImage *)inImage withInRect:(CGRect)dstRect
{
    CGSize bgsz = [bgImage size];
    CGSize isz = [inImage size];
    
    if( ![self imageSizeValid:bgsz] && ![self imageSizeValid:bgsz] )
        return nil;
    
    CGImageRef marsBg   = CGImageCreateWithImageInRect([bgImage CGImage],
                                                       CGRectMake(0, 0, bgsz.width, bgsz.height));
    CGImageRef marsIn = CGImageCreateWithImageInRect([inImage CGImage],
                                                     CGRectMake(0, 0, isz.width, isz.height));
    UIGraphicsBeginImageContext(CGSizeMake(bgsz.width, bgsz.height));
    
    [[UIImage imageWithCGImage:marsBg] drawAtPoint:CGPointMake(0, 0)];
    [[UIImage imageWithCGImage:marsIn] drawAtPoint:CGPointMake(dstRect.origin.x, dstRect.origin.y)];
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(marsIn); CGImageRelease(marsBg);
    
    return im;
}

+ (UIImage *)makeRetinaTwoPartImage:(UIImage *)bgImage inImage:(UIImage *)inImage withInRect:(CGRect)dstRect
{
    CGSize bgsz = [bgImage size];
    CGSize isz = CGSizeMake(inImage.size.width*2, inImage.size.height*2);
    
    if( ![self imageSizeValid:bgsz] && ![self imageSizeValid:bgsz] )
        return nil;
    
    CGImageRef marsBg   = CGImageCreateWithImageInRect([bgImage CGImage],
                                                       CGRectMake(0, 0, bgsz.width, bgsz.height));
    CGImageRef marsIn = CGImageCreateWithImageInRect([inImage CGImage],
                                                     CGRectMake(0, 0, isz.width, isz.height));
    UIGraphicsBeginImageContext(CGSizeMake(bgsz.width, bgsz.height));
    
    [[UIImage imageWithCGImage:marsBg] drawAtPoint:CGPointMake(0, 0)];
    [[UIImage imageWithCGImage:marsIn] drawAtPoint:CGPointMake(dstRect.origin.x, dstRect.origin.y)];
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(marsIn); CGImageRelease(marsBg);
    
    return im;
}

+ (UIImage *)makeRetinaTwoPartImage:(UIImage *)bgImage inRetinaImage:(UIImage *)inImage withInRect:(CGRect)dstRect
{
    CGSize bgsz = CGSizeMake(bgImage.size.width*2, bgImage.size.height*2);
    CGSize isz = CGSizeMake(inImage.size.width*2, inImage.size.height*2);
    
    if( ![self imageSizeValid:bgsz] && ![self imageSizeValid:bgsz] )
        return nil;
    
    CGImageRef marsBg   = CGImageCreateWithImageInRect([bgImage CGImage],
                                                       CGRectMake(0, 0, bgsz.width, bgsz.height));
    CGImageRef marsIn = CGImageCreateWithImageInRect([inImage CGImage],
                                                     CGRectMake(0, 0, isz.width, isz.height));
    UIGraphicsBeginImageContext(CGSizeMake(bgsz.width, bgsz.height));
    
    [[UIImage imageWithCGImage:marsBg] drawAtPoint:CGPointMake(0, 0)];
    [[UIImage imageWithCGImage:marsIn] drawAtPoint:CGPointMake(dstRect.origin.x, dstRect.origin.y)];
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(marsIn); CGImageRelease(marsBg);
    
    return im;
}

+ (UIImage *)makeThreePartImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage centerImage:(UIImage *)centerImage withSize:(CGSize)dstRect
{
    CGSize lsz = [leftImage size];
    CGSize rsz = [rightImage size];
    CGSize fsz = [centerImage size];
    
    CGImageRef marsLeft = CGImageCreateWithImageInRect([leftImage CGImage],
                                                       CGRectMake(0, 0, lsz.width, lsz.height));
    CGImageRef marsFill = CGImageCreateWithImageInRect([centerImage CGImage],
                                                       CGRectMake(0, 0, fsz.width, fsz.height));
    CGImageRef marsRight = CGImageCreateWithImageInRect([rightImage CGImage],
                                                        CGRectMake(0, 0, rsz.width, rsz.height));
    UIGraphicsBeginImageContext(CGSizeMake(dstRect.width, dstRect.height));
    
    [[UIImage imageWithCGImage:marsLeft] drawAtPoint:CGPointMake(0, 0)];
    float i = 0;
    for( i = lsz.width; i < (dstRect.width - rsz.width); i+=fsz.width)
    {
        [[UIImage imageWithCGImage:marsFill] drawAtPoint:CGPointMake(i, 0)];
    }
    [[UIImage imageWithCGImage:marsRight] drawAtPoint:CGPointMake(i, 0)];
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(marsLeft); CGImageRelease(marsRight);
    
    return im;
}

+ (UIImage *)makeRetinaThreePartImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage centerImage:(UIImage *)centerImage withSize:(CGSize)dstRect
{
    CGSize lsz = CGSizeMake(leftImage.size.width*2, leftImage.size.height*2);
    CGSize rsz = CGSizeMake(rightImage.size.width*2, rightImage.size.height*2);
    CGSize fsz = CGSizeMake(centerImage.size.width*2, centerImage.size.height*2);
    
    CGImageRef marsLeft = CGImageCreateWithImageInRect([leftImage CGImage],
                                                       CGRectMake(0, 0, lsz.width, lsz.height));
    CGImageRef marsFill = CGImageCreateWithImageInRect([centerImage CGImage],
                                                       CGRectMake(0, 0, fsz.width, fsz.height));
    CGImageRef marsRight = CGImageCreateWithImageInRect([rightImage CGImage],
                                                        CGRectMake(0, 0, rsz.width, rsz.height));
    UIGraphicsBeginImageContext(CGSizeMake(dstRect.width, dstRect.height));
    
    [[UIImage imageWithCGImage:marsLeft] drawAtPoint:CGPointMake(0, 0)];
    float i = 0;
    for( i = lsz.width; i < (dstRect.width - rsz.width); i+=fsz.width)
    {
        [[UIImage imageWithCGImage:marsFill] drawAtPoint:CGPointMake(i, 0)];
    }
    [[UIImage imageWithCGImage:marsRight] drawAtPoint:CGPointMake(i, 0)];
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(marsLeft); CGImageRelease(marsRight);
    
    return im;
}

+ (UIImage *)makeRetinaImageByHeight:(UIImage *)stackImage withSize:(CGSize)dstSize
{
    CGSize ssz = CGSizeMake(stackImage.size.width*2, stackImage.size.height*2);
    
    CGImageRef stackRef = CGImageCreateWithImageInRect([stackImage CGImage],
                                                       CGRectMake(0, 0, ssz.width, ssz.height));
    UIGraphicsBeginImageContext(CGSizeMake(dstSize.width, dstSize.height));
    
    float i = 0;
    for( i = 0; i < dstSize.height; i+=(ssz.height/2))
    {
        [[UIImage imageWithCGImage:stackRef] drawAtPoint:CGPointMake(0, i)];
    }
    
    UIImage *im = nil;
    im = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(stackRef);
    
    return im;
}

+(UIImage *) loadImage:(NSString *)fileName inDirectory:(NSString *)directoryPath
{
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", directoryPath, fileName]];
    return result;
}

#pragma mark - animation effect

+ (void)animationDidStart:(CAAnimation *)theAnimation {
    UIView *targetView = [theAnimation valueForKey:@"animationTargetViewKey"];
    [theAnimation setValue:[NSNumber numberWithBool:targetView.userInteractionEnabled] forKey:@"animationWasInteractionEnabledKey"];
    [targetView setUserInteractionEnabled:NO];
    
    if([[theAnimation valueForKey:@"animationType"] isEqualToString:@"animationTypeIn"]) {
        [targetView setHidden:NO];
    }
    
    //Check for chaining and forward the delegate call if necessary
    NSObject *callerDelegate = [theAnimation valueForKey:@"animationCallerDelegateKey"];
    SEL startSelector = NSSelectorFromString([theAnimation valueForKey:@"animationCallerStartSelectorKey"]);
    
    FT_CALL_DELEGATE_WITH_ARG(callerDelegate, startSelector, theAnimation)
}

+ (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished {
    UIView *targetView = [theAnimation valueForKey:@"animationTargetViewKey"];
    BOOL wasInteractionEnabled = [[theAnimation valueForKey:@"animationWasInteractionEnabledKey"] boolValue];
    [targetView setUserInteractionEnabled:wasInteractionEnabled];
    
    if([[theAnimation valueForKey:@"animationType"] isEqualToString:@"animationTypeOut"]) {
        [targetView setHidden:YES];
    }
    [targetView.layer removeAnimationForKey:[theAnimation valueForKey:@"animationName"]];
    
    //Forward the delegate call
    id callerDelegate = [theAnimation valueForKey:@"animationCallerDelegateKey"];
    
    if([theAnimation valueForKey:@"animationIsChainedKey"]) {
        CAAnimation *next = [theAnimation valueForKey:@"animationNextAnimationKey"];
        if(next) {
            //Add the next animation to its layer
            UIView *nextTarget = [next valueForKey:@"animationTargetViewKey"];
            [nextTarget.layer addAnimation:next forKey:[next valueForKey:@"animationName"]];
        }
    }
    
    [callerDelegate animationDidStop:theAnimation finished:finished];
}


+ (CAAnimationGroup *)animationGroupFor:(NSArray *)animations withView:(UIView *)view
                               duration:(NSTimeInterval)duration delegate:(id)delegate
                          startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector
                                   name:(NSString *)name type:(NSString *)type {
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = [NSArray arrayWithArray:animations];
    group.delegate = self;
    group.duration = duration;
    group.removedOnCompletion = NO;
    if([type isEqualToString:@"animaitionTypeOut"]) {
        group.fillMode = kCAFillModeBoth;
    }
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setValue:view forKey:@"animationTargetViewKey"];
    [group setValue:delegate forKey:@"animationCallerDelegateKey"];
    if(!startSelector) {
        startSelector = @selector(animationDidStart:);
    }
    [group setValue:NSStringFromSelector(startSelector) forKey:@"animationCallerStartSelectorKey"];
    if(!stopSelector) {
        stopSelector = @selector(animationDidStop:finished:);
    }
    [group setValue:NSStringFromSelector(stopSelector) forKey:@"animationCallerStopSelectorKey"];
    [group setValue:name forKey:@"animationName"];
    [group setValue:type forKey:@"animationType"];
    return group;
}

+ (CAAnimation *)popInAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate
                     startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = duration;
    scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5f],
                    [NSNumber numberWithFloat:1.2f],
                    [NSNumber numberWithFloat:.85f],
                    [NSNumber numberWithFloat:1.f],
                    nil];
    
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = duration * .4f;
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeIn.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [self animationGroupFor:[NSArray arrayWithObjects:scale, fadeIn, nil] withView:view duration:duration
                                             delegate:delegate startSelector:startSelector stopSelector:stopSelector
                                                 name:@"animationPopIn" type:@"animaitionTypeIn"];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return group;
}

+ (CAAnimation *)popOutAnimationFor:(UIView *)view duration:(NSTimeInterval)duration delegate:(id)delegate
                      startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector {
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = duration;
    scale.removedOnCompletion = NO;
    scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.f],
                    [NSNumber numberWithFloat:1.2f],
                    [NSNumber numberWithFloat:.75f],
                    nil];
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.duration = duration * .4f;
    fadeOut.fromValue = [NSNumber numberWithFloat:1.f];
    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeOut.beginTime = duration * .6f;
    fadeOut.fillMode = kCAFillModeBoth;
    
    return [self animationGroupFor:[NSArray arrayWithObjects:scale, fadeOut, nil] withView:view duration:duration
                          delegate:delegate startSelector:startSelector stopSelector:stopSelector
                              name:@"animationPopOut" type:@"animaitionTypeOut"];
}

+ (void)popIn:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector withView:(UIView *)view
{
    CAAnimation *anim = [self popInAnimationFor:view duration:duration delegate:delegate
                                  startSelector:startSelector stopSelector:stopSelector];
    [view.layer addAnimation:anim forKey:@"animationPopIn"];
}

+ (void)popIn:(NSTimeInterval)duration delegate:(id)delegate withView:(UIView *)view
{
    [self popIn:duration delegate:delegate startSelector:nil stopSelector:nil withView:view];
}

+ (void)popOut:(NSTimeInterval)duration delegate:(id)delegate startSelector:(SEL)startSelector stopSelector:(SEL)stopSelector withView:(UIView *)view
{
    CAAnimation *anim = [self popOutAnimationFor:view duration:duration delegate:delegate
                                   startSelector:startSelector stopSelector:stopSelector];
    [view.layer addAnimation:anim forKey:@"animationPopOut"];
}

+ (void)popOut:(NSTimeInterval)duration delegate:(id)delegate withView:(UIView *)view
{
    [self popOut:duration delegate:delegate startSelector:nil stopSelector:nil withView:view];
}

@end
