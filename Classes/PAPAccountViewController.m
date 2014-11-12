//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAccountViewController.h"
#import "PAPAppCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPLoadMoreCell.h"
#import "PAPSettingsButtonItem.h"
#import "PAPBackButtonItem.h"
#import "PAPProfileImageView.h"
#import "Country.h"

@interface PAPAccountViewController()
@property (nonatomic, strong) UIView *headerView;
@end

@implementation PAPAccountViewController
@synthesize headerView;
@synthesize user;

#pragma mark - Initialization

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"User cannot be nil"];
    }

    self.navigationItem.leftBarButtonItem = [[PAPBackButtonItem alloc] initWithTarget:self action:@selector(backButtonAction:)];
    //ios7 swipe back
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    //ios7 enable swipe back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 222.0f)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, app count, follower count, following count, and so on
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    
    PAPProfileImageView* profilePictureImageView = [[PAPProfileImageView alloc] initWithFrame:CGRectMake( 96.0f, 40.0f, 128.0f, 128.0f)];
    [profilePictureImageView setProfileID:[user objectForKey:kPAPUserFacebookIDKey]];
    [profilePictureImageView setHidePlaceholder:YES];
    
    [self.headerView addSubview:profilePictureImageView];

    UIButton* appsJumpBarButton = [[UIButton alloc]initWithFrame:CGRectMake( 26.0f, 104.0f, 45.0f, 37.0f)];
    [appsJumpBarButton setImage: [UIImage imageNamed:@"profile.appsDrawer.png"] forState:UIControlStateNormal];
    [appsJumpBarButton setImage:[UIImage imageNamed:@"profile.appsDrawer.selected.png"] forState:UIControlStateHighlighted];
    [appsJumpBarButton addTarget:self
               action:@selector(toggleAppsJumpBar:)
                forControlEvents:UIControlEventTouchUpInside];

    
    [self.headerView addSubview:appsJumpBarButton];
    
    UILabel *appCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 148.0f, 92.0f, 22.0f)];
    [appCountLabel setTextAlignment:NSTextAlignmentCenter];
    [appCountLabel setBackgroundColor:[UIColor clearColor]];
    [appCountLabel setTextColor:[UIColor whiteColor]];
    [appCountLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [self.headerView addSubview:appCountLabel];
  
    
    UILabel *followingCountLabel = nil;
    UILabel *followerCountLabel = nil;
    
    NSNumber* userInternal =[self.user objectForKey:kPAPUserInternal];
    if(!userInternal || ![userInternal boolValue]) //You can't unfollow internal user
    {
        UIImageView *followersIconImageView = [[UIImageView alloc] initWithImage:nil];
        [followersIconImageView setImage:[UIImage imageNamed:@"profile.followers.png"]];
        [followersIconImageView setFrame:CGRectMake( 247.0f, 100.0f, 52.0f, 37.0f)];
        [self.headerView addSubview:followersIconImageView];
        
        followerCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 144.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
        [followerCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followerCountLabel setBackgroundColor:[UIColor clearColor]];
        [followerCountLabel setTextColor:[UIColor whiteColor]];
        [followerCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.headerView addSubview:followerCountLabel];
        
        followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 226.0f, 160.0f, self.headerView.bounds.size.width - 226.0f, 16.0f)];
        [followingCountLabel setTextAlignment:NSTextAlignmentCenter];
        [followingCountLabel setBackgroundColor:[UIColor clearColor]];
        [followingCountLabel setTextColor:[UIColor whiteColor]];
        [followingCountLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [self.headerView addSubview:followingCountLabel];
    }
    
    UILabel *userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 176.0f, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentCenter];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor whiteColor]];
    [userDisplayNameLabel setText:[self.user objectForKey:@"displayName"]];
    [userDisplayNameLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [self.headerView addSubview:userDisplayNameLabel];
    
    [appCountLabel setText:@"0 apps"];
    
    PFQuery *queryAppCount = [PFQuery queryWithClassName:kPAPAppClassKey];
    [queryAppCount whereKey:kPAPAppUserKey equalTo:self.user];
    [queryAppCount setCachePolicy:kPFCachePolicyNetworkElseCache];
    [queryAppCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [appCountLabel setText:[NSString stringWithFormat:@"%d app%@", number, number==1?NSLocalizedString(@"account.label.app.singular", nil):NSLocalizedString(@"account.label.app.plural", nil)]];
            [[PAPCache sharedCache] setAppCount:@(number) user:self.user];
        }
    }];
    
    if(!userInternal || ![userInternal boolValue]) //You can't unfollow internal user
    {
        [followerCountLabel setText:NSLocalizedString(@"account.label.nofollowers",nil)];
        
        PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryFollowerCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryFollowerCount whereKey:kPAPActivityToUserKey equalTo:self.user];
        [queryFollowerCount setCachePolicy:kPFCachePolicyNetworkElseCache];
        [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                [followerCountLabel setText:[NSString stringWithFormat:@"%d %@%@", number,NSLocalizedString(@"account.label.numfollower", nil), number==1?NSLocalizedString(@"account.label.numfollower.singular", nil):NSLocalizedString(@"account.label.numfollower.plural", nil)]];
            }
        }];

        [followingCountLabel setText:NSLocalizedString(@"account.label.nofollowing",nil)];
        
        PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kPAPActivityClassKey];
        [queryFollowingCount whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
        [queryFollowingCount whereKey:kPAPActivityFromUserKey equalTo:self.user];
        [queryFollowingCount setCachePolicy:kPFCachePolicyNetworkElseCache];
        [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                NSArray* array = [[Country currentCountry] objectForKey:kPAPCountryAutoFollowFacebookIds];
                NSInteger count = number-array.count;
                [followingCountLabel setText:[NSString stringWithFormat:@"%lu %@", count>0?count:0, NSLocalizedString(@"account.label.numfollowing", nil)]];
            }
        }];

        if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [loadingActivityIndicatorView startAnimating];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
            
            // check if the currentUser is following this user
            PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kPAPActivityClassKey];
            [queryIsFollowing whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
            [queryIsFollowing whereKey:kPAPActivityToUserKey equalTo:self.user];
            [queryIsFollowing whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
            [queryIsFollowing setCachePolicy:kPFCachePolicyNetworkElseCache];
            [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error && [error code] != kPFErrorCacheMiss) {
                    NSLog(@"Couldn't determine follow relationship: %@", error);
                    self.navigationItem.rightBarButtonItem = nil;
                } else {
                    if (number == 0) {
                        [self configureFollowButton];
                    } else {
                        [self configureUnfollowButton];
                    }
                }
            }];
        }
    }
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isNetworkReachable)]) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kPAPAppUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kPAPAppUserKey];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        cell.separatorImageTop.image = [UIImage imageNamed:@"common.separator.png"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureUnfollowButton];

    [PAPUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];
        }
        else
        {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];

    [self configureFollowButton];

    [PAPUtility unfollowUserEventually:self.user];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPUtilityUserFollowingChangedNotification object:nil];    
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureFollowButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"account.button.follow",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(followButtonAction:)];
    [[PAPCache sharedCache] setFollowStatus:NO user:self.user];
}

- (void)configureUnfollowButton {
    NSNumber* userInternal =[self.user objectForKey:kPAPUserInternal];
    if(!userInternal || ![userInternal boolValue]) //You can't unfollow internal user
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"account.button.unfollow",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowButtonAction:)];
        [[PAPCache sharedCache] setFollowStatus:YES user:self.user];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (NSString*) getAppsJumpBarTitle
{
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return [NSString stringWithFormat: NSLocalizedString(@"appJumpBar.title.account", nil),[self.user objectForKey:@"displayName"]];
    }
    return NSLocalizedString(@"appJumpBar.title.account.me", nil);
}


@end