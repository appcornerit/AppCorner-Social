//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "DAAppsViewController.h"
#import "PAPEditAppViewController.h"

@protocol PAPTabBarControllerDelegate;

@interface PAPTabBarController : UITabBarController <UINavigationControllerDelegate, UIActionSheetDelegate, DAAppsViewControllerDelegate>
{
    DAAppsViewController* appViewController;
    PAPEditAppViewController *editViewController;
}

@end

@protocol PAPTabBarControllerDelegate <NSObject>

- (void)tabBarController:(UITabBarController *)tabBarController cameraButtonTouchUpInsideAction:(UIButton *)button;

@end