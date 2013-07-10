//
//  CommonUI.m
//  eBookMall
//
//  Created by nako on 1/2/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import "CommonUI.h"
#import <QuartzCore/QuartzCore.h>

@implementation CommonUI

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

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

+ (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize withImage:(UIImage *)srcImage
{
    
    UIImage *sourceImage = srcImage;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}
@end
