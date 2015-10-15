//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "AppDelegate.h"

#import "MBProgressHUD.h"
#import "PAPHomeViewController.h"
#import "PAPLogInViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PAPAccountViewController.h"
#import "PAPWelcomeViewController.h"
#import "PAPActivityFeedViewController.h"
#import "PAPAppDetailsViewController.h"
#import "SyncManager.h"
#import "Country.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"

#import "PAANavigationController.h"
#import "PAAMenuViewController.h"
#import "REFrostedViewController.h"
#import "PAAppStoreQuery.h"

@interface AppDelegate () <SocketIODelegate>{
    NSMutableData *_data;
    BOOL firstLaunch;
}

@property (nonatomic, strong) SocketIO *socketIO;
@property (nonatomic, strong) PAPHomeViewController *homeViewController;
@property (nonatomic, strong) PAPActivityFeedViewController *activityViewController;
@property (nonatomic, strong) PAPWelcomeViewController *welcomeViewController;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

@property (nonatomic, strong) DKReachability *hostReach;
@property (nonatomic, strong) DKReachability *internetReach;
@property (nonatomic, strong) DKReachability *wifiReach;
@property (nonatomic, assign) NSInteger appPostNotificationCounter;

- (void)setupAppearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
@end

@implementation AppDelegate

@synthesize window;
@synthesize navController;
@synthesize tabBarController;

@synthesize homeViewController;
@synthesize activityViewController;
@synthesize welcomeViewController;

@synthesize hud;
@synthesize autoFollowTimer;

@synthesize hostReach;
@synthesize internetReach;
@synthesize wifiReach;


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIApplication sharedApplication] delegate] window];
    [Parse setApplicationId:SERVER_URL clientKey:nil];
    [Parse setRequestLogEnabled:NO];    

    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
//    // if you want to use https instead of http
//    if(SERVER_PORT == PROD_SERVER_PORT)
//    {
//        //self.socketIO.useSecure = YES;
//    }
    [self resetAppPostNotificationCounter];

    if (application.applicationIconBadgeNumber != 0 && [PFInstallation currentInstallation]) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    self.welcomeViewController = [[PAPWelcomeViewController alloc] init];

    self.navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];

    [self handlePush:launchOptions];
 
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];

    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }

    if([PFInstallation currentInstallation])
    {
        [[PFInstallation currentInstallation] saveInBackground];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if ([error code] != 3010) {
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString* type = userInfo[kPAPPushPayloadActivityTypeKey];
    if(type && [type isEqualToString:kPAPPushPayloadPayloadTypePurchaseKey])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceivePurchaseRemoteNotification object:nil userInfo:userInfo];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:userInfo];
        
        if ([PFUser currentUser]) {
            if ([self.tabBarController viewControllers].count > PAPActivityTabBarItemIndex) {
                UITabBarItem *tabBarItem = [(self.tabBarController.viewControllers)[PAPActivityTabBarItemIndex] tabBarItem];
                
                NSString *currentBadgeValue = tabBarItem.badgeValue;
                
                if (currentBadgeValue && currentBadgeValue.length > 0) {
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    NSNumber *badgeValue = [numberFormatter numberFromString:currentBadgeValue];
                    NSNumber *newBadgeValue = @([badgeValue intValue] + 1);
                    tabBarItem.badgeValue = [numberFormatter stringFromNumber:newBadgeValue];
                } else {
                    tabBarItem.badgeValue = @"1";
                }
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0 && [PFInstallation currentInstallation]) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;

    [[FBSession activeSession] handleDidBecomeActive];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    PFUser * user = [PFUser user];
    if(user)
    {
        NSError* error = nil;
        BOOL logged = [user.dkEntity loggedUser:&error];
        if(logged)
        {
            [PAPErrorHandler handleSuccess:@"becomeActive.updateMessage"];
            [SyncManager sync:^(BOOL succeeded, NSError *error) {
                if(!succeeded)
                {
                    NSLog(@"SyncManager error: %@",error);
                }
            }];
        }
    }
}


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
    // The empty UITabBarItem behind our Camera button should not load a view controller
    return ![viewController isEqual:aTabBarController.viewControllers[PAPEmptyTabBarItemIndex]];
}


#pragma mark - PFLoginViewController

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {

    //enable socket
    [self.socketIO connectToHost:SERVER_URI onPort:SERVER_PORT];
    
    // user has logged in - we need to fetch all of their Facebook data before we let them in
    if (![self shouldProceedToMainInterface:user]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view animated:YES];
        self.hud.labelText = NSLocalizedString(@"Loading", nil);
        self.hud.dimBackground = YES;
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [self facebookRequestDidLoad:result];
        } else {
            [self facebookRequestDidFailWithError:error];
        }
    }];
}

#pragma mark - AppDelegate

