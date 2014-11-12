//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPActivityCell.h"
#import "PAPAppDetailsFooterView.h"
#import "PAPConstants.h"
#import "PAPAccountViewController.h"
#import "PAPLoadMoreCell.h"
#import "PAPUtility.h"
#import "MBProgressHUD.h"
#import "PAPBackButtonItem.h"
#import "Country.h"

enum ActionSheetTags {
    MainActionSheetTag = 0,
    ConfirmDeleteActionSheetTag = 1
};

@interface PAPAppDetailsViewController ()
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PAPAppDetailsHeaderView *headerView;
@property (nonatomic, assign) BOOL likersQueryInProgress;
@end

static const CGFloat kPAPCellInsetWidth = 10.0f;

@implementation PAPAppDetailsViewController

@synthesize commentTextField;
@synthesize app, headerView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedAppCallbackFinishedNotification object:self.app];
}

- (instancetype)initWithApp:(PAApp *)aApp {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;

        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }

        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of comments to show per page
        self.objectsPerPage = 20;
        
        self.app = aApp;
        
        self.likersQueryInProgress = NO;
        self.openedFromAccount = NO;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 90, 40);
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:@"toolbar.logo.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapLogoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;
    self.navigationItem.titleView.alpha = 0.9;
    self.navigationItem.hidesBackButton = YES;

    self.navigationItem.leftBarButtonItem = [[PAPBackButtonItem alloc] initWithTarget:self action:@selector(backButtonAction:)];
    
    //ios7 swipe back
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    //ios7 enable swipe back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    // Set table view properties
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    // Set table header
    self.headerView = [[PAPAppDetailsHeaderView alloc] initWithFrame:[PAPAppDetailsHeaderView rectForView] app:self.app];
    self.headerView.delegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Set table footer
    PAPAppDetailsFooterView *footerView = [[PAPAppDetailsFooterView alloc] initWithFrame:[PAPAppDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    commentTextField.delegate = self;
    self.tableView.tableFooterView = footerView;

    if ([self currentUserOwnsApp]) {
        // Else we only want to show an action button if the user owns the app and has permission to delete it.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonAction:)];
    }
    else if(NSClassFromString(@"UIActivityViewController")) {
        // Use UIActivityViewController if it is available (iOS 6 +)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(activityButtonAction:)];        
    }
    
    if (NSClassFromString(@"UIRefreshControl")) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
        self.pullToRefreshEnabled = NO;
    }
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLikedOrUnlikedApp:) name:PAPUtilityUserLikedUnlikedAppCallbackFinishedNotification object:self.app];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.headerView reloadLikeBar];
    
    // we will only hit the network if we have no cached data for this app
    BOOL hasCachedLikers = [[PAPCache sharedCache] attributesForApp:self.app] != nil;
    if (!hasCachedLikers) {
        [self loadLikers];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = (self.objects)[indexPath.row];
        
        if (object) {
            NSString *commentString = [object objectForKey:kPAPActivityContentKey];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:kPAPActivityFromUserKey];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:kPAPUserDisplayNameKey];
            }
            
            CGFloat h = [PAPActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
            if(h<49.0) //fix min cell height
                return 49.0;
            else
                return h;
        }
    }
    
    // The pagination row
    return 44.0f;
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityAppIDKey equalTo:self.app];
    [query includeKey:kPAPActivityFromUserKey];
    [query whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeComment];
    [query orderByAscending:@"createdAt"]; 

    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isNetworkReachable)]) {    
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }

    self.tableView.tableHeaderView = self.headerView;
    
    [self.headerView reloadLikeBar];
    [self loadLikers];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";

    // Try to dequeue a cell and create one if necessary
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.delegate = self;
    }
    else{
        cell.avatarImageView.profileID = nil;
    }
    
    [cell setUser:[object objectForKey:kPAPActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kPAPActivityContentKey]];
    [cell setDate:[object createdAt]];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 140) ? NO : YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0 && [self.app objectForKey:kPAPAppUserKey]) {
        PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
        [comment setObject:trimmedComment forKey:kPAPActivityContentKey]; // Set comment text
        [comment setObject:[self.app objectForKey:kPAPAppUserKey] forKey:kPAPActivityToUserKey]; // Set toUser
        [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey]; // Set fromUser
        [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
        [comment setObject:self.app forKey:kPAPActivityAppIDKey];
        
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.app objectForKey:kPAPAppUserKey]];
        comment.ACL = ACL;

        [[PAPCache sharedCache] incrementCommentCountForApp:self.app];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            if (error)
            {
                [[PAPCache sharedCache] decrementCommentCountForApp:self.app];
                if(error.code == kPFErrorObjectNotFound) {
                    [PAPErrorHandler handleErrorMessage:@"This app is no longer available" titleKey:@"Could not post comment"];
                }
                else
                {
                    [PAPErrorHandler handleError:error titleKey:@"Could not post comment"];
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDetailsViewControllerUserCommentedOnAppNotification object:self.app userInfo:@{@"comments": @(self.objects.count + 1)}];
            
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.generic.warning",nil) message:NSLocalizedString(@"detail.confirm.message",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.generic.cancel",nil),NSLocalizedString(@"detail.confirm.delete", nil), nil];
            alert.tag = ConfirmDeleteActionSheetTag;
            [alert show];
        }
        else if([actionSheet cancelButtonIndex] == buttonIndex)
        {
            //Do nothing;
        }
        else {
            [self activityButtonAction:actionSheet];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == ConfirmDeleteActionSheetTag)
    {
        if (buttonIndex == 0)
        {
            // Yes, do nothing
        }
        else if (buttonIndex == 1)
        {
            [self shouldDeleteApp];            
        }
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}


#pragma mark - PAPBaseTextCellDelegate

- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
    [self shouldPresentAccountViewForUser:aUser];
}


#pragma mark - PAPAppDetailsHeaderViewDelegate

-(void)appDetailsHeaderView:(PAPAppDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    [self shouldPresentAccountViewForUser:user];
}

- (void)actionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = MainActionSheetTag;
    actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"detail.button.delete", nil)];
    if (NSClassFromString(@"UIActivityViewController")) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"detail.button.share", nil)];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"button.generic.cancel", nil)];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)activityButtonAction:(id)sender {
    if (NSClassFromString(@"UIActivityViewController")) {
        if ([[self.app objectForKey:kPAPAppIconKey] isDataAvailable]) { 
            [self showShareSheet];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[self.app objectForKey:kPAPAppIconKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (!error) {
                    [self showShareSheet];
                }
            }];
        }
    }
}


#pragma mark - ()

- (void)showShareSheet
{
    UIImage* image = [self.headerView.appImageScrollView getCurrentImage];
    NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:6];

    // Prefill caption if this is the original poster of the app, and then only if they added a caption initially.
    if ([[[PFUser currentUser] objectId] isEqualToString:[[self.app objectForKey:kPAPAppUserKey] objectId]] && [self.objects count] > 0) {
        PFObject *firstActivity = self.objects[0];
        if ([[[firstActivity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[self.app objectForKey:kPAPAppUserKey] objectId]]) {
            NSString *commentString = [firstActivity objectForKey:kPAPActivityContentKey];
            [activityItems addObject:commentString];
        }
    }

    [activityItems addObject:self.app.name];
    [activityItems addObject:image];

    [activityItems addObject:NSLocalizedString(@"share.post.message",nil)];
    [activityItems addObject:[NSURL URLWithString:@"http://itunes.com/apps/appcorner"]];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[]];
    [activityViewController setValue:self.app.name forKey:@"subject"];

    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeCopyToPasteboard];

    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
}

- (void)shouldPresentAccountViewForUser:(PFUser *)user {
    if(self.openedFromAccount && [[user objectId] isEqualToString:[self.openedFromUserAccount objectId]])
    {
        return; 
    }
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userLikedOrUnlikedApp:(NSNotification *)note {
    [self.headerView reloadLikeBar];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-kbSize.height) animated:YES];
}

- (void)loadLikers {
    if (self.likersQueryInProgress) {
        return;
    }

    self.likersQueryInProgress = YES;
    PFQuery *query = [PAPUtility queryForActivitiesOnApp:app cachePolicy:kPFCachePolicyNetworkOnly];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.likersQueryInProgress = NO;
        if (error) {
            [self.headerView reloadLikeBar];
            return;
        }
        
        NSMutableArray *likers = [NSMutableArray array];
        NSMutableArray *commenters = [NSMutableArray array];
        
        BOOL isLikedByCurrentUser = NO;
        
        for (PFObject *activity in objects) {
            if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [likers addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            } else if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeComment] && [activity objectForKey:kPAPActivityFromUserKey]) {
                [commenters addObject:[activity objectForKey:kPAPActivityFromUserKey]];
            }
            
            if ([[[activity objectForKey:kPAPActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeLike]) {
                    isLikedByCurrentUser = YES;
                }
            }
        }
        
        [[PAPCache sharedCache] setAttributesForApp:app likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
        [self.headerView reloadLikeBar];
    }];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

- (BOOL)currentUserOwnsApp {
    return [[[self.app objectForKey:kPAPAppUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]];
}

- (void)shouldDeleteApp {
    // Delete all activites related to this app
    PFQuery *query = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [query whereKey:kPAPActivityAppIDKey equalTo:self.app];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity deleteEventually];
            }
        }
        
        // Delete app
        [self.app deleteEventually];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDetailsViewControllerUserDeletedAppNotification object:[self.app objectId]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PAPAppHeaderViewDelegate
- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapOnAppIconButton:(UIButton *)button app:(PAApp *)tappedApp
{
    NSDictionary *appParameters = @{SKStoreProductParameterITunesItemIdentifier : tappedApp.appId, SKStoreProductParameterAffiliateToken:kPGHAffiliate};
    SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
    [productViewController setDelegate:self];
    [productViewController loadProductWithParameters:appParameters completionBlock:nil];
    [self presentViewController:productViewController
                       animated:YES
                     completion:nil];
}


#pragma mark- Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


-(void)didTapLogoButtonAction:(id)sender
{
    if(self.objects.count > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.objects.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

@end
