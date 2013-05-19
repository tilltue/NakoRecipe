//
//  HttpApi.h
//  NakoRecipe
//
//  Created by nako on 5/16/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestResult : NSObject
@property (nonatomic, retain) NSString *retString;
@property (nonatomic, retain) NSString *errorDomain;
@end


@interface HttpApi : NSObject
+ (HttpApi *)getInstance;
- (NSString *)getRecipe;
@end
