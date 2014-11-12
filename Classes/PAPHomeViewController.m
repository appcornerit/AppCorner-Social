//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPHomeViewController.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"
#import "PAPFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PAANavigationController.h"

@interface PAPHomeViewController ()
@property (nonatomic, strong) PAPSettingsActionSheetDelegate *settingsActionSheetDelegate;
@property (nonatomic, strong) UIView *blankTimelineView;
@end

@implementation PAPHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];    

    self.navigationItem.rightBarButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    
    UIButton *appsBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [appsBarButton setImage:[UIImage imageNamed:@"toolbar.appsDrawer.png"] forState:UIControlStateNormal];
    [appsBarButton setImage:[UIImage imageNamed:@"toolbar.appsDrawer.selected.png"] forState:UIControlStateHighlighted];
    
    [appsBarButton addTarget:self action:@selector(toggleAppsJumpBar:) forControlEvents:UIControlEventTouchUpInside];
    [appsBarButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:appsBarButton];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];

    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(24.0f, 113.0f, 270.0f, 144.0f)];
    containerView.backgroundColor = [UIColor clearColor];
    UILabel* messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f, 100.0f)];
    messageLabel.numberOfLines = 0;
    messageLabel.text = NSLocalizedString(@"home.blank.message", nil);
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont italicSystemFontOfSize:24];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview: messageLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(35.0f, 100.0f, 200.0f, 44.0f);
    button.backgroundColor = [UIColor whiteColor];
    button.alpha = 0.9f;
    button.layer.cornerRadius = 5.0;
    [button setTitle:NSLocalizedString(@"home.blank.button.title", nil) forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button];

    [self.blankTimelineView addSubview:containerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceivePurchaseRemoteNotification:) name:PAPAppDelegateApplicationDidReceivePurchaseRemoteNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAPAppDelegateApplicationDidReceivePurchaseRemoteNotification object:nil];
}

- (void)applicationDidReceivePurchaseRemoteNotification:(NSNotification *)note {
      NSError* error = nil;
     [[PFUser currentUser].dkEntity refresh:&error];
}

- (void)loadObjects{
    [PAPErrorHandler dismissMessage];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] resetAppPostNotificationCounter];
	[super loadObjects];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    if (self.objects.count == 0 && !self.firstLaunch) {
        self.tableView.scrollEnabled = NO;
        
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

-(BOOL) excludeCurrentUserAppsFromJumpBar
{
    return NO;
}

@end
