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
#import "HttpApi.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "CustomAlert.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"

@interface PinterestViewController ()

@end

@implementation PinterestViewController
@synthesize loginState = _loginState;

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
    
    recipePinterest = [[RecipePinterest alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44-GAD_SIZE_320x50.height)];
    recipePinterest.recipe_delegate = self;
    recipePinterest.alignType = [[AppPreference getAlign] intValue];
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
    
    UIButton *btnAlign;
    btnAlign = [[UIButton alloc] init];
    [btnAlign setFrame:CGRectMake(0, 0, 83, 45)];
    btnAlign.backgroundColor = [UIColor clearColor];
//    UIImageView *btnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abs_spinner_default"]];
//    [btnImage setFrame:CGRectMake(60, 0, 23, 33)];
//    [btnAlign addSubview:btnImage];
//    UIImage *stretchableImage = [[UIImage imageNamed:@"abs_spinner_default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    [btnAlign setImage:[UIImage imageNamed:@"abs_spinner_default"] forState:UIControlStateNormal];
    [btnAlign setImageEdgeInsets:UIEdgeInsetsMake(15, 60, 0, 0)];
    [btnAlign setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
    btnAlign.titleLabel.font = [UIFont systemFontOfSize:15];
    
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc] initWithCustomView:btnAlign];
    [btnAlign addTarget:self action:@selector(btnAlign) forControlEvents:UIControlEventTouchUpInside];
    btnRight.style = UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem = btnRight;
    [self makePopView];

    [self setupLeftMenuButton];
}


-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

- (void)makePopView
{
    popView = [[AlignPopView alloc] initWithFrame:self.view.bounds];
    popView.hidden = YES;
    popView.align_delegate = self;
    
    [self.view addSubview:popView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[LocalyticsSession shared] tagEvent:@"MainPintrest"];
    [self versionCheck];
    NSInteger recipeCount = [[[CoreDataManager getInstance] getPosts] count];
    if( recipeCount > 0 ){
        if( recipeCount != [recipePinterest getItemCount] ){
            [recipePinterest reloadPintRest];
        }
        [self likeCommentUpdate];
    }else{
        [self update];
    }
    [self updateAlignText];
}

- (void)updateAlignText
{
    UIBarButtonItem *btnRight = self.navigationItem.rightBarButtonItem;
    UIButton *btnAlign = (UIButton *)btnRight.customView;
    switch ([[AppPreference getAlign] intValue] ) {
        case 0:
            [btnAlign setTitle:@"최신순" forState:UIControlStateNormal];
            break;
        case 1:
            [btnAlign setTitle:@"조회순" forState:UIControlStateNormal];
            break;
        case 2:
            [btnAlign setTitle:@"좋아요순" forState:UIControlStateNormal];
            break;
        case 3:
            [btnAlign setTitle:@"댓글순" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)loginComplete:(BOOL)state
{
    _loginState = state;
}

- (void)selectAlign:(int)alignType
{
    [AppPreference setAlign:alignType];
    [self updateAlignText];
    popView.hidden = YES;
    [recipePinterest algin:alignType];
}

- (void)btnAlign
{
    popView.hidden = !popView.hidden;
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [UIImageView clearCache];
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

- (void)likeCommentUpdate
{
    NSURL *url = [NSURL URLWithString:@"http://14.63.219.181:3000/count_info"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if( [JSON count] > 0 )
           [recipePinterest.likeCommentArr removeAllObjects];
        for( NSDictionary *item in JSON ){
            NSString *post_id = [[item objectForKey:@"post_id"] isKindOfClass:[NSNumber class]]?[[item objectForKey:@"post_id"] stringValue]:[item objectForKey:@"post_id"];
            if( post_id != nil ){
                NSString *count = [[item objectForKey:@"count"] isKindOfClass:[NSNumber class]]?[[item objectForKey:@"count"] stringValue]:[item objectForKey:@"count"];
                NSString *likeCount = [[item objectForKey:@"likes"] isKindOfClass:[NSNumber class]]?[[item objectForKey:@"likes"] stringValue]:[item objectForKey:@"likes"];
                NSString *commentCount = [[item objectForKey:@"comments"] isKindOfClass:[NSNumber class]]?[[item objectForKey:@"comments"] stringValue]:[item objectForKey:@"comments"];
                LikeCommentItem *likeItem = [[LikeCommentItem alloc] init];
                likeItem.postId = post_id;
                likeItem.count = [count intValue];
                likeItem.like_count = [likeCount intValue];
                likeItem.comment_count = [commentCount intValue];
                [recipePinterest.likeCommentArr addObject:likeItem];
            }
        }
        [recipePinterest reloadLikePintRest];
    } failure:nil];
    
    [operation start];
}

- (void)update
{
    NSInteger currentPostCount = [[[CoreDataManager getInstance] getPosts] count];
    [[HttpAsyncApi getInstance] requestRecipe:currentPostCount withOffsetPostIndex:0];
}

#pragma mark - request observer

- (void)requestFinished:(NSString *)retString withInstance:(HttpAsyncApi *)instance
{
//    NSLog(@"%@",retString);
    NSError *error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[retString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    NSString *count = [[json objectForKey:@"count"] isKindOfClass:[NSNumber class]]?[[json objectForKey:@"count"] stringValue]:[json objectForKey:@"count"];
    NSString *total_count = [[json objectForKey:@"count_total"] isKindOfClass:[NSNumber class]]?[[json objectForKey:@"count_total"] stringValue]:[json objectForKey:@"count_total"];
    if( [count intValue] > 0 ){
        NSArray *postDictArr = [json objectForKey:@"posts"];
        for( NSMutableDictionary *postDict in postDictArr )
        {
            NSString *postID = [[postDict objectForKey:@"id"] isKindOfClass:[NSNumber class]]?[[postDict objectForKey:@"id"] stringValue]:[postDict objectForKey:@"id"];
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
    [self likeCommentUpdate];
    [recipePinterest stopLoading];
}

- (void)requestFailed:(HttpAsyncApi *)instance
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

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
