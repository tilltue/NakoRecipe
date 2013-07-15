//
//  AppDelegate.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PinterestViewController.h"

extern NSString *const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    PinterestViewController *pintrestMainViewController;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) NSString *facebookID;
#pragma mark - CoreData
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL)openSession;
- (void)facebookLogout;
- (NSString *)getFaceBookId;
@end
