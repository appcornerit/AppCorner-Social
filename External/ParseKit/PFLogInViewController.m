//
//  PFLogInViewController.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PFLogInViewController.h"
#import "PFQuery.h"
#import "PFUser.h"
#import "PFConstants.h"

#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "SyncManager.h"
#import "UIButton+PPiAwesome.h"

@interface PFLogInViewController ()
    @property (strong, nonatomic) IBOutlet UIButton *button;
    @property (assign,nonatomic) CGPoint touchPoint;
    @property (strong, nonatomic) UIImageView* firstLoadView;
@end


@implementation PFLogInViewController


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.button=[UIButton buttonWithType:UIButtonTypeCustom text:NSLocalizedString(@"login.button.message", nil) icon:@"icon-facebook" textAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]} andIconPosition:IconPositionLeft];

    [self.button setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-260.0f)/2.0f, [UIScreen mainScreen].bounds.size.height - 130.0f, 260.0f, 44.0f)];
    [self.button setBackgroundColor:[UIColor colorWithRed:27.0f/255 green:178.0f/255 blue:233.0f/255 alpha:1.0] forUIControlState:UIControlStateHighlighted];
    [self.button setBackgroundColor:[UIColor colorWithRed:60.0f/255 green:89.0f/255 blue:157.0f/255 alpha:1.0] forUIControlState:UIControlStateNormal];
    
    [self.button setSeparation:1];
    [self.button setRadius:5.0];
    
    [self.button addTarget:self action:@selector(login:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.button.alpha = 0.0f;
    [self.view addSubview:self.button];
    [UIView animateWithDuration:1.5f animations:^{
        self.button.alpha = 1.0f;
    }];
    
    stopUdpate = NO;
    self.enableTouch = NO;
    
    //Avoid flash screen on load
    self.firstLoadView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.firstLoadView.image = [UIImage imageNamed:@"Default-568h.png"];
    } else {
        self.firstLoadView.image = [UIImage imageNamed:@"Default.png"];
    }
    [self.view insertSubview:self.firstLoadView belowSubview:self.textLabel];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) loginUser:(NSString*) facebookId displayName:(NSString*)displayName email:(NSString*)email
{    
    NSError *error = nil;
    PFUser * c = [PFUser user];
    NSString* fbToken = FBSession.activeSession.accessTokenData.accessToken;
    BOOL logged = [c.dkEntity loggedUser:&error];
    if(!logged){
        error = nil;
        logged = [c.dkEntity fblogin:&error facebookId:facebookId accessToken:fbToken];
        if(!logged){
             [self showError:error];
             return;
        }
    }
    
    PFQuery *query = [PFUser query];
   [query.dkQuery whereEntityIdMatches: [c objectForKey:kDKEntityIDField]];
    error = nil;
    NSArray *array = [query findObjects:&error];
    if(!error && [array count] > 0){
        c = (PFUser*)array[0];
        //update user email (commented for privacy)
//        if(email && ![email isEqualToString:@""])
//        {
//            [c setObject:email forKey:kUserEmailKey];
//        }
        //update displayname
        NSNumber* userInternal =[c objectForKey:kPAPUserInternal];
        if((!userInternal || ![userInternal boolValue]) && (displayName && ![displayName isEqualToString:@""]))
        {
            [c setObject:displayName forKey:kUserDisplayNameKey];
        }

        [PFUser setCurrentUser:c];
        [[PFUser currentUser] saveEventually];
        
        if([PFInstallation currentInstallation])
        {
            [[PFInstallation currentInstallation] setObject:c.objectId forKey:kPAPInstallationUserKey];
            [[PFInstallation currentInstallation] saveInBackground];
        }
    }
    else
    {
        [self showError:error];
        return;
    }

    [SyncManager sync:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate logInViewController:self didLogInUser: [PFUser currentUser]];
            });
        }
        else
        {
            [self showError:error];
            return;
        }
    }];
}

-(void) showError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [PAPErrorHandler handleError:error titleKey:nil];
        [self logout];
    });
}

- (void)getUserInfo
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 [UIView animateWithDuration:1.0f animations:^{
                     self.button.alpha = 0.0f;
                     if(self.textLabel) self.textLabel.alpha = 0.0;
                     if(self.siteLabel) self.siteLabel.alpha = 0.0;
                 }];
                 self.firstLoadView.alpha = 0.0f;

                 [self startRender];
                 [_ripple initiateRippleAtLocation:self.touchPoint];                 
                 // We have a valid session
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     NSString * facebookId = user.id;
                     NSString * facebookName = user.name;
                     
                     if (facebookName == (id)[NSNull null] || facebookName.length == 0)facebookName = @"";
                     NSString * facebookEmail = user[@"email"]; 
                     if (facebookEmail == (id)[NSNull null] || facebookEmail.length == 0)facebookEmail = @"";
                     [self loginUser:facebookId displayName:facebookName email:facebookEmail];
                 });
             }
             else
             {
                 [PAPErrorHandler handleError:error titleKey:nil];                 
                 [self logout];
             }
         }];
    }
}

- (void)login:(id)sender forEvent:(UIEvent *)event {
    NSSet *touches = [event touchesForView:sender];
    UITouch *touch = [touches anyObject];
    self.touchPoint = [touch locationInView:self.view];
    
    self.button.enabled = NO;
    [UIView animateWithDuration:1.0f animations:^{
        self.button.alpha = 0.5f;
    }];
    if (FBSession.activeSession.isOpen) {
        [self openSessionWithAllowLoginUI:NO];
    } else {
        // The user has initiated a login, so call the openSession method
        // and show the login UX if necessary.
        [self openSessionWithAllowLoginUI:YES];
    }
}

- (void)logout
{
    [PFUser logOut];
    self.button.enabled = YES;
    [UIView animateWithDuration:1.0f animations:^{
        self.button.alpha = 1.0f;
        if(self.textLabel) self.textLabel.alpha = 1.0;
        if(self.siteLabel) self.siteLabel.alpha = 1.0;
    }];
}


/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                [self getUserInfo];
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            //[FBSession.activeSession closeAndClearTokenInformation];
            [self logout];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        [self handleRequestPermissionError:error];        
    }
}

// Helper method to handle errors during permissions request
- (void)handleRequestPermissionError:(NSError *)error
{
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.generic", nil)
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"button.generic.close", nil)
                          otherButtonTitles:nil] show];
    } else {
        if (error.fberrorCategory == FBErrorCategoryUserCancelled){
            // The user has cancelled the request. You can inspect the value and
            // inner error for more context. Here we simply ignore it.
            NSLog(@"User cancelled post permissions.");
        } else {
            NSLog(@"Unexpected error requesting permissions:%@", error);
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fb.permission.error.title",nil)
                                        message:NSLocalizedString(@"fb.permission.error.message",nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"button.generic.close", nil)
                              otherButtonTitles:nil] show];
        }
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:self.facebookPermissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}


@end