- (BOOL)isNetworkReachable {
    return [DKManager endpointReachable];
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
    PAPLogInViewController *loginViewController = [[PAPLogInViewController alloc] init];
    [loginViewController setDelegate:self];
    loginViewController.fields = PFLogInFieldsFacebook;
    loginViewController.facebookPermissions = @[ @"user_about_me",@"email"];    
    loginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.welcomeViewController presentViewController:loginViewController animated:NO completion:nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentTabBarController {    
    self.tabBarController = [[PAPTabBarController alloc] init];
    self.homeViewController = [[PAPHomeViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.homeViewController setFirstLaunch:firstLaunch];
    self.activityViewController = [[PAPActivityFeedViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *emptyNavigationController = [[UINavigationController alloc] init];
    
    PAANavigationController* homeNavigationController = [[PAANavigationController alloc] initWithRootViewController:self.homeViewController];
    PAAMenuViewController *homeMenuController = [[PAAMenuViewController alloc] initWithStyle:UITableViewStylePlain];
    REFrostedViewController *homeFrostedViewController = [[REFrostedViewController alloc] initWithContentViewController:homeNavigationController menuViewController:homeMenuController];
    homeFrostedViewController.direction = REFrostedViewControllerDirectionRight;
    homeFrostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    
    PAANavigationController* activityFeedNavigationController = [[PAANavigationController alloc] initWithRootViewController:self.activityViewController];
    PAAMenuViewController *activityMenuController = [[PAAMenuViewController alloc] initWithStyle:UITableViewStylePlain];
    REFrostedViewController *activityFrostedViewController = [[REFrostedViewController alloc] initWithContentViewController:activityFeedNavigationController menuViewController:activityMenuController];
    activityFrostedViewController.direction = REFrostedViewControllerDirectionRight;
    activityFrostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:homeNavigationController];
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:emptyNavigationController];
    [PAPUtility addBottomDropShadowToNavigationBarForNavigationController:activityFeedNavigationController];
    
    UITabBarItem *homeTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar.label.home", nil) image:nil tag:0];
    [homeTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar.home.selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar.home.png"]];

    [homeTabBarItem setTitleTextAttributes: @{ NSForegroundColorAttributeName: [UIColor colorWithRed:0.0f/255.0f green:190.0f/255.0f blue:255.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    UITabBarItem *activityFeedTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tabbar.label.activity", nil) image:nil tag:1];
    [activityFeedTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar.activities.selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar.activities.png"]];

    [activityFeedTabBarItem setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor colorWithRed:0.0f/255.0f green:190.0f/255.0f blue:255.0f/255.0f alpha:1.0f] } forState:UIControlStateSelected];
    
    [homeFrostedViewController setTabBarItem:homeTabBarItem];
    [activityFrostedViewController setTabBarItem:activityFeedTabBarItem];
    
    self.tabBarController.delegate = self;

    self.tabBarController.viewControllers = @[ homeFrostedViewController, emptyNavigationController, activityFrostedViewController];
    
    [self.navController setViewControllers:@[ self.welcomeViewController, self.tabBarController ] animated:NO];

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound)];
    }
}

- (void)logOut {
    // clear cache
    [[PAPCache sharedCache] clear];

    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Unsubscribe from push notifications by removing the user association from the current installation.
    if([PFInstallation currentInstallation])
    {
        [[PFInstallation currentInstallation] removeObjectForKey:kPAPInstallationUserKey];
        [[PFInstallation currentInstallation] saveInBackground];
    }
    // Log out
    [PFUser logOut];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // clear out cached data, view controllers, etc
    [self.navController popToRootViewControllerAnimated:NO];
    
    [self presentLoginViewController];
    
    self.homeViewController = nil;
    self.activityViewController = nil;
    
    //disconnect
    [self.socketIO disconnectForced];
}


#pragma mark - ()

- (void)handlePush:(NSDictionary *)launchOptions {

    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
        
        if (![PFUser currentUser]) {
            return;
        }
                
        // If the push notification payload references a app, we will attempt to push this view controller into view
        NSString *appObjectId = remoteNotificationPayload[kPAPPushPayloadAppIdKey];
        if (appObjectId && appObjectId.length > 0) {
            [self shouldNavigateToApp:(PAApp*)[PAApp objectWithoutDataWithClassName:kPAPAppClassKey objectId:appObjectId]];
            return;
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        NSString *fromObjectId = remoteNotificationPayload[kPAPPushPayloadFromUserObjectIdKey];
        if (fromObjectId && fromObjectId.length > 0) {
            PFQuery *query = [PFUser query];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
                if (!error) {
                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
                    self.tabBarController.selectedViewController = homeNavigationController;
                    
                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
                    accountViewController.user = (PFUser *)user;
                    [homeNavigationController pushViewController:accountViewController animated:YES];
                }
            }];
        }
    }
}

- (void)autoFollowTimerFired:(NSTimer *)aTimer {
    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
    [MBProgressHUD hideHUDForView:self.homeViewController.view animated:YES];
    [self.homeViewController loadObjects];
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    if ([PAPUtility userHasValidFacebookData:[PFUser currentUser]]) {
        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        [self presentTabBarController];

        [self.navController dismissViewControllerAnimated:YES completion:^{
        }];
        return YES;
    }
    
    return NO;
}

