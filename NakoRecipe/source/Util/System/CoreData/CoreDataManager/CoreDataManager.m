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
    if( [fetchedResults count] > 0 )
        return fetchedResults;
    return nil;
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
    NSMutableDictionary *attatchmentDicts = [jsonDict objectForKey:@"attachments"];
    for( NSString *key in [attatchmentDicts allKeys] )
    {
        NSMutableDictionary *attatchment = [attatchmentDicts objectForKey:key];
        tempValue = [attatchment objectForKey:@"URL"];
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

@end
