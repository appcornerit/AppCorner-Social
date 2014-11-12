//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPFindFriendsViewController.h"
#import "PAPProfileImageView.h"
#import "AppDelegate.h"
#import "PAPLoadMoreCell.h"
#import "PAPAccountViewController.h"
#import "MBProgressHUD.h"
#import "PAPBackButtonItem.h"
#import "Country.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AMBlurView.h"

typedef NS_ENUM(NSInteger, PAPFindFriendsFollowStatus) {
    PAPFindFriendsFollowingNone = 0,    // User isn't following anybody in Friends list
    PAPFindFriendsFollowingAll,         // User is following all Friends
    PAPFindFriendsFollowingSome         // User is following some of their Friends
} ;

@interface PAPFindFriendsViewController ()
@property (nonatomic, strong) AMBlurView *headerView;
@property (nonatomic, assign) PAPFindFriendsFollowStatus followStatus;
@property (nonatomic, strong) NSString *selectedEmailAddress;
@property (nonatomic, strong) NSMutableDictionary *outstandingFollowQueries;
@property (nonatomic, strong) NSMutableDictionary *outstandingCountQueries;

@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) SLComposeViewController *mySLComposerSheet;
@end


@implementation PAPFindFriendsViewController
@synthesize headerView;
@synthesize followStatus;
@synthesize selectedEmailAddress;
@synthesize outstandingFollowQueries;
@synthesize outstandingCountQueries;
#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingFollowQueries = [NSMutableDictionary dictionary];
        self.outstandingCountQueries = [NSMutableDictionary dictionary];
        
        self.selectedEmailAddress = @"";

        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }
        
        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        // Used to determine Follow/Unfollow All button status
        self.followStatus = PAPFindFriendsFollowingSome;
        
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar.logo.png"]];
    self.navigationItem.titleView.alpha = 0.9;
    
    self.navigationItem.leftBarButtonItem = [[PAPBackButtonItem alloc] initWithTarget:self action:@selector(backButtonAction:)];
    
    //ios7 swipe back
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    //ios7 enable swipe back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if ([MFMailComposeViewController canSendMail] || [MFMessageComposeViewController canSendText]) {
        CGFloat height = [UIScreen mainScreen].bounds.size.height - ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.tabBar.frame.size.height;
        self.headerView = [[AMBlurView alloc] initWithFrame:CGRectMake(0, height-67, 320, 67)];

        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setBackgroundColor:[UIColor clearColor]];
        [clearButton addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setFrame:self.headerView.bounds];
        [self.headerView addSubview:clearButton];
        NSString *inviteString = NSLocalizedString(@"findFriends.button.invite",nil);
        CGSize inviteStringSize = [inviteString sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(310, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

        UILabel *inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.headerView.frame.size.height-inviteStringSize.height)/2, [UIScreen mainScreen].bounds.size.width, inviteStringSize.height)];
        
        [inviteLabel setText:inviteString];
        [inviteLabel setTextAlignment:NSTextAlignmentCenter];
        [inviteLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [inviteLabel setTextColor:[UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0]];

        [inviteLabel setBackgroundColor:[UIColor clearColor]];
        [self.headerView addSubview:inviteLabel];

        [self.view addSubview:self.headerView];

        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.headerView.frame.size.height, 0.0);
    }
    
    if (NSClassFromString(@"UIRefreshControl")) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
        self.pullToRefreshEnabled = NO;
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) {
        return [PAPFindFriendsCell heightForCell];
    } else {
        return 44.0f;
    }
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    // Use cached facebook friend ids
//    NSArray *facebookFriends = [[PAPCache sharedCache] facebookFriends];
    
    // Query for all friends you have on facebook and who are using the app
    PFQuery *friendsQuery = [PFUser query];
//    [friendsQuery whereKey:kPAPUserFacebookIDKey containedIn:facebookFriends];
    
    //show all people except you (connect people who love open source)
    [friendsQuery whereKey:kPAPUserFacebookIDKey notEqualTo:[[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]];
    
    friendsQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isNetworkReachable)]) {
        friendsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [friendsQuery orderByAscending:kPAPUserDisplayNameKey];
    
    self.showHudForLoading = self.objects.count == 0;
    return friendsQuery;
    
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
    self.showHudForLoading = self.objects.count == 0;       
    self.navigationItem.rightBarButtonItem = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *FriendCellIdentifier = @"FriendCell";
    
    PAPFindFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
    if (cell == nil) {
        cell = [[PAPFindFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FriendCellIdentifier];
        [cell setDelegate:self];
    }
    else{
        cell.avatarImageView.profileID = nil;
    }
    
    [cell setUser:(PFUser*)object];

    [cell.appLabel setText:@"0 apps"];
    
    NSDictionary *attributes = [[PAPCache sharedCache] attributesForUser:(PFUser *)object];
    
    if (attributes) {
        // set them now
        NSString *pluralizedApp;
        NSNumber *number = [[PAPCache sharedCache] appCountForUser:(PFUser *)object];
        if ([number intValue] == 1) {
            pluralizedApp = @"app";
        } else {
            pluralizedApp = @"apps";
        }
        [cell.appLabel setText:[NSString stringWithFormat:@"%@ %@", number, pluralizedApp]];
    } else {
        @synchronized(self) {
            NSNumber *outstandingCountQueryStatus = (self.outstandingCountQueries)[indexPath];
            if (!outstandingCountQueryStatus) {
                (self.outstandingCountQueries)[indexPath] = @YES;
                PFQuery *appNumQuery = [PFQuery queryWithClassName:kPAPAppClassKey];
                [appNumQuery whereKey:kPAPAppUserKey equalTo:object];
                [appNumQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [appNumQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                    @synchronized(self) {
                        [[PAPCache sharedCache] setAppCount:@(number) user:(PFUser *)object];
                        [self.outstandingCountQueries removeObjectForKey:indexPath];
                    }
                    PAPFindFriendsCell *actualCell = (PAPFindFriendsCell*)[tableView cellForRowAtIndexPath:indexPath];
                    NSString *pluralizedApp;
                    if (number == 1) {
                        pluralizedApp = @"app";
                    } else {
                        pluralizedApp = @"apps";
                    }
                    [actualCell.appLabel setText:[NSString stringWithFormat:@"%d %@", number, pluralizedApp]];
                    
                }];
            };
        }
    }

    cell.followButton.selected = NO;
    cell.tag = indexPath.row;
    cell.followButton.enabled = NO;
    if (self.followStatus == PAPFindFriendsFollowingSome) {
        if (attributes) {
            [cell.followButton setSelected:[[PAPCache sharedCache] followStatusForUser:(PFUser *)object]];
            cell.followButton.enabled = YES;
        } else {
            @synchronized(self) {
                NSNumber *outstandingQuery = (self.outstandingFollowQueries)[indexPath];
                if (!outstandingQuery) {
                    (self.outstandingFollowQueries)[indexPath] = @YES;
                    PFQuery *isFollowingQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
                    [isFollowingQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
                    [isFollowingQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
                    [isFollowingQuery whereKey:kPAPActivityToUserKey equalTo:object];
                    [isFollowingQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
                    
                    [isFollowingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        @synchronized(self) {
                            [self.outstandingFollowQueries removeObjectForKey:indexPath];
                            [[PAPCache sharedCache] setFollowStatus:(!error && number > 0) user:(PFUser *)object];
                        }
                        if (cell.tag == indexPath.row) {
                            [cell.followButton setSelected:(!error && number > 0)];
                            cell.followButton.enabled = YES;
                        }
                    }];
                }
            }
        }
    } else {
        [cell.followButton setSelected:(self.followStatus == PAPFindFriendsFollowingAll)];
        cell.followButton.enabled = YES;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *NextPageCellIdentifier = @"NextPageCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:NextPageCellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NextPageCellIdentifier];
        cell.hideSeparatorBottom = YES;
        cell.hideSeparatorTop = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}


#pragma mark - PAPFindFriendsCellDelegate

- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser {
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:aUser];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)cell:(PAPFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser {
    [self shouldToggleFollowFriendForCell:cellView];
}


#pragma mark - ABPeoplePickerDelegate

/* Called when the user cancels the address book view controller. We simply dismiss it. */
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Called when a member of the address book is selected, we return YES to display the member's details. */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

/* Called when the user selects a property of a person in their address book (ex. phone, email, location,...)
   This method will allow them to send a text or email inviting them to the app.  */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {

    if (property == kABPersonEmailProperty) {

        ABMultiValueRef emailProperty = ABRecordCopyValue(person,property);
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emailProperty,identifier);
        self.selectedEmailAddress = email;

        if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
            // ask user
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"findFriends.sheet.invite",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"button.generic.cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"findFriends.sheet.email",nil), NSLocalizedString(@"findFriends.sheet.iMessage",nil), nil];
            UIWindow* window = [[UIApplication sharedApplication] keyWindow];
            [actionSheet showInView:window];
        } else if ([MFMailComposeViewController canSendMail]) {
            // go directly to mail
            [self presentMailComposeViewController:email];
        } else if ([MFMessageComposeViewController canSendText]) {
            // go directly to iMessage
            [self presentMessageComposeViewController:email];
        }

    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        
        if ([MFMessageComposeViewController canSendText]) {
            [self presentMessageComposeViewController:phone];
        }
    }
    
    return NO;
}

#pragma mark - MFMailComposeDelegate

/* Simply dismiss the MFMailComposeViewController when the user sends an email or cancels */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - MFMessageComposeDelegate

/* Simply dismiss the MFMessageComposeViewController when the user sends a text or cancels */
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if(actionSheet.tag == 100)
    {
        if (buttonIndex == 0) {
            [self inviteFriendsFromFacebook];
        }
        else if (buttonIndex == 1) {
            [self postMessageOnFacebook];
        }
        else{
            [self inviteFriendsFromContacts];
        }
    }
    else{
        if (buttonIndex == 0) {
            [self presentMailComposeViewController:self.selectedEmailAddress];
        } else if (buttonIndex == 1) {
            [self presentMessageComposeViewController:self.selectedEmailAddress];
        }
    }
}

#pragma mark - ()

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)inviteFriendsButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"button.generic.cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"invite.sheet.facebook", nil),NSLocalizedString(@"invite.sheet.post.facebook", nil),NSLocalizedString(@"invite.sheet.contacts", nil), nil];
    actionSheet.tag = 100;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)inviteFriendsFromContacts {
    ABPeoplePickerNavigationController *addressBook = [[ABPeoplePickerNavigationController alloc] init];
    addressBook.peoplePickerDelegate = self;
    
    if ([MFMailComposeViewController canSendMail] && [MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = @[@(kABPersonEmailProperty), @(kABPersonPhoneProperty)];
    } else if ([MFMailComposeViewController canSendMail]) {
        addressBook.displayedProperties = @[@(kABPersonEmailProperty)];
    } else if ([MFMessageComposeViewController canSendText]) {
        addressBook.displayedProperties = @[@(kABPersonPhoneProperty)];
    }

    [self presentViewController:addressBook animated:YES completion:nil];
}

- (void)followAllFriendsButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    self.followStatus = PAPFindFriendsFollowingAll;
    [self configureUnfollowAllButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"findFriends.button.unfollowAll",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];

        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = (self.objects)[r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            PAPFindFriendsCell *cell = (PAPFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            cell.followButton.selected = YES;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(followUsersTimerFired:) userInfo:nil repeats:NO];
        [PAPUtility followUsersEventually:self.objects block:^(BOOL succeeded, NSError *error) {
            // note -- this block is called once for every user that is followed successfully. We use a timer to only execute the completion block once no more saveEventually blocks have been called in 2 seconds
            [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0f]];
        }];

    });
}

- (void)unfollowAllFriendsButtonAction:(id)sender {
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    self.followStatus = PAPFindFriendsFollowingNone;
    [self configureFollowAllButton];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"findFriends.button.followAll",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];

        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.objects.count];
        for (int r = 0; r < self.objects.count; r++) {
            PFObject *user = (self.objects)[r];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:0];
            PAPFindFriendsCell *cell = (PAPFindFriendsCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath object:user];
            cell.followButton.selected = NO;
            [indexPaths addObject:indexPath];
        }
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

        [PAPUtility unfollowUsersEventually:self.objects];

        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    });

}

- (void)shouldToggleFollowFriendForCell:(PAPFindFriendsCell*)cell {
    PFUser *cellUser = cell.user;
    if ([cell.followButton isSelected]) {
        // Unfollow
        cell.followButton.selected = NO;
        [PAPUtility unfollowUserEventually:cellUser];
        [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
    } else {
        // Follow
        cell.followButton.selected = YES;
        [PAPUtility followUserEventually:cellUser block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
            } else {
                cell.followButton.selected = NO;
            }
        }];
    }
}

- (void)configureUnfollowAllButton {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"findFriends.button.unfollowAll",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAllFriendsButtonAction:)];
}

- (void)configureFollowAllButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"findFriends.button.followAll",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(followAllFriendsButtonAction:)];
}

