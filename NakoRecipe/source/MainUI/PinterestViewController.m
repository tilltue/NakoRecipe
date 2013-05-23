//
//  PinterestViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 16..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "PinterestViewController.h"
#import "CoreDataManager.h"

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
    [[HttpAsyncApi getInstance] requestRecipe:0 withEndPostIndex:10];
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

#pragma mark - request observer

- (void)requestFinished:(NSString *)retString
{
    NSLog(@"%@",retString);
    [recipePinterest getShowIndex];
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
    [self presentViewController:recipeViewController animated:YES completion:nil];
}
@end
