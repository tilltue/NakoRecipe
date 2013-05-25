//
//  CoreDataManager.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "CoreDataManager.h"
#import "SBJson.h"

@implementation CoreDataManager

- (id)init
{
    self = [ super init ];
    
    if( self != nil )
    {
        ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

#pragma mark - Singleton Methods
+ (CoreDataManager *)getInstance
{
    static dispatch_once_t onceToken;
    static CoreDataManager * singletonInstance   = nil;;
    
    dispatch_once( &onceToken,
                  ^{
                      if( singletonInstance == nil )
                      {
                          singletonInstance = [ [ CoreDataManager alloc ] init ];
                      }
                  });
    
    return singletonInstance;
}

- (void)saveContext
{
    [ad saveContext];
}

- (NSArray *)getFetchResults:(NSString *)entityName withKey:(NSString *)keyAttributeName filter:(NSPredicate *)predicate
{
    NSError *fetchError = nil;
    BOOL isAscending = NO;
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (predicate != nil)
        [fetchRequest setPredicate:predicate];
    
    isAscending = YES;
    
    if (keyAttributeName != nil)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyAttributeName ascending:isAscending];
        
        NSArray *oSortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:oSortDescriptors];
    }
    
    NSArray * result = [ad.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (!result) [NSException raise:@"Fetch failed" format:@"Reason: %@", [fetchError localizedDescription]];
    return result;
}


- (NSFetchedResultsController *)getFetchedResultsController:(NSString *)entityName withKey:(NSString *)keyAttributeName filter:(NSPredicate *)predicate
{
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:ad.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (predicate != nil)
        [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:keyAttributeName ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    NSFetchedResultsController *tempFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                   managedObjectContext:ad.managedObjectContext
                                                                                                     sectionNameKeyPath:nil
                                                                                                              cacheName:nil];
	return tempFetchedResultsController;
}

- (BOOL)validatePostId:(NSString *)postId
{
    if( postId == nil )
        return NO;
    NSPredicate *_predicate;
    _predicate = [NSPredicate predicateWithFormat:@"post_id == %@",postId];
    NSArray *fetchedResults = [self getFetchResults:@"Post" withKey:@"post_id" filter:_predicate];
    if( [fetchedResults count] > 0 )
        return NO;
    return YES;
}

- (NSArray *)getPosts
{
    NSArray *fetchedResults = [self getFetchResults:@"Post" withKey:@"post_id" filter:nil];
    if( [fetchedResults count] > 0 ){
        NSMutableArray *sortArray = [[NSMutableArray alloc] initWithArray:fetchedResults];
        [sortArray sortUsingFunction:intSortPostId context:nil];
        return sortArray;
    }
    return nil;
}

- (void)makePostFromBundle
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultJSON" ofType:@"htm"];
    NSData *bundleJSONData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary* dict = [[[SBJsonParser alloc] init] objectWithData:bundleJSONData];
    NSString *found = [dict objectForKey:@"found"];
    if( [found intValue] > 0 ){
        NSLog(@"fonund %d",[found intValue]);
        NSArray *postDictArr = [dict objectForKey:@"posts"];
        for( NSMutableDictionary *postDict in postDictArr )
        {
            if( [postDict objectForKey:@"ID"] != nil )
                [[CoreDataManager getInstance] savePost:postDict];
        }
    }
}

- (Post *)getPost:(NSString *)postId
{
    if( postId == nil )
        return nil;
    NSPredicate *_predicate;
    _predicate = [NSPredicate predicateWithFormat:@"post_id == %@",postId];
    NSArray *fetchedResults = [self getFetchResults:@"Post" withKey:@"post_id" filter:_predicate];
    if( [fetchedResults count] > 0 )
        return [fetchedResults objectAtIndex:0];
    return nil;
}

- (void)updatePost:(NSDictionary *)jsonDict
{
    id tempValue = nil;
    tempValue = [jsonDict objectForKey:@"ID"];
    if( [tempValue isKindOfClass:[NSDecimalNumber class]] )
        tempValue = [NSString stringWithFormat:@"%@",[tempValue stringValue]];
    if( tempValue != nil && [tempValue length] > 0 && [self validatePostId:tempValue] )
        return;
    Post *tempPost = [self getPost:tempValue];
    tempValue = [jsonDict objectForKey:@"title"];
    if( tempValue != nil && [tempValue length] > 0 )
        tempPost.title = tempValue;
    tempValue = [self stringByStrippingHTML:[jsonDict objectForKey:@"content"]];
    if( tempValue != nil && [tempValue length] > 0 )
        tempPost.content = tempValue;
    tempValue = [jsonDict objectForKey:@"like_count"];
    if( tempValue != nil )
        tempPost.like_count = [NSNumber numberWithInt:[tempValue intValue]];
    tempValue = [jsonDict objectForKey:@"comment_count"];
    if( tempValue != nil )
        tempPost.comment_count = [NSNumber numberWithInt:[tempValue intValue]];
    
    NSMutableDictionary *tempDict = [jsonDict objectForKey:@"tags"];
    if( [[tempDict allKeys] count] > 0 ){
        NSString *key = [[tempDict allKeys] objectAtIndex:0];
        if( [key length] > 0 )
            tempPost.tags = key;
    }
    
    for( AttatchMent *item in tempPost.attatchments )
        [ad.managedObjectContext deleteObject:item];
    [tempPost removeAttatchments:tempPost.attatchments];
    [self saveContext];
    
    NSString *thumbImagePrefix = @"creator";
    NSMutableDictionary *attatchmentDicts = [jsonDict objectForKey:@"attachments"];
    for( NSString *key in [attatchmentDicts allKeys] )
    {
        NSMutableDictionary *attatchment = [attatchmentDicts objectForKey:key];
        tempValue = [attatchment objectForKey:@"URL"];
        if( [[tempValue lastPathComponent] hasPrefix:thumbImagePrefix] ){
            tempPost.creator_url = tempValue;
            continue;
        }
        if( tempValue != nil && [tempValue length] > 0 ){
            AttatchMent *tempAttachment = [self saveAttatchment:attatchment withPostId:tempPost.post_id];
            [tempPost addAttatchmentsObject:tempAttachment];
        }
    }
    [self saveContext];
}

