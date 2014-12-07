//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppTimelineViewController.h"
#import "PAPAppCell.h"
#import "PAPAccountViewController.h"
#import "PAPAppDetailsViewController.h"
#import "PAPUtility.h"
#import "PAPLoadMoreCell.h"
#import "PAPEditAppViewController.h"

@interface PAPAppTimelineViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSMutableSet *reusableSectionFooterViews;
@property (nonatomic, strong) NSMutableDictionary *outstandingSectionHeaderQueries;

@property (nonatomic, strong) POHorizontalList* appsJumpBar;
@end

@implementation PAPAppTimelineViewController
@synthesize reusableSectionHeaderViews;
@synthesize reusableSectionFooterViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPTabBarControllerDidFinishEditingAppNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDetailsViewControllerUserLikedUnlikedAppNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPUtilityUserLikedUnlikedAppCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDetailsViewControllerUserCommentedOnAppNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDetailsViewControllerUserDeletedAppNotification object:nil];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kPAPAppClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;

        // Whether the built-in pull-to-refresh is enabled
        if (NSClassFromString(@"UIRefreshControl")) {
            self.pullToRefreshEnabled = NO;
        } else {
            self.pullToRefreshEnabled = YES;
        }

        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers/footers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        self.reusableSectionFooterViews = [NSMutableSet setWithCapacity:3];
        
        self.shouldReloadOnAppear = NO;

    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 90, 40);
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:@"toolbar.logo.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapLogoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = button;
    self.navigationItem.titleView.alpha = 0.9;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]];
    self.tableView.backgroundView = texturedBackgroundView;

    if (NSClassFromString(@"UIRefreshControl")) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl = refreshControl;
        self.refreshControl.tintColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        [self.refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
        self.pullToRefreshEnabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishApp:) name:PAPTabBarControllerDidFinishEditingAppNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:PAPUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeleteApp:) name:PAPAppDetailsViewControllerUserDeletedAppNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikeApp:) name:PAPAppDetailsViewControllerUserLikedUnlikedAppNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikeApp:) name:PAPUtilityUserLikedUnlikedAppCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnApp:) name:PAPAppDetailsViewControllerUserCommentedOnAppNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(self.appsJumpBar)
    {
        [self.appsJumpBar removeFromSuperview];
        self.appsJumpBar = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    if (self.paginationEnabled && sections != 0 && self.hasMore)
        sections++;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView customViewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }

    PAPAppHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    PAApp *app = (self.objects)[section];
    
    if (!headerView) {
        headerView = [[PAPAppHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:PAPAppHeaderButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    
    PFUser* appUser = [app objectForKey:kPAPAppUserKey];
    NSNumber* internal = [appUser objectForKey:kPAPUserInternal];
    BOOL boolInternal = (internal && [internal boolValue]);
    headerView.likeButton.hidden = boolInternal;
    headerView.commentButton.hidden = boolInternal;
    
    [headerView setApp:app];
    headerView.tag = section;
    [headerView.likeButton setTag:section];
    
    NSDictionary *attributesForApp = [[PAPCache sharedCache] attributesForApp:app];

    if (attributesForApp) {
        [headerView setLikeStatus:[[PAPCache sharedCache] isAppLikedByCurrentUser:app]];
        [headerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForApp:app] description] forState:UIControlStateNormal];
        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForApp:app] description] forState:UIControlStateNormal];
        
        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.200f animations:^{
                headerView.likeButton.alpha = 1.0f;
                headerView.commentButton.alpha = 1.0f;
            }];
        }
    } else {
        headerView.likeButton.alpha = 0.0f;
        headerView.commentButton.alpha = 0.0f;
        
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionHeaderQueryStatus = (self.outstandingSectionHeaderQueries)[[NSNumber numberWithInt:section]];
            if (!outstandingSectionHeaderQueryStatus) {
                PFQuery *query = [PAPUtility queryForActivitiesOnApp:app cachePolicy:kPFCachePolicyNetworkOnly];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:[NSNumber numberWithInt:section]];

                        if (error) {
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
                        
                        if (headerView.tag != section) {
                            return;
                        }
                        
                        [headerView setLikeStatus:[[PAPCache sharedCache] isAppLikedByCurrentUser:app]];
                        [headerView.likeButton setTitle:[[[PAPCache sharedCache] likeCountForApp:app] description] forState:UIControlStateNormal];
                        [headerView.commentButton setTitle:[[[PAPCache sharedCache] commentCountForApp:app] description] forState:UIControlStateNormal];
                        
                        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.200f animations:^{
                                headerView.likeButton.alpha = 1.0f;
                                headerView.commentButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }            
        }
    }
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView customViewForFooterInSection:(NSInteger)section {
    if (section >= self.objects.count) {
        // Load More section
        return nil;
    }
    
    PAPAppFooterView *footerView = [self dequeueReusableSectionFooterView];
    
    if (!footerView) {
        footerView = [[PAPAppFooterView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 60.0f)];
        footerView.delegate = self;
        [self.reusableSectionFooterViews addObject:footerView];
    }
    
    PAApp *app = (self.objects)[section];
    [footerView setApp:app];
    footerView.tag = section;    
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.objects.count) {
        // Load More Section
        return 44.0f;
    }
    return mainImageHeight + (44*2.0)+16.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == self.objects.count && self.paginationEnabled) {
        // Load More Cell
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
    
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kPAPActivityClassKey];
    [followingActivitiesQuery whereKey:kPAPActivityTypeKey equalTo:kPAPActivityTypeFollow];
    [followingActivitiesQuery whereKey:kPAPActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *appsFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [appsFromFollowedUsersQuery whereKey:kPAPAppUserKey matchesKey:kPAPActivityToUserKey inQuery:followingActivitiesQuery];

    PFQuery *appsFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [appsFromCurrentUserQuery whereKey:kPAPAppUserKey equalTo:[PFUser currentUser]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[appsFromFollowedUsersQuery, appsFromCurrentUserQuery]];
    [query includeKey:kPAPAppUserKey];
    [query orderByDescending:@"createdAt"];

    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isNetworkReachable)]) {    
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }

    self.showHudForLoading = self.objects.count == 0;

    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (NSClassFromString(@"UIRefreshControl")) {
        [self.refreshControl endRefreshing];
    }
    
    if(self.appsJumpBar){
        self.appsJumpBar.excludeCurrentUserApps = [self excludeCurrentUserAppsFromJumpBar];
        self.appsJumpBar.pAAppItems = self.objects;
    }
    self.showHudForLoading = self.objects.count == 0;    
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return (self.objects)[indexPath.section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == self.objects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        if (indexPath.section == self.objects.count && self.paginationEnabled && self.autoScrollLoad) {
            // Load More Cell
            [self loadNextPage];
        }
        return cell;
    } else {
        PAPAppCell *cell = (PAPAppCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = [[PAPAppCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.headView = [self tableView:tableView customViewForHeaderInSection:indexPath.section];
        cell.footView = [self tableView:tableView customViewForFooterInSection:indexPath.section];
        
        cell.appButton.tag = indexPath.section;
        cell.app = ((PAApp*)object);
        
        return cell;
    }
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

#pragma mark - PAPAppTimelineViewController

- (PAPAppHeaderView *)dequeueReusableSectionHeaderView {
    for (PAPAppHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            sectionHeaderView.avatarImageView.profileID = nil;
            return sectionHeaderView;
        }
    }
    
    return nil;
}

- (PAPAppFooterView *)dequeueReusableSectionFooterView {
    for (PAPAppFooterView *sectionFooterView in self.reusableSectionFooterViews) {
        if (!sectionFooterView.superview) {
            // we found a section footer that is no longer visible
            return sectionFooterView;
        }
    }
    
    return nil;
}

#pragma mark - PAPAppHeaderViewDelegate

- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    if([self isKindOfClass:[PAPAccountViewController class]] && [[user objectId] isEqualToString:[((PAPAccountViewController*)self).user objectId]])
    {
        return;
    }
    
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapLikeAppButton:(UIButton *)button app:(PAApp *)app {
    [appHeaderView shouldEnableLikeButton:NO];
    
    BOOL liked = !button.selected;
    [appHeaderView setLikeStatus:liked];
    
    NSString *originalButtonTitle = button.titleLabel.text;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    NSNumber *likeCount = [numberFormatter numberFromString:button.titleLabel.text];
    if (liked) {
        likeCount = @([likeCount intValue] + 1);
        [[PAPCache sharedCache] incrementLikerCountForApp:app];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = @([likeCount intValue] - 1);
        }
        [[PAPCache sharedCache] decrementLikerCountForApp:app];
    }
    
    [[PAPCache sharedCache] setAppIsLikedByCurrentUser:app liked:liked];
    
    [button setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    
    if (liked) {
        [PAPUtility likeAppInBackground:app block:^(BOOL succeeded, NSError *error) {
            PAPAppHeaderView *actualHeaderView = (PAPAppHeaderView *)[self tableView:self.tableView customViewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:succeeded];
            
            if (!succeeded) {
                [PAPErrorHandler handleError:error titleKey:nil];
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];                
            }
            else{
//               [PAPErrorHandler handleSuccess:@"message.action.like"];                
            }
        }];
    } else {
        [PAPUtility unlikeAppInBackground:app block:^(BOOL succeeded, NSError *error) {
            PAPAppHeaderView *actualHeaderView = (PAPAppHeaderView *)[self tableView:self.tableView customViewForHeaderInSection:button.tag];
            [actualHeaderView shouldEnableLikeButton:YES];
            [actualHeaderView setLikeStatus:!succeeded];
            
            if (!succeeded) {
                [PAPErrorHandler handleError:error titleKey:nil];
                [actualHeaderView.likeButton setTitle:originalButtonTitle forState:UIControlStateNormal];      
            }
        }];
    }
}

- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapCommentOnAppButton:(UIButton *)button  app:(PAApp *)app {
    PAPAppDetailsViewController *appDetailsVC = [[PAPAppDetailsViewController alloc] initWithApp:app];
    if([self isKindOfClass:[PAPAccountViewController class]])
    {
        appDetailsVC.openedFromAccount = YES;
        appDetailsVC.openedFromUserAccount = ((PAPAccountViewController*)self).user;
    }
    [self.navigationController pushViewController:appDetailsVC animated:YES];
}

#pragma mark - PAPAppFooterViewDelegate

- (void)appFooterView:(PAPAppFooterView *)appFooterView didTapAppButton:(UIButton *)button app:(PAApp *)app
{
    if (app) {
        NSDictionary *appParameters = @{SKStoreProductParameterITunesItemIdentifier : app.appId,
                                        SKStoreProductParameterAffiliateToken:kPGHAffiliate,
                                        SKStoreProductParameterCampaignToken:[[NSBundle mainBundle] bundleIdentifier]};
        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
        [productViewController setDelegate:self];
        [productViewController loadProductWithParameters:appParameters completionBlock:nil];
#if TARGET_IPHONE_SIMULATOR
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot open App Store on simulator" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Cancel", nil];
        [alert show];
#else
        [self presentViewController:productViewController
                           animated:YES
                         completion:nil];
#endif
    }
}
- (void)appFooterView:(PAPAppFooterView *)appFooterView didTapShareButton:(UIButton *)button app:(PAApp *)app
{
    PAApp* newApp = [PAApp createNewAppFromExistingApp:app];
    [newApp existsInUserCountryAppStore:^(BOOL succeeded, NSError *error) {
        if(!newApp.inCountryAppStore)
        {
            [PAPErrorHandler handleErrorMessage:@"badges.warning.appNotInCountry" titleKey:@"error.generic.warning"];
            return;
        }
        PAPEditAppViewController* editViewController = [[PAPEditAppViewController alloc] initWithApp:newApp];
        [self.navigationController pushViewController:editViewController animated:YES];
    }];
}

#pragma mark- Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
    for (int i = 0; i < self.objects.count; i++) {
        PFObject *object = (self.objects)[i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    
    return nil;
}

- (void)userDidLikeOrUnlikeApp:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnApp:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeleteApp:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishApp:(NSNotification *)note {
    if (self.objects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    NSLog(@"User following changed.");
    self.shouldReloadOnAppear = YES;
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
}

#pragma mark - POHorizontalListDelegate

- (void) didSelectApp:(PAApp *)app
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.objects indexOfObject:app]];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    if(self.appsJumpBar.isOpen){
        [self toggleAppsJumpBar:self];
    }
}

- (NSString*) getAppsJumpBarTitle
{
    return NSLocalizedString(@"appJumpBar.title.home",nil);
}

- (void) toggleAppsJumpBar:(id)sender
{
    if(!self.appsJumpBar)
    {
        self.appsJumpBar = [[NSBundle mainBundle] loadNibNamed:@"POHorizontalList" owner:self options:nil][0];
        CGRect frame = self.appsJumpBar.frame;
        self.appsJumpBar.offsetY = 0.0f;
        frame.origin.y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
        self.appsJumpBar.frame = frame;
        [self.appsJumpBar setupViewWithParentView:self.view];
        self.appsJumpBar.titleLabel.text = [self getAppsJumpBarTitle];
        self.appsJumpBar.delegate = self;
        
        self.appsJumpBar.excludeCurrentUserApps = [self excludeCurrentUserAppsFromJumpBar];
        self.appsJumpBar.pAAppItems = self.objects;
        
        [self.view addSubview:self.appsJumpBar];
        [self.appsJumpBar togglePanel:sender];
    }
    else
    {
        [self.appsJumpBar togglePanel:sender withCompletionBlock:^(BOOL isOpen) {
            if(!isOpen)
            {
                [self.appsJumpBar removeFromSuperview];
                self.appsJumpBar = nil;
            }
        }];
    }
}

-(BOOL) excludeCurrentUserAppsFromJumpBar
{
    return NO;
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