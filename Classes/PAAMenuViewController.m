//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAAMenuViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "PAPAccountViewController.h"
#import "PAPFindFriendsViewController.h"
#import "AppDelegate.h"
#import "PAPProfileImageView.h"
#import "Country.h"

@implementation PAAMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.bounces = NO;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.tableHeaderView = ({
        
        CGFloat modifierHeight = 0.0f;
        if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
            //iPhone 5
            modifierHeight = 1.0f;
        }
        else
        {
            modifierHeight = -2.0f;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 110.0f+modifierHeight)];
        
        PAPProfileImageView* profilePictureImageView = [[PAPProfileImageView alloc] initWithFrame:CGRectMake( 0.0f, 10.0f-modifierHeight, 100.0f, 100.0f)];
        [profilePictureImageView setProfileID:[[PFUser currentUser] objectForKey:kPAPUserFacebookIDKey]];
        [profilePictureImageView setHidePlaceholder:YES];
        profilePictureImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UIButton * button = [[UIButton alloc]initWithFrame:profilePictureImageView.frame];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(openAccount) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:profilePictureImageView];
        [view addSubview:button];
        view;
    });
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    label.text = [NSLocalizedString(@"settings.sheet.title", nil) uppercaseString];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    UIViewController* mainController = navigationController.visibleViewController;
    if (indexPath.section == 0 && indexPath.row == 0) {
            [self openAccount];
    }else if (indexPath.section == 0 && indexPath.row == 1) {
            PAPFindFriendsViewController *findFriendsVC = [[PAPFindFriendsViewController alloc] initWithStyle:UITableViewStylePlain];
            navigationController.viewControllers = @[mainController,findFriendsVC];
            [self.frostedViewController hideMenuViewController];
    }else if (indexPath.section == 0 && indexPath.row == 2) {
        // Log out user and present the login view controller
        [self.frostedViewController hideMenuViewController];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.generic.warning",nil) message:NSLocalizedString(@"logout.confirm.message",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.generic.dismiss",nil),NSLocalizedString(@"settings.sheet.logOut", nil), nil];
        alert.tag = 100;
        [alert show];
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        //iPhone 5
        return 59.0;
    }
    else
    {
        return 45.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
    {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryView = nil;
    cell.textLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"Cochin-BoldItalic" size:18];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (indexPath.section == 0) {
        NSArray *titles = @[NSLocalizedString(@"settings.sheet.profile", nil) , NSLocalizedString(@"settings.sheet.findFriends", nil), NSLocalizedString(@"settings.sheet.logOut", nil)];
        cell.textLabel.text = titles[indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Cochin-BoldItalic" size:20];
        if(indexPath.row == 2)
        {
            cell.textLabel.textColor = [UIColor colorWithRed:255/255.0f green:45/255.0f blue:85/255.0f alpha:1.0f];
        }
    } else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        cell.textLabel.text = NSLocalizedString(@"settings.sheet.saveAppPicker",nil);
        UISwitch * switchPromotion = [[UISwitch alloc] initWithFrame:CGRectMake(0,10,50,30)];
        switchPromotion.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"save_picker_app"];
        [switchPromotion addTarget:self action:@selector(setStateAppPicker:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchPromotion;
    }
    
    return cell;
}

- (void)setState:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"enabled_sponsored_app"];
    if([sender isOn])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.generic.warning",nil) message:NSLocalizedString(@"settings.country.message",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.generic.close",nil), nil];
        [alert show];
    }
}

- (void)setStateAppPicker:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:@"save_picker_app"];
}
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 0)
        {
            // Yes, do nothing
        }
        else if (buttonIndex == 1)
        {
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        }
    }
}

-(void)openAccount
{
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    UIViewController* mainController = navigationController.visibleViewController;
    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:[PFUser currentUser]];
    navigationController.viewControllers = @[mainController,accountViewController];
    [self.frostedViewController hideMenuViewController];
}


@end
