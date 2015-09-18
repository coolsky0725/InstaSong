//
//  PKIntroRootViewController.m
//  Peek
//
//  Created by Robert Bastian on 2014-03-16.
//  Copyright (c) 2014 Peek Inc. All rights reserved.
//

#import "PKIntroRootViewController.h"
#import "PKIntroContentViewController.h"

@interface PKIntroRootViewController ()

@end

@implementation PKIntroRootViewController

@synthesize skipBtnView;
@synthesize pageControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pageTitles = @[@"", @"", @"", @""];
    _pageImages = @[@"page1.png", @"page2.png", @"page3.png", @"page4.png"];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageViewController"];
    self.pageViewController.dataSource = self;

    PKIntroContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.backgroundColor = [UIColor clearColor];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37 );
    self.pageViewController.delegate = self;

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.view bringSubviewToFront:self.skipBtnView];
    
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Page View Controller Data Source

- (void)pageViewController:(UIPageViewController *)viewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed){return;}
    
    // Find index of current page
    PKIntroContentViewController *currentViewController = (PKIntroContentViewController *)[self.pageViewController.viewControllers lastObject];
    NSInteger indexOfCurrentPage = currentViewController.pageIndex;
    self.pageControl.currentPage = indexOfCurrentPage;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (PKIntroContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count]))
        return nil;

    // Create a new view controller and pass suitable data.
    PKIntroContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    

    return pageContentViewController;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PKIntroContentViewController*) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound))
        return nil;

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PKIntroContentViewController*) viewController).pageIndex;

    if (index == NSNotFound || index++ == [self.pageTitles count])
        return nil;

    return [self viewControllerAtIndex:index];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"tutorialFinished"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
