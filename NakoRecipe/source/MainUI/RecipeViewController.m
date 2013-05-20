//
//  RecipeViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeViewController.h"

@interface RecipeViewController ()

@end

@implementation RecipeViewController
@synthesize currentPostId;

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
    recipeView = [[RecipeView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:recipeView];
    [self initGestureRecognizer:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    if( currentPostId != nil )
        [recipeView reloadRecipeView:currentPostId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gesture handler

- (void)initGestureRecognizer:(UIView *)view
{
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [view addGestureRecognizer:tapRecognizer];
}

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end