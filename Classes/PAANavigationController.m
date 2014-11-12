//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAANavigationController.h"
#import "PAAMenuViewController.h"
#import "UIViewController+REFrostedViewController.h"

@interface PAANavigationController ()

@property (strong, readwrite, nonatomic) PAAMenuViewController *menuViewController;

@end

@implementation PAANavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}

@end
