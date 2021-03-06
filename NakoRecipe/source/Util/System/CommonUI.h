//
//  CommonUI.h
//  eBookMall
//
//  Created by nako on 1/2/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUI : NSObject
+ (UIImage *)makeShadowImage:(UIColor *)color withSize:(CGSize)dstSize;
+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees;
+ (UIColor *)getUIColorFromHexString:(NSString *)hexString;
+ (CGRect)getRectFromDic:(NSMutableDictionary *)rectDic withKey:(NSString *)key;
+ (UIButton *)createTempButtonWithBgImage:(UIImage *)bgImage pressImage:(UIImage *)pressBgImage selectedImage:(UIImage *)selectedBgImage;
+ (UIImage *)ImageResize:(UIImage * )image withSize:(CGSize)size;
+ (UIImage *)addLabelToImage:(UIImage *)bgImage inLabel:(UILabel *)inLabel withInRect:(CGRect)dstRect;
+ (UIImage *)makeTwoPartImage:(UIImage *)bgImage inImage:(UIImage *)inImage withInRect:(CGRect)dstRect;
+ (UIImage *)makeRetinaImageDotFill:(UIImage *)dotImage withSize:(CGSize)dstSize;
+ (UIImage *)makeRetinaTwoPartImage:(UIImage *)bgImage inRetinaImage:(UIImage *)inImage withInRect:(CGRect)dstRect;
+ (UIImage *)makeRetinaTwoPartImage:(UIImage *)bgImage inImage:(UIImage *)inImage withInRect:(CGRect)dstRect;
+ (UIImage *)makeThreePartImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage centerImage:(UIImage *)centerImage withSize:(CGSize)dstRect;
+ (UIImage *)makeRetinaThreePartImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage centerImage:(UIImage *)centerImage withSize:(CGSize)dstRect;
+ (UIImage *)makeRetinaImageByHeight:(UIImage *)stackImage withSize:(CGSize)dstSize;
+ (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize withImage:(UIImage *)srcImage;
@end
