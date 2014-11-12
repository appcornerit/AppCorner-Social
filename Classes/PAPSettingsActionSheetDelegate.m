//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPSettingsActionSheetDelegate.h"
#import "PAPFindFriendsViewController.h"
#import "PAPAccountViewController.h"
#import "AppDelegate.h"

// ActionSheet button indexes
typedef NS_ENUM(NSInteger, kPAPSettingsActionSheetButtons) {
	kPAPSettingsProfile = 0,
	kPAPSettingsFindFriends,
	kPAPSettingsLogout,
    kPAPSettingsNumberOfButtons
} ;
 
@implementation PAPSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (instancetype)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kPAPSettingsActionSheetButtons)buttonIndex) {
        case kPAPSettingsProfile:
        {
            PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [accountViewController setUser:[PFUser currentUser]];
            [navController pushViewController:accountViewController animated:YES];
            break;
        }
        case kPAPSettingsFindFriends:
        {
            PAPFindFriendsViewController *findFriendsVC = [[PAPFindFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
        case kPAPSettingsLogout:
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

@end