- (void)savePost:(NSDictionary *)jsonDict
{
    id tempValue = nil;
    tempValue = [jsonDict objectForKey:@"ID"];
    if( [tempValue isKindOfClass:[NSDecimalNumber class]] )
        tempValue = [NSString stringWithFormat:@"%@",[tempValue stringValue]];
    if( tempValue != nil && [tempValue length] > 0 && ![self validatePostId:tempValue] )
        return;
    Post *tempPost = (Post *) [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:ad.managedObjectContext];
    tempPost.post_id = tempValue;
    tempValue = [jsonDict objectForKey:@"title"];
    if( tempValue != nil && [tempValue length] > 0 )
        tempPost.title = tempValue;
    tempValue = [self stringByStrippingHTML:[jsonDict objectForKey:@"content"]];
    if( tempValue != nil && [tempValue length] > 0 )
        tempPost.content = tempValue;
    tempValue = [jsonDict objectForKey:@"like_count"];
    if( tempValue != nil )
        tempPost.like_count = [NSNumber numberWithInt:[tempValue intValue]];
    tempValue = [jsonDict objectForKey:@"comment_count"];
    if( tempValue != nil )
        tempPost.comment_count = [NSNumber numberWithInt:[tempValue intValue]];
    
    NSMutableDictionary *tempDict = [jsonDict objectForKey:@"tags"];
    if( [[tempDict allKeys] count] > 0 ){
        NSString *key = [[tempDict allKeys] objectAtIndex:0];
        if( [key length] > 0 )
            tempPost.tags = key;
    }
    
    NSString *thumbImagePrefix = @"creator";
    NSMutableDictionary *attatchmentDicts = [jsonDict objectForKey:@"attachments"];
    for( NSString *key in [attatchmentDicts allKeys] )
    {
        NSMutableDictionary *attatchment = [attatchmentDicts objectForKey:key];
        tempValue = [attatchment objectForKey:@"URL"];
        if( [[tempValue lastPathComponent] hasPrefix:thumbImagePrefix] ){
            tempPost.creator_url = tempValue;
            continue;
        }
        if( tempValue != nil && [tempValue length] > 0 ){
            AttatchMent *tempAttachment = [self saveAttatchment:attatchment withPostId:tempPost.post_id];
            [tempPost addAttatchmentsObject:tempAttachment];
//            NSLog(@"%@",[tempAttachment debugDescription]);
        }
    }
//    NSLog(@"%@",[tempPost debugDescription]);
    [self saveContext];
}

- (AttatchMent *)saveAttatchment:(NSDictionary *)jsonDict withPostId:(NSString *)postId
{
    id tempValue = nil;
    AttatchMent *tempAttachment = (AttatchMent *) [NSEntityDescription insertNewObjectForEntityForName:@"AttatchMent" inManagedObjectContext:ad.managedObjectContext];
    tempAttachment.post_id = postId;
    tempValue = [jsonDict objectForKey:@"URL"];
    tempAttachment.thumb_url = tempValue;
    tempValue = [jsonDict objectForKey:@"width"];
    if( [tempValue isKindOfClass:[NSDecimalNumber class]] )
        tempValue = [NSString stringWithFormat:@"%@",[tempValue stringValue]];
    tempAttachment.width = [NSNumber numberWithInt:[tempValue intValue]];
    tempValue = [jsonDict objectForKey:@"height"];
    if( [tempValue isKindOfClass:[NSDecimalNumber class]] )
        tempValue = [NSString stringWithFormat:@"%@",[tempValue stringValue]];
    tempAttachment.height = [NSNumber numberWithInt:[tempValue intValue]];
    [self saveContext];
    return tempAttachment;
}

- (NSString *)stringByStrippingHTML:(NSString *)inputString
{
    NSMutableString *outString;
    
    if (inputString)
    {
        outString = [[NSMutableString alloc] initWithString:inputString];
        
        if ([inputString length] > 0)
        {
            NSRange r;
            
            while ((r = [outString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            {
                [outString deleteCharactersInRange:r];
            }
        }
    }
    
    return outString;
}

NSInteger intSortPostId(Post *item1, Post *item2, void *context)
{
    int v1 = [item1.post_id intValue];
    int v2 = [item2.post_id intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

NSInteger intSortURL(AttatchMent *item1, AttatchMent *item2, void *context)
{
    NSString *fileName1 = [[item1.thumb_url lastPathComponent] stringByDeletingPathExtension];
    NSString *fileName2 = [[item2.thumb_url lastPathComponent] stringByDeletingPathExtension];
    fileName1 = [fileName1 substringFromIndex:[fileName1 length]-1];
    fileName2 = [fileName2 substringFromIndex:[fileName2 length]-1];
    int v1 = [fileName1 intValue];
    int v2 = [fileName2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}
@end
