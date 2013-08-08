//
//  RecipeViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeViewController.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface RecipeViewController ()

@end

@implementation RecipeViewController
@synthesize currentPostId;
@synthesize likeVCShow = _likeVCShow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect tempRect = self.view.bounds;
        tempRect.origin = CGPointZero;
        tempRect.size.height -=84;
        recipeView = [[RecipeView alloc] initWithFrame:tempRect];
        recipeView.recipe_delegate = self;
        [self.view addSubview:recipeView];
        
        tempRect.origin.x = 0;
        tempRect.origin.y = tempRect.size.height;
        tempRect.size.height = 40;
        recipeCommentView = [[RecipeCommentView alloc] initWithFrame:tempRect];
        recipeCommentView.comment_delegate = self;
        recipeCommentView.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
        if( [SystemInfo shadowOptionModel]){
            recipeCommentView.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
            recipeCommentView.layer.shadowRadius = 2;
            recipeCommentView.layer.shadowOpacity = 0.2;
        }
        [self.view addSubview:recipeCommentView];
        
        tempRect = [SystemInfo isPad]?CGRectMake(0, 0, 768, 40):CGRectMake(0, 0, 220, 40);
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
        label.text = @"";
        self.navigationItem.titleView = label;
        [[HttpAsyncApi getInstanceCommentSend] attachObserver:self];
        [[HttpAsyncApi getInstanceLikeSend] attachObserver:self];
        
        likeListViewController = [[LikeListViewController alloc] init];
        blogListViewController = [[BlogListViewController alloc] init];
    }
    return self;
}

- (void)shapeView:(UIView *)view
{
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)].CGPath;
    view.layer.masksToBounds = YES;
    view.layer.mask = shapeLayer;
}

- (void)keyboardHide
{
    [recipeCommentView keyboardHide];
}

- (void)keyBoardAnimated:(NSNotification *)notification
{
    [recipeView keyBoardAnimated:notification];
}

- (BOOL)loginCheck
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate loginCheck];
}

- (void)sendLike:(BOOL)like
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate loginCheck] && appDelegate.facebookID != nil && appDelegate.facebookName != nil){
        Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:appDelegate.facebookID forKey:@"fb_id"];
        [dict setValue:tempPost.post_id forKey:@"post_id"];
        [[HttpAsyncApi getInstanceLikeSend] sendLike:dict withLikeState:like];
    }
}

- (void)sendComment:(NSString *)comment
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate loginCheck] && appDelegate.facebookID != nil && appDelegate.facebookName != nil){
        Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:appDelegate.facebookName forKey:@"user_name"];
        [dict setValue:appDelegate.facebookID forKey:@"fb_id"];
        [dict setValue:comment forKey:@"comment"];
        [dict setValue:tempPost.post_id forKey:@"post_id"];
        [dict setValue:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",appDelegate.facebookID] forKey:@"thumb_url"];
        [[HttpAsyncApi getInstanceCommentSend] sendComment:dict];
    }
}

- (void)likeUpdate:(BOOL)state
{
    [recipeCommentView likeUpdate:state];
}

- (void)showLikeList:(NSArray *)likeList
{
    _likeVCShow = YES;
    if( [SystemInfo isPad] ){
        likeListViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }else{
        likeListViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [likeListViewController.likeArr removeAllObjects];
    [likeListViewController.likeArr addObjectsFromArray:likeList];
    [self.navigationController pushViewController:likeListViewController animated:YES];

}

- (void)showBlogList:(NSArray *)blogList withBaseURL:(NSString *)baseURL withTotal:(int)total
{
    _likeVCShow = YES;
    Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
    [blogListViewController.blogArr removeAllObjects];
    [blogListViewController.blogArr addObjectsFromArray:blogList];
    blogListViewController.searchBaseURL = baseURL;
    blogListViewController.totalCount = total;
    blogListViewController.recipeTitle = tempPost.title;
    [self.navigationController pushViewController:blogListViewController animated:YES];
}

- (void)requestFinished:(NSString *)retString withInstance:(HttpAsyncApi *)instance
{
    switch (instance.kindOfRequest) {
        case E_REQUEST_COMMENT_SEND:
        {
            [recipeCommentView sendComplete:YES];
            [recipeView loadComment:YES];
        }
            break;
        case E_REQUEST_LIKE_SEND:
        {
            [recipeCommentView sendLikeComplete:YES];
            [recipeView loadLike];
        }
            break;
        default:
            break;
    }

}

- (void)requestFailed:(HttpAsyncApi *)instance
{
    switch (instance.kindOfRequest) {
        case E_REQUEST_COMMENT_SEND:
        {
            [recipeCommentView sendComplete:NO];
        }
            break;
        case E_REQUEST_LIKE_SEND:
        {
            [recipeCommentView sendLikeComplete:NO];
        }
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [CommonUI getUIColorFromHexString:@"#E4E3DC"];
    _likeVCShow = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if( !_likeVCShow ){
        Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
        [[LocalyticsSession shared] tagEvent:[NSString stringWithFormat:@"Recipe:%@",tempPost.title]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated
{
    if( !_likeVCShow ){
        [recipeView reset];
        [recipeCommentView reset];
    }
}

- (void)prepareWillAppear
{
    _likeVCShow = NO;
    if( currentPostId != nil ){
        [recipeView reloadRecipeView:currentPostId];
        Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
        NSArray *infoTextArr = [tempPost.tags componentsSeparatedByString:@"|"];
        if( [infoTextArr count] > 4 ){
            NSString *food_name       = [infoTextArr objectAtIndex:3];
            UILabel *tempLabel = (UILabel *)self.navigationItem.titleView;
            tempLabel.text = food_name;
        }
    }
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

@end
