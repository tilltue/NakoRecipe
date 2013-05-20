//
//  AsyncImageView.h
//  eBookMall
//
//  Created by nako on 4/16/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIImageView
{
    NSURLConnection* connection;
    NSMutableData* data;
    NSString *loadURL;
    BOOL isLoadComplete;
    CGFloat resizeWidth;
}
- (void)loadImageFromURL:(NSString *)url withResizeWidth:(CGFloat)width;
@end
