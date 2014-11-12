//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPTabBarController.h"
#import "PAPEditAppViewController.h"
#import "REFrostedViewController.h"
#import "PAANavigationController.h"

@interface PAPTabBarController ()
    @property (nonatomic,strong) UINavigationController *navController;
@end

@implementation PAPTabBarController
@synthesize navController;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navController = [[UINavigationController alloc] init];
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:self.navController];
}


#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake( 94.0f, 0.0f, 131.0f, self.tabBar.bounds.size.height);
    [cameraButton setImage:[UIImage imageNamed:@"tabbar.add.png"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(appSearchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cameraButton.alpha = 0.9;
    [self.tabBar addSubview:cameraButton];
    
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeUpGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUpGestureRecognizer setNumberOfTouchesRequired:1];
    [cameraButton addGestureRecognizer:swipeUpGestureRecognizer];
}

#pragma mark - PAPTabBarController

-(void) shouldPresentAppSearchController
{
    appViewController = [[DAAppsViewController alloc] initWithNibName:@"DAAppsViewController" bundle:nil];
    appViewController.delegateAppSearch=self;
    [appViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navController pushViewController:appViewController animated:NO];
    [self presentViewController:self.navController animated:YES completion:nil];
}

- (void) dealloc
{
    appViewController.delegateAppSearch = nil;
    appViewController = nil;
    editViewController = nil;
}

#pragma mark - ()

- (void)appSearchButtonAction:(id)sender {
    [self shouldPresentAppSearchController];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    [self shouldPresentAppSearchController];
}

-(void)appSelected:(PAApp*)app modal:(BOOL) modal
{
   [app existsInUserCountryAppStore:^(BOOL succeeded, NSError *error) {
       if(!app.inCountryAppStore)
       {
           [PAPErrorHandler handleErrorMessage:@"badges.warning.appNotInCountry" titleKey:@"error.generic.warning"];
           return;
       }
       editViewController = [[PAPEditAppViewController alloc] initWithApp:app];
       if(!modal)
       {
           editViewController.closeModalViewOnPublish = YES;
           [self.navController pushViewController:editViewController animated:YES];
       }
       else
       {
           editViewController.closeModalViewOnPublish = NO;
           [((UINavigationController*)((REFrostedViewController*)self.viewControllers[0]).contentViewController)  pushViewController:editViewController animated:YES];
       }
   }];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag == 0 || item.tag == 1)
    {
        REFrostedViewController* homeFosted = (REFrostedViewController*)self.viewControllers[0];
        [homeFosted hideMenuViewController];
        NSArray* homeViewControllers = ((UINavigationController*)homeFosted.contentViewController).viewControllers;
        if(homeViewControllers.count > 1)
        {
          [((UINavigationController*)homeFosted.contentViewController) popToRootViewControllerAnimated:item.tag == 0];
        }

        REFrostedViewController* activityFosted = (REFrostedViewController*)self.viewControllers[2];
        [activityFosted hideMenuViewController];
        
        NSArray* activityViewControllers = ((UINavigationController*)activityFosted.contentViewController).viewControllers;
        if(activityViewControllers.count > 1)
        {
          [((UINavigationController*)activityFosted.contentViewController) popToRootViewControllerAnimated:item.tag == 1];
        }
   }
}

@end
