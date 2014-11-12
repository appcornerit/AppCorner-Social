//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPActivityFeedViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPActivityCell.h"
#import "PAPAccountViewController.h"
#import "PAPAppDetailsViewController.h"
#import "PAPBaseTextCell.h"
#import "PAPLoadMoreCell.h"
#import "PAPSettingsButtonItem.h"
#import "PAPFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "PAPEditAppViewController.h"
#import "PAANavigationController.h"

@interface PAPActivityFeedViewController ()

@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) NSDate *lastRefresh;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation PAPActivityFeedViewController

@synthesize settingsActionSheetDelegate;
@synthesize lastRefresh;
@synthesize blankTimelineView;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];    
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }

        // The number of objects to show per page
        self.objectsPerPage = 15;
        
        self.showHudForLoading = YES;
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];    
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;

    UIButton *logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoButton.frame = CGRectMake(0, 0, 90, 40);
    logoButton.backgroundColor = [UIColor clearColor];
    [logoButton setImage:[UIImage imageNamed:@"toolbar.logo.png"] forState:UIControlStateNormal];
    [logoButton addTarget:self action:@selector(didTapLogoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = logoButton;
    self.navigationItem.titleView.alpha = 0.9;

    // Add Settings button
    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveRemoteNotification:) name:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(24.0f, 113.0f, 270.0f, 144.0f)];
    containerView.backgroundColor = [UIColor clearColor];
    UILabel* messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f, 100.0f)];
    messageLabel.numberOfLines = 0;
    messageLabel.text = NSLocalizedString(@"activity.blank.message", nil);
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont italicSystemFontOfSize:24];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview: messageLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(35.0f, 100.0f, 200.0f, 44.0f);
    button.backgroundColor = [UIColor whiteColor];
    button.alpha = 0.9f;
    button.layer.cornerRadius = 5.0;
    [button setTitle:NSLocalizedString(@"activity.blank.button.title", nil) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button];

    [self.blankTimelineView addSubview:containerView];

    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];

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
        PFObject *object = (self.objects)[indexPath.row];
        NSString *activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[object objectForKey:kPAPActivityTypeKey]];
        
        if ([(NSString*)[object objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypePriceDrop]) {
            activityString = [PAPUtility priceDropToString:[object objectForKey:kPAPActivityContentKey] withActivityString:activityString];
        }
        
        PFUser *user = (PFUser*)[object objectForKey:kPAPActivityFromUserKey];
        NSString *nameString = NSLocalizedString(@"activity.user.noname", nil);
        if (user && [user objectForKey:kPAPUserDisplayNameKey] && [[user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
            nameString = [user objectForKey:kPAPUserDisplayNameKey];
        }
        
        CGFloat h = [PAPActivityCell heightForCellWithName:nameString contentString:activityString];
        if(h<58.0) //fix min cell height
            return 58.0;
        else
            return h;
    } else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.objects.count) {
        PFObject *activity = (self.objects)[indexPath.row];
        if ([activity objectForKey:kPAPActivityAppIDKey]) {
            if ([kPAPActivityTypePriceDrop isEqualToString:[activity objectForKey:kPAPActivityTypeKey]]) {
                PAApp* app = [activity objectForKey:kPAPActivityAppIDKey];
                PAApp* newApp = [PAApp createNewAppFromExistingApp:app];
                [newApp existsInUserCountryAppStore:^(BOOL succeeded, NSError *error) {
                    if(!newApp.inCountryAppStore)
                    {
                        [PAPErrorHandler handleErrorMessage:@"badges.warning.appNotInCountry" titleKey:@"error.generic.warning"];
                        return;
                    }
                    PAPEditAppViewController *editViewController = [[PAPEditAppViewController alloc] initWithApp:newApp];
                    editViewController.publishPriceDrop = YES;
                    
                    NSString *activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[activity objectForKey:kPAPActivityTypeKey]];
                    editViewController.priceDropText = [PAPUtility priceDropToString:[activity objectForKey:kPAPActivityContentKey] withActivityString:activityString];                    
                    
                    [self.navigationController pushViewController:editViewController animated:YES];
                }];
            }
            else{
                PAApp *app = [activity objectForKey:kPAPActivityAppIDKey];
                PAPAppDetailsViewController *detailViewController = [[PAPAppDetailsViewController alloc] initWithApp:app];
                [self.navigationController pushViewController:detailViewController animated:YES];
            }
        } else if ([activity objectForKey:kPAPActivityFromUserKey]) {
            PAPAccountViewController *detailViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [detailViewController setUser:[activity objectForKey:kPAPActivityFromUserKey]];
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
    } else if (self.paginationEnabled) {
        // load more
        [self loadNextPage];
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:kPAPActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kPAPActivityFromUserKey notEqualTo:[PFUser currentUser]];
    [query whereKeyExists:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityFromUserKey];
    [query includeKey:kPAPActivityAppIDKey];
    [query orderByDescending:@"createdAt"];

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

    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UITabBarItem *tabBarItem = [(self.tabBarController.viewControllers)[PAPActivityTabBarItemIndex] tabBarItem];
    
    if (self.objects.count == 0) {
        self.tableView.scrollEnabled = NO;
        tabBarItem.badgeValue = nil;

        if(![[UIApplication sharedApplication].delegate performSelector:@selector(isNetworkReachable)])
        {
            [PAPErrorHandler handleError:error titleKey:@"error.connection.title"];
            return;
        }
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
        
        NSUInteger unreadCount = 0;
        for (PFObject *activity in self.objects) {
            if ([lastRefresh compare:[activity createdAt]] == NSOrderedAscending && ![[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
                unreadCount++;
            }
        }
        
        if (unreadCount > 0) {
            tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)unreadCount];
        } else {
            tabBarItem.badgeValue = nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"ActivityCell";

    PAPActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PAPActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    else
    {
        cell.avatarImageView.profileID = nil;
    }
    
    [cell setActivity:object];

    if ([lastRefresh compare:[object createdAt]] == NSOrderedAscending) {
        [cell setIsNew:YES];
    } else {
        [cell setIsNew:NO];
    }
    if ([(NSString*)[object objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypePriceDrop]) {
        [cell setIsPriceDrop:YES];
    }
    else
    {
        [cell setIsPriceDrop:NO];
    }

    [cell hideSeparator:(indexPath.row == self.objects.count - 1)];

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
   }
    return cell;
}


#pragma mark - PAPActivityCellDelegate Methods

- (void)cell:(PAPActivityCell *)cellView didTapActivityButton:(PFObject *)activity {    
    // Get image associated with the activity
    PAApp *app = [activity objectForKey:kPAPActivityAppIDKey];
    
    NSDictionary *appParameters = @{SKStoreProductParameterITunesItemIdentifier : app.appId, SKStoreProductParameterAffiliateToken:kPGHAffiliate};
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


- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)user {
    // Push account view controller
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}


#pragma mark - PAPActivityFeedViewController

+ (NSString *)stringForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:kPAPActivityTypeLike]) {
        return NSLocalizedString(@"activity.message.like", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeFollow]) {
        return NSLocalizedString(@"activity.message.follow", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeComment]) {
        return NSLocalizedString(@"activity.message.comment", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypeJoined]) {
        return NSLocalizedString(@"activity.message.joined", nil);
    } else if ([activityType isEqualToString:kPAPActivityTypePriceDrop]) {
        return NSLocalizedString(@"activity.message.priceDrop", nil);
    } else {
        return nil;
    }
}


#pragma mark - ()

- (void)settingsButtonAction:(id)sender {
    [((PAANavigationController *)self.navigationController) showMenu];
}

- (void)inviteFriendsButtonAction:(id)sender {
    PAPFindFriendsViewController *detailViewController = [[PAPFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)applicationDidReceiveRemoteNotification:(NSNotification *)note {
    [self loadObjects];
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

-(void)didTapLogoButtonAction:(id)sender
{    
    if(!self.refreshControl.refreshing)
    {
        [self loadObjects];
        if(self.objects.count > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}


@end