- (BOOL)handleActionURL:(NSURL *)url {
    // fb1410425812510551://appid/859204347
    if ([[url fragment] rangeOfString:@"^appid/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
        NSString *appId = [url lastPathComponent];
        if (appId && appId.length > 0) {
            PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
            query.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            [query loadAppWithAppId:appId completionBlock:^(PAApp *app, NSError *error) {
                if(!error && app && app.loaded)
                {
                    [self.tabBarController appSelected:app modal:YES];
                }
            }];
            return YES;
        }
    }
    return NO;
}

- (void)shouldNavigateToApp:(PAApp *)targetApp {
    for (PAApp *app in self.homeViewController.objects) {
        if ([[app objectId] isEqualToString:[targetApp objectId]]) {
            targetApp = app;
            break;
        }
    }
    
    // if we have a local copy of this app, this won't result in a network fetch
    [targetApp fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            UINavigationController *homeNavigationController = [self.tabBarController viewControllers][PAPHomeTabBarItemIndex];
            [self.tabBarController setSelectedViewController:homeNavigationController];
            
            PAPAppDetailsViewController *detailViewController = [[PAPAppDetailsViewController alloc] initWithApp:(PAApp*)object];
            [homeNavigationController pushViewController:detailViewController animated:YES];
        }
    }];
}

- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = result[@"data"];
    
    if (data) {
        // we have friends data
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data) {
            if (friendData[@"id"]) {
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        // cache friend data
        [[PAPCache sharedCache] setFacebookFriends:facebookIds];
        
        if (user) {
            if (![user objectForKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey]) {
                self.hud.labelText = NSLocalizedString(@"hud.following.friends", nil);
                firstLaunch = YES;
                
                [user setObject:@YES forKey:kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
                NSError *error = nil;
                
                // find common Facebook friends already using the app
                PFQuery *facebookFriendsQuery = [PFUser query];
                [facebookFriendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookIds];
                
                // auto-follow
                PFQuery *autoFollowAccountsQuery = [PFUser query];
                if([Country currentCountry])
                {
                    [autoFollowAccountsQuery whereKey:kPAPUserFacebookIDKey containedIn:[[Country currentCountry] objectForKey:kPAPCountryAutoFollowFacebookIds]];
                }
                
                // combined query
                PFQuery *query = [PFQuery orQueryWithSubqueries:@[autoFollowAccountsQuery,facebookFriendsQuery]];
                
                NSArray *anypicFriends = [query findObjects:&error];
                
                if (!error) {
                    [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        PFObject *joinActivity = [PFObject objectWithClassName:kPAPActivityClassKey];
                        [joinActivity setObject:user forKey:kPAPActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:kPAPActivityToUserKey];
                        [joinActivity setObject:kPAPActivityTypeJoined forKey:kPAPActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        // make sure our join activity is always earlier than a follow
                        [joinActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            [PAPUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                                // This block will be executed once for each friend that is followed.
                                // We need to refresh the timeline when we are following at least a few friends
                                // Use a timer to avoid refreshing innecessarily
                                if (self.autoFollowTimer) {
                                    [self.autoFollowTimer invalidate];
                                }
                                
                                self.autoFollowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(autoFollowTimerFired:) userInfo:nil repeats:NO];
                            }];
                        }];
                    }];
                }
                
                if (![self shouldProceedToMainInterface:user]) {
                    [self logOut];
                    return;
                }
                
                if (!error) {
                    [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:NO];
                    if (anypicFriends.count > 0) {
                        [MBProgressHUD hideAllHUDsForView:self.homeViewController.view animated:NO];
                        self.hud = [MBProgressHUD showHUDAddedTo:self.homeViewController.view animated:NO];
                        self.hud.dimBackground = YES;
                        self.hud.labelText = NSLocalizedString(@"hud.following.friends", nil);
                    } else {
                        [self.homeViewController loadObjects];
                    }
                }
            }
            
            [user saveEventually];
        } else {
            NSLog(@"No user session found. Forcing logOut.");
            [self logOut];
        }
    } else {
        self.hud.labelText = NSLocalizedString(@"hud.create.profile", nil);

        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:kPAPUserDisplayNameKey];
            } else {
                [user setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
            }
            
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:kPAPUserFacebookIDKey];
            }
            
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
        }
    }
}

#pragma mark - SocketIODelegate

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    //Deployd issue https://github.com/deployd/deployd/issues/141
//    NSLog(@"didReceiveMessage() >>> data: %@", packet.data);
    if(packet && packet.name && [packet.name isEqualToString:kPAPSocketPayloadNewAppKey])
    {
        self.appPostNotificationCounter++;
        NSString* message = [NSString stringWithFormat: NSLocalizedString(@"home.app.notification", nil), self.appPostNotificationCounter];
        if(self.appPostNotificationCounter > 1)
        {
           message = [NSString stringWithFormat: NSLocalizedString(@"home.app.notifications", nil), self.appPostNotificationCounter];
        }
        [PAPErrorHandler handleMessage:message];
    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}

-(void)resetAppPostNotificationCounter
{
    self.appPostNotificationCounter = 0;
}
@end
