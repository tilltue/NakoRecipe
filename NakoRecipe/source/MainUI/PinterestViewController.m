//
//  PinterestViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "PinterestViewController.h"
#import "CoreDataManager.h"
#import "AppPreference.h"
#import "SBJson.h"

@interface PinterestViewController ()

@end

@implementation PinterestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [CommonUI getUIColorFromHexString:@"#E4E3DC"];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(update)];
    refreshButton.tintColor = [CommonUI getUIColorFromHexString:@"#C9C5C5"];
    self.navigationItem.rightBarButtonItem = refreshButton;

    recipePinterest = [[RecipePinterest alloc] initWithFrame:self.view.bounds];
    recipePinterest.delegate = self;
    [self.view addSubview:recipePinterest];
    [[HttpAsyncApi getInstance] attachObserver:self];
    
    recipeViewController = [[RecipeViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    if( [[[CoreDataManager getInstance] getPosts] count] > 0 )
        ;//update?
    else
        [[CoreDataManager getInstance] makePostFromBundle];
    [recipePinterest reloadPintRest];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Recipe Info update

- (void)updateCheck
{
    BOOL updateCheck = NO;
    NSInteger tempTime = [[AppPreference getCheckTime:PREKEY_UPDATE_RECIPE] floatValue];
    if( tempTime < 0 ){
        updateCheck = YES;
        [AppPreference setCheckTime:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] withKey:PREKEY_UPDATE_RECIPE];
    }else{
        NSInteger tempInterVal = [[NSDate date] timeIntervalSince1970] - tempTime;
        if( tempInterVal > 120 ){
            updateCheck = YES;
            [AppPreference setCheckTime:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] withKey:PREKEY_UPDATE_RECIPE];
        }
    }
    if( updateCheck ){
        NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
        [[HttpAsyncApi getInstance] requestRecipe:currentPostCount withOffsetPostIndex:0];
    }
}

- (void)update
{
    NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
    [[HttpAsyncApi getInstance] requestRecipe:currentPostCount withOffsetPostIndex:0];
}

#pragma mark - request observer

- (void)requestFinished:(NSString *)retString
{
    //NSLog(@"%@",retString);
    //[recipePinterest getShowIndex];
    NSMutableDictionary* dict = [[[SBJsonParser alloc] init] objectWithString:retString];
    NSString *found = [dict objectForKey:@"found"];
    if( [found intValue] > 0 ){
        NSArray *postDictArr = [dict objectForKey:@"posts"];
        for( NSMutableDictionary *postDict in postDictArr )
        {
            NSString *postID = [postDict objectForKey:@"ID"];
            if( postID != nil ){
                if( [[CoreDataManager getInstance] validatePostId:postID] )
                    [[CoreDataManager getInstance] savePost:postDict];
                else
                    [[CoreDataManager getInstance] updatePost:postDict];
            }
        }
        [recipePinterest reloadPintRest];
        //전체 갯수가 더 많을때 부분 요청을 다시 한번 한다.
        NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
        if( currentPostCount < [found intValue] )
            [[HttpAsyncApi getInstance] requestRecipe:[found intValue] withOffsetPostIndex:currentPostCount];
    }

}

#pragma mark - pintrestview delegate

- (void)selectRecipe:(NSString *)recipeId
{
    recipeViewController.currentPostId = recipeId;
    if( [SystemInfo isPad] ){
        recipeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }else{
        recipeViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self.navigationController pushViewController:recipeViewController animated:YES];
}
@end
