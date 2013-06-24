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
#import "HttpApi.h"

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
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(update)];
    refreshButton.tintColor = [CommonUI getUIColorFromHexString:@"#C9C5C5"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicatorView];
    self.navigationItem.rightBarButtonItem = refreshButton;
    recipePinterest = [[RecipePinterest alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44-GAD_SIZE_320x50.height)];
    recipePinterest.delegate = self;
    [self.view addSubview:recipePinterest];
    [[HttpAsyncApi getInstance] attachObserver:self];
    
    if( [SystemInfo isPad] ){
        bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-GAD_SIZE_320x50.width/2, self.view.bounds.size.height-GAD_SIZE_320x50.height-44, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    }else{
        bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-GAD_SIZE_320x50.height-44, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    }
    bannerView.adUnitID = @"a151ac0e907064e";
    bannerView.rootViewController = self;
    [bannerView loadRequest:[GADRequest request]];
    [self.view addSubview:bannerView];
    
    recipeViewController = [[RecipeViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self versionCheck];
    if( [[[CoreDataManager getInstance] getPosts] count] > 0 ){
        [recipePinterest reloadPintRest];
    }else{
        [_activityIndicatorView startAnimating];
        [self performSelectorInBackground:@selector(makeCoreDataFromBundle) withObject:nil];
    }
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

- (void)makeCoreDataFromBundle
{
    [[CoreDataManager getInstance] makePostFromBundle];
    [recipePinterest reloadPintRest];
    [_activityIndicatorView stopAnimating];
}

#pragma mark - Recipe Info update

- (void)versionCheck
{
    if( [AppPreference getValid] )
        return;
    [[HttpApi getInstance] requestVersion];
}

- (void)update
{
    [_activityIndicatorView startAnimating];
    
    NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
    [[HttpAsyncApi getInstance] requestRecipe:currentPostCount withOffsetPostIndex:0];
}

#pragma mark - request observer

- (void)requestFinished:(NSString *)retString
{
    [_activityIndicatorView stopAnimating];
//    NSLog(@"%@",retString);
    //[recipePinterest getShowIndex];
    NSMutableDictionary* dict = [[[SBJsonParser alloc] init] objectWithString:retString];
    NSString *count = [dict objectForKey:@"count"];
    NSString *total_count = [dict objectForKey:@"count_total"];
    if( [count intValue] > 0 ){
        NSArray *postDictArr = [dict objectForKey:@"posts"];
        for( NSMutableDictionary *postDict in postDictArr )
        {
            NSString *postID = [postDict objectForKey:@"id"];
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
        if( currentPostCount < [total_count intValue] )
            [[HttpAsyncApi getInstance] requestRecipe:[total_count intValue] withOffsetPostIndex:currentPostCount];
    }

}

- (void)requestFailed
{
    NSLog(@"failed");
    [_activityIndicatorView stopAnimating];
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
