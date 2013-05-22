//
//  Post.h
//  NakoRecipe
//
//  Created by nako on 5/22/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AttatchMent;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * comment_count;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * like_count;
@property (nonatomic, retain) NSString * post_id;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * creator_url;
@property (nonatomic, retain) NSSet *attatchments;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addAttatchmentsObject:(AttatchMent *)value;
- (void)removeAttatchmentsObject:(AttatchMent *)value;
- (void)addAttatchments:(NSSet *)values;
- (void)removeAttatchments:(NSSet *)values;

@end
