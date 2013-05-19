//
//  AttatchMent.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AttatchMent : NSManagedObject

@property (nonatomic, retain) NSString * thumb_url;
@property (nonatomic, retain) NSString * post_id;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;

@end
