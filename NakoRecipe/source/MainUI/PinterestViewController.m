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

    recipePinterest = [[RecipePinterest alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)];
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
    [self makeCoreDataFromBundle];
    
    UIButton *btnLogin;
    btnLogin = [[UIButton alloc] init];
    [btnLogin setFrame:CGRectMake(0, 0, 32, 32)];
    [btnLogin setImage:[UIImage imageNamed:@"ic_overflow"] forState:UIControlStateNormal];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:btnLogin];
    [btnLogin addTarget:self action:@selector(btnLogin) forControlEvents:UIControlEventTouchUpInside];
    btnRight.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = btnRight;
    [self makePopView];
}

- (void)makePopView
{
    popView = [[UIView alloc] initWithFrame:self.view.bounds];
    popView.hidden = YES;
    
    UIButton *btnClose = [[UIButton alloc] initWithFrame:self.view.bounds];
    [btnClose addTarget:self action:@selector(btnClose) forControlEvents:UIControlEventTouchUpInside];
    [popView addSubview:btnClose];
    
    UIButton *btnFacebook = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 160, 5, 150, 38)];
    btnFacebook.backgroundColor = [UIColor whiteColor];
    btnFacebook.layer.cornerRadius = 5;
    btnFacebook.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
    btnFacebook.layer.shadowRadius = 2;
    btnFacebook.layer.shadowOpacity = 0.2;
    [popView addSubview:btnFacebook];
    
    UIImageView *ivFaceIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_facebook"]];
    ivFaceIcon.frame = CGRectMake(self.view.bounds.size.width - 157, 8, 32, 32);
    [popView addSubview:ivFaceIcon];
    
    CGRect frame = ivFaceIcon.frame;
    frame.origin.x += ivFaceIcon.frame.size.width + 3;
    frame.size.width = 120;
    
    UILabel *lblFacebook = [[UILabel alloc] initWithFrame:frame];
    lblFacebook.font = [UIFont systemFontOfSize:17];
    lblFacebook.text = @"페이스북 로그인";
    lblFacebook.textColor = [UIColor grayColor];
    lblFacebook.backgroundColor = [UIColor clearColor];
    [popView addSubview:lblFacebook];
    
    [self.view addSubview:popView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self versionCheck];
    if( [[[CoreDataManager getInstance] getPosts] count] > 0 ){
        [recipePinterest reloadPintRest];
    }else{
        [self update];
    }
}

- (void)btnLogin
{
    popView.hidden = !popView.hidden;
}

- (void)btnClose
{
    popView.hidden = YES;
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
    NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
    [[HttpAsyncApi getInstance] requestRecipe:currentPostCount withOffsetPostIndex:0];
}

#pragma mark - request observer

- (void)requestFinished:(NSString *)retString
{
//    NSLog(@"%@",retString);
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
        [[CoreDataManager getInstance] saveContext];
        [recipePinterest reloadPintRest];
        //전체 갯수가 더 많을때 부분 요청을 다시 한번 한다.
        NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
        if( currentPostCount < [total_count intValue] )
            [[HttpAsyncApi getInstance] requestRecipe:[total_count intValue] withOffsetPostIndex:currentPostCount];
    }
    [recipePinterest stopLoading];
}

- (void)requestFailed
{
    [recipePinterest stopLoading];
}

#pragma mark - pintrestview delegate

- (void)selectRecipe:(NSString *)recipeId
{
    recipeViewController.currentPostId = recipeId;
    [recipeViewController prepareWillAppear];
    if( [SystemInfo isPad] ){
        recipeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }else{
        recipeViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self.navigationController pushViewController:recipeViewController animated:YES];
}
@end
