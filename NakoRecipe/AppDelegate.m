//
//  AppDelegate.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "AppDelegate.h"
#import "FileControl.h"
#import "SDURLCache.h"
#import "CustomAlert.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"

NSString *const FBSessionStateChangedNotification = @"com.sample.app:FBSessionStateChangedNotification";

//HA-SJL 세발자전거 HA-SJB
//HA-TTL 테트리스 HA-TTM
@implementation AppDelegate
@synthesize session = _session;
@synthesize facebookID = _facebookID;
@synthesize facebookName = _facebookName;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}
#pragma mark - Facebook related methods

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
            _facebookID = nil;
            _facebookName = nil;
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        case FBSessionStateClosedLoginFailed:
        {
            _facebookID = nil;
            _facebookName = nil;
            [FBSession.activeSession closeAndClearTokenInformation];
            CustomAlert *alert = [[CustomAlert alloc]initWithTitle:@"" message:@"로그인 실패" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            alert.delegate = self;
            [alert show];
        }
            break;
        default:
            break;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification
                                                        object:session];

    if (error) {
        [pintrestMainViewController loginComplete:NO];
    }else{
        [pintrestMainViewController loginComplete:[FBSession activeSession].isOpen];
        [FBRequestConnection startForMeWithCompletionHandler:
         ^(FBRequestConnection *connection, id result, NSError *error)
         {
//             NSLog(@"facebook result: %@", result);
//             NSLog(@"%@",[result objectForKey:@"name"]);
             _facebookID = [result objectForKey:@"id"];
             _facebookName = [result objectForKey:@"name"];
             if(_facebookID != nil && _facebookName != nil && loginPopShow ){
                 CustomAlert *alert = [[CustomAlert alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@ 님\n로그인 되었습니다.",_facebookName] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
                 alert.delegate = self;
                 [alert show];
             }else if( loginPopShow == NO ){
                 loginPopShow = YES;
             }
             [sideviewController reloadTable];
         }];

    }
}

- (void)facebookLogout
{
    CustomAlert *alert = [[CustomAlert alloc]initWithTitle:@"" message:@"로그아웃 하시겠습니까?" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:@"취소", nil];
    alert.tag = 111;
    alert.delegate = self;
    [alert show];    
}

- (BOOL)openSession
{
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session,FBSessionState state,NSError *error) {
                                             
                                             [self sessionStateChanged:session state:state error:error];
                                         }];
}

- (BOOL)loginCheck
{
    return pintrestMainViewController.loginState;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://확인
        {
            if(alertView.tag == 111){
                _facebookID = nil;
                _facebookName = nil;
                [FBSession.activeSession closeAndClearTokenInformation];
            }
        }
            break;
        case 1://취소
        {   
        }
            break;
        default:
            break;
    }
    if( buttonIndex == 0 ){
        
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self managedObjectContext];
    
    [[LocalyticsSession shared] startSession:@"f35bdc28310c39d1fabf523-1f941e08-e550-11e2-364a-00a426b17dd8"];
    
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                         diskCapacity:1024*1024*500 // 5MB disk cache
                                                             diskPath:[SDURLCache defaultCachePath]];
    [NSURLCache setSharedURLCache:urlCache];
    
    pintrestMainViewController = [[PinterestViewController alloc] init];
    if(FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded){
        loginPopShow = NO;
        pintrestMainViewController.loginState = YES;
        [self openSession];
    }else{
        loginPopShow = YES;
        pintrestMainViewController.loginState = NO;
    }
    CGRect tempRect = [SystemInfo isPad]?CGRectMake(0, 0, 568, 40):CGRectMake(0, 0, 120, 40);
    CGFloat titleFontHeight;
    if( [UIFONT_NAME isEqualToString:@"HA-TTL"] )
        titleFontHeight = [SystemInfo isPad]?24.0:24.0f;
    else
        titleFontHeight = [SystemInfo isPad]?24.0:24.0f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:tempRect];
    label.font = [UIFont fontWithName:UIFONT_NAME size:titleFontHeight];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @" 야간매점";
    pintrestMainViewController.navigationItem.titleView = label;
    
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:pintrestMainViewController];
    navigationVC.navigationBar.tintColor = [UIColor whiteColor];//[CommonUI getUIColorFromHexString:@"E04C30"];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[CommonUI getUIColorFromHexString:@"E04C30"] forKey:UITextAttributeTextColor];
    [attributes setValue:[UIColor whiteColor] forKey:UITextAttributeTextShadowColor];
    [attributes setValue:[NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)] forKey:UITextAttributeTextShadowOffset];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    CGFloat verticalOffset = 4;
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[CommonUI getUIColorFromHexString:@"E04C30"]];
    
    
    sideviewController = [[SideViewController alloc] init];
    
    MMDrawerController * drawerController = [[MMDrawerController alloc]
                                             initWithCenterViewController:navigationVC
                                             leftDrawerViewController:sideviewController
                                             rightDrawerViewController:nil];
    [drawerController setMaximumLeftDrawerWidth:[SystemInfo isPad]?350:250];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar|MMOpenDrawerGestureModeBezelPanningCenterView];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = drawerController;

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RecipeModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NakoRecipe.sqlite"];
    [FileControl addSkipBackupAttributeToItemAtURL:storeURL];
    
    NSError *error = nil;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