- (void)presentMailComposeViewController:(NSString *)recipient {
    // Create the compose email view controller
    MFMailComposeViewController *composeEmailViewController = [[MFMailComposeViewController alloc] init];
    
    // Set the recipient to the selected email and a default text
    [composeEmailViewController setMailComposeDelegate:self];
    [composeEmailViewController setSubject: NSLocalizedString(@"findFriends.mail.subject",nil)];
    [composeEmailViewController setToRecipients:@[recipient]];
    [composeEmailViewController setMessageBody:NSLocalizedString(@"findFriends.mail.text",nil) isHTML:YES];
    
    // Dismiss the current modal view controller and display the compose email one.
    // Note that we do not animate them. Doing so would require us to present the compose
    // mail one only *after* the address book is dismissed.
    [self dismissViewControllerAnimated:NO completion:^{
        [self presentViewController:composeEmailViewController animated:NO completion:nil];
    }];

}

- (void)presentMessageComposeViewController:(NSString *)recipient {
    // Create the compose text message view controller
    MFMessageComposeViewController *composeTextViewController = [[MFMessageComposeViewController alloc] init];
    
    // Send the destination phone number and a default text
    [composeTextViewController setMessageComposeDelegate:self];
    [composeTextViewController setRecipients:@[recipient]];
    [composeTextViewController setBody:NSLocalizedString(@"findFriends.mail.body",nil)];
    
    // Dismiss the current modal view controller and display the compose text one.
    // See previous use for reason why these are not animated.
    [self dismissViewControllerAnimated:NO completion:^{
        [self presentViewController:composeTextViewController animated:NO completion:nil];
    }];

}

- (void)followUsersTimerFired:(NSTimer *)timer {
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}





#pragma mark - Facebook FriendPickerController

- (void)inviteFriendsFromFacebook {
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.generic",nil)
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:NSLocalizedString(@"button.generic.close",nil)
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self sendRequestToiOSFriends];
                                          }
                                      }];
        return;
    }
    [self sendRequestToiOSFriends];
}

-(void) inviteFacebookFriends:(NSArray*) suggestedFriends
{
    NSMutableDictionary* params =  [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 3. Suggest friends the user may want to request
                                     [suggestedFriends componentsJoinedByString:@","], @"suggestions", nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:NSLocalizedString(@"fb.invite.message",nil)
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}];
}

-(void) postMessageOnFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        self.mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        self.mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]; //Tell him with what social plattform to use it, e.g. facebook or twitter 
        [self.mySLComposerSheet setInitialText:NSLocalizedString(@"fb.post.message",nil)]; //the message you want to post
        [self.mySLComposerSheet addImage:[UIImage imageNamed:@"share.icon.png"]]; //an image you could post
        [self.mySLComposerSheet addURL:[NSURL URLWithString:@"http://itunes.com/apps/appcorner"]];  //replace with https://itunes.apple.com/us/app/keynote/id361285480?mt=8
        //for more instance methodes, go here:https://developer.apple.com/library/ios/#documentation/NetworkingInternet/Reference/SLComposeViewController_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40012205
        [self presentViewController:self.mySLComposerSheet animated:YES completion:nil];
    }
    [self.mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSLog(@"SLComposeViewController for facebook not available.");
    }];
}


/*
 * Send request to iOS device users.
 */
- (void)sendRequestToiOSFriends {
    // Filter and only show friends using iOS
    [self requestFriendsUsingDevice:@"iOS"];
}

/*
 * Get iOS device users and send targeted requests.
 */
- (void) requestFriendsUsingDevice:(NSString *)device {
    NSMutableArray *deviceFilteredFriends = [[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:@"me/friends"
                                 parameters: @{ @"fields" : @"id,devices"}
                                 HTTPMethod:nil
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (!error) {
                                  // Get the result
                                  NSArray *resultData = result[@"data"];
                                  // Check we have data
                                  if ([resultData count] > 0) {
                                      // Loop through the friends returned
                                      for (NSDictionary *friendObject in resultData) {
                                          // Check if devices info available
                                          if (friendObject[@"devices"]) {
                                              NSArray *deviceData = friendObject[@"devices"];
                                              // Loop through list of devices
                                              for (NSDictionary *deviceObject in deviceData) {
                                                  // Check if there is a device match
                                                  if ([device isEqualToString:deviceObject[@"os"]]) {
                                                      // If there is a match, add it to the list
                                                      [deviceFilteredFriends addObject:
                                                       friendObject[@"id"]];
                                                      break;
                                                  }
                                              }
                                          }
                                      }
                                  }
                              }
                              // Send request
                              [self inviteFacebookFriends:deviceFilteredFriends];
                          }];
}

@end
