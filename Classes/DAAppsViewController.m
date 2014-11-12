//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "DAAppsViewController.h"
#import "DAAppViewCell.h"
#import "PAAppStoreQuery.h"
#import "RSSParser.h"
#import "MBProgressHUD.h"
#import "PAPLoadMoreCell.h"
#import "Sync.h"
#import "PAPiTunesCountry.h"

#define DARK_BACKGROUND_COLOR   [UIColor colorWithWhite:235.0f/255.0f alpha:1.0f]
#define LIGHT_BACKGROUND_COLOR  [UIColor colorWithWhite:245.0f/255.0f alpha:1.0f]

@interface DAAppsViewController () <NSURLConnectionDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSArray *appsArray;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet AMBlurView *buttonsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *menuRanking;
@property (weak, nonatomic) IBOutlet UIButton *menuGenre;
@property (weak, nonatomic) IBOutlet UIButton *menuCountry;
@property (weak, nonatomic) IBOutlet UIView *placeholderGenre;
@property (weak, nonatomic) IBOutlet UIView *placeholderRanking;
@property (weak, nonatomic) IBOutlet UIView *placeholderCountry;

@property (strong, nonatomic) PAPMenuTableViewController *panelRanking;
@property (strong, nonatomic) PAPMenuTableViewController *panelGenre;
@property (strong, nonatomic) PAPMenuTableViewController *panelCountry;

@property (strong, nonatomic) NSArray* rankingTypeItems;
@property (strong, nonatomic) NSArray* rankingTypeValues;
@property (strong, nonatomic) NSArray* genreItems;
@property (strong, nonatomic) NSArray* genreValues;
@property (strong, nonatomic) NSMutableArray* countryItems;
@property (strong, nonatomic) NSArray* countryValues;

@property (assign, nonatomic) BOOL disableMenuLoading;
    
@property (nonatomic, strong) UIView *blankView;

- (IBAction)toggleMenuPanel:(id)sender;

@end

@implementation DAAppsViewController
{
    NSInteger menuRankingSelectedIndex;
    NSInteger menuGenreSelectedIndex;
    NSInteger menuCountrySelectedIndex;
    BOOL dataWithSearchTerm;
}

#pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]]];
    self.tableView.backgroundView = texturedBackgroundView;
    [self.navigationItem setHidesBackButton:YES];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.buttonsContainerView.frame.size.height, 0.0, 0.0, 0.0);
    
    self.searchBar.placeholder = NSLocalizedString(@"appPicker.search.placeholder",nil);
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.generic.close",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonAction:)];
    
    //ios7 disable swipe back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.tableView.rowHeight = 83.0f;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.rankingTypeItems = @[
        NSLocalizedString(@"appPicker.ranking.topfreeapplications",@"Top Free Apps"),
        NSLocalizedString(@"appPicker.ranking.toppaidapplications",@"Top Paid Apps"),
        NSLocalizedString(@"appPicker.ranking.topgrossingapplications",@"Top Grossing Apps"),
        NSLocalizedString(@"appPicker.ranking.newfreeapplications",@"New Free Applications"),
        NSLocalizedString(@"appPicker.ranking.newpaidapplications",@"New Paid Applications")];
    
    self.rankingTypeValues = @[@"topfreeapplications",@"toppaidapplications",@"topgrossingapplications",@"newfreeapplications",@"newpaidapplications"];
    
    self.genreItems = @[
        NSLocalizedString(@"appPicker.genre.all",@"All Genres"),
        NSLocalizedString(@"appPicker.genre.6018",@"Books"),
        NSLocalizedString(@"appPicker.genre.6000",@"Business"),
        NSLocalizedString(@"appPicker.genre.6022",@"Catalogs"),
        NSLocalizedString(@"appPicker.genre.6017",@"Education"),
        NSLocalizedString(@"appPicker.genre.6016",@"Entertainment"),
        NSLocalizedString(@"appPicker.genre.6015",@"Finance"),
        NSLocalizedString(@"appPicker.genre.6023",@"Food & Drink"),
        NSLocalizedString(@"appPicker.genre.6014",@"Games"),
        NSLocalizedString(@"appPicker.genre.6013",@"Health & Fitness"),
        NSLocalizedString(@"appPicker.genre.6012",@"Lifestyle"),
        NSLocalizedString(@"appPicker.genre.6020",@"Medical"),
        NSLocalizedString(@"appPicker.genre.6011",@"Music"),
        NSLocalizedString(@"appPicker.genre.6010",@"Navigation"),
        NSLocalizedString(@"appPicker.genre.6009",@"News"),
        NSLocalizedString(@"appPicker.genre.6021",@"Newsstand"),
        NSLocalizedString(@"appPicker.genre.6008",@"Photo & Video"),
        NSLocalizedString(@"appPicker.genre.6007",@"Productivity"),
        NSLocalizedString(@"appPicker.genre.6006",@"Reference"),
        NSLocalizedString(@"appPicker.genre.6005",@"Social Networking"),
        NSLocalizedString(@"appPicker.genre.6004",@"Sports"),
        NSLocalizedString(@"appPicker.genre.6003",@"Travel"),
        NSLocalizedString(@"appPicker.genre.6002",@"Utilities"),
        NSLocalizedString(@"appPicker.genre.6001",@"Weather")];
    
    
    self.genreValues = @[@""         ,@"6018" ,@"6000"    ,@"6022"    ,@"6017"     ,@"6016"         ,@"6015"
                        ,@"6023"       ,@"6014" ,@"6013"            ,@"6012"     ,@"6020"   ,@"6011" ,@"6010"      ,@"6009",@"6021"     ,@"6008"
                        ,@"6007"       ,@"6006"     ,@"6005"             ,@"6004"  ,@"6003"  ,@"6002"     ,@"6001"];
    
    
    self.countryItems = [[NSMutableArray alloc]init];
    self.countryValues = @[@"AL",@"DZ",@"AO",@"AI",@"AG",@"AR",@"AM",@"AU",@"AT",@"AZ",@"BS",@"BH",@"BB",@"BY",@"BE",@"BZ",@"BJ",@"BM",@"BT",@"BO",@"BW",@"BR",@"VG",@"BN",@"BG",@"BF",@"KH",@"CA",@"CV",@"KY",@"TD",@"CL",@"CN",@"CO",@"CG",@"CR",@"HR",@"CY",@"CZ",@"DK",@"DM",@"DO",@"EC",@"EG",@"SV",@"EE",@"FJ",@"FI",@"FR",@"GM",@"DE",@"GH",@"GR",@"GD",@"GT",@"GW",@"GY",@"HN",@"HK",@"HU",@"IS",@"IN",@"ID",@"IE",@"IL",@"IT",@"JM",@"JP",@"JO",@"KZ",@"KE",@"KR",@"KW",@"KG",@"LA",@"LV",@"LB",@"LR",@"LT",@"LU",@"MO",@"MK",@"MG",@"MW",@"MY",@"ML",@"MT",@"MR",@"MU",@"MX",@"FM",@"MD",@"MN",@"MS",@"MZ",@"NA",@"NP",@"NL",@"NZ",@"NI",@"NE",@"NG",@"NO",@"OM",@"PK",@"PW",@"PA",@"PG",@"PY",@"PE",@"PH",@"PL",@"PT",@"QA",@"RO",@"RU",@"ST",@"SA",@"SN",@"SC",@"SL",@"SG",@"SK",@"SI",@"SB",@"ZA",@"ES",@"LK",@"KN",@"LC",@"VC",@"SR",@"SZ",@"SE",@"CH",@"TW",@"TJ",@"TZ",@"TH",@"TT",@"TN",@"TR",@"TM",@"TC",@"UG",@"GB",@"UA",@"AE",@"UY",@"US",@"UZ",@"VE",@"VN",@"YE",@"ZW"];
    
    NSInteger countryIndex = 0;
    NSString *countryCode = [[PAPiTunesCountry getStoreCountryForCurrenUser] uppercaseString];
    for (NSInteger i = 0; i < self.countryValues.count; i++) {
        NSString* country = self.countryValues[i];
        if([country isEqualToString:countryCode]){
            countryIndex = i;
        }                    
        [self.countryItems addObject: [NSString stringWithFormat:@"%@.png",[country uppercaseString]]];
    }
    
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
    } else {
        CGRect pCou = self.placeholderCountry.frame;
        CGRect pGen = self.placeholderGenre.frame;
        pCou.size.height -= 88;
        pGen.size.height -= 88;
        self.placeholderCountry.frame = pCou;
        self.placeholderGenre.frame = pGen;
    }

    self.panelRanking = [[PAPMenuTableViewController alloc]initWithNibName:nil bundle:nil];
    self.panelRanking.type = kPAPMenuPickerTypeRanking;
    self.panelRanking.openDirection = kPAPMenuOpenDirectionRight;
    self.panelRanking.items = self.rankingTypeItems;
    self.panelRanking.values = self.rankingTypeValues;
    self.panelRanking.delegate = self;
    [self.view insertSubview:self.panelRanking.view belowSubview:self.buttonsContainerView];
    CGFloat itemsHeight = self.rankingTypeItems.count*menuItemHeight;
    if(itemsHeight < self.placeholderRanking.frame.size.height)
    {
        CGRect frame = self.placeholderRanking.frame;
        frame.size.height = itemsHeight;
        self.placeholderRanking.frame = frame;
    }
    self.panelRanking.closeOffset = self.menuCountry.frame.size.height;
    self.panelRanking.openFrame = self.placeholderRanking.frame;
    self.panelRanking.backgroundAreaDismissRect = self.tableView.frame;
    
    self.panelCountry = [[PAPMenuTableViewController alloc]initWithNibName:nil bundle:nil];
    self.panelCountry.type = kPAPMenuPickerTypeCountry;
    self.panelCountry.openDirection = kPAPMenuOpenDirectionDown;
    self.panelCountry.items = self.countryItems;
    self.panelCountry.values = self.countryValues;
    self.panelCountry.delegate = self;
    [self.view insertSubview:self.panelCountry.view belowSubview:self.buttonsContainerView];
    itemsHeight = self.countryItems.count*menuItemHeight;
    if(itemsHeight < self.placeholderCountry.frame.size.height)
    {
        CGRect frame = self.placeholderCountry.frame;
        frame.size.height = itemsHeight;
        self.placeholderCountry.frame = frame;
    }
    self.panelCountry.closeOffset = self.menuCountry.frame.size.height;
    self.panelCountry.openFrame = self.placeholderCountry.frame;
    self.panelCountry.backgroundAreaDismissRect = self.tableView.frame;
    
    self.panelGenre = [[PAPMenuTableViewController alloc]initWithNibName:nil bundle:nil];
    self.panelGenre.type = kPAPMenuPickerTypeGenre;
    self.panelGenre.openDirection = kPAPMenuOpenDirectionLeft;
    self.panelGenre.items = self.genreItems;
    self.panelGenre.values = self.genreValues;
    self.panelGenre.delegate = self;
    [self.view insertSubview:self.panelGenre.view belowSubview:self.buttonsContainerView];
    itemsHeight = self.genreItems.count*menuItemHeight;
    if(itemsHeight < self.placeholderGenre.frame.size.height)
    {
        CGRect frame = self.placeholderGenre.frame;
        frame.size.height = itemsHeight;
        self.placeholderGenre.frame = frame;
    }
    self.panelGenre.closeOffset = self.menuCountry.frame.size.height;
    self.panelGenre.openFrame = self.placeholderGenre.frame;
    self.panelGenre.backgroundAreaDismissRect = self.tableView.frame;
    
    NSDictionary *defaultUserDefaults = @{@"save_picker_ranking": @-1,
                                         @"save_picker_genre": @-1,
                                         @"save_picker_country": @-1,
                                         @"save_picker_text": @""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultUserDefaults];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"save_picker_app"])
    {
        NSInteger ranking = [[NSUserDefaults standardUserDefaults] integerForKey:@"save_picker_ranking"];
        NSInteger genre = [[NSUserDefaults standardUserDefaults] integerForKey:@"save_picker_genre"];
        NSInteger country = [[NSUserDefaults standardUserDefaults] integerForKey:@"save_picker_country"];
        NSString* searchText = [[NSUserDefaults standardUserDefaults] stringForKey:@"save_picker_text"];
        NSString *trimmedSearchText = @"";
        if(searchText)
        {
            trimmedSearchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    
        if(ranking < 0 || ranking >= self.rankingTypeItems.count)
        {
            ranking = 0;
        }
        if(genre < 0 || genre >= self.genreItems.count)
        {
            genre = 0;
        }
        if(country < 0 || country >= self.countryItems.count)
        {
            country = countryIndex;
        }
        
        
        self.disableMenuLoading = YES;
        [self valueSelectedAtIndex:ranking forType:kPAPMenuPickerTypeRanking];
        [self valueSelectedAtIndex:genre forType:kPAPMenuPickerTypeGenre];
        if([trimmedSearchText isEqualToString:@""])
        {
            self.disableMenuLoading = NO;
        }
        [self valueSelectedAtIndex:country forType:kPAPMenuPickerTypeCountry];
        if(![trimmedSearchText isEqualToString:@""])
        {
            self.searchBar.text = trimmedSearchText;
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
    else
    {    
        self.disableMenuLoading = YES;
        [self valueSelectedAtIndex:0 forType:kPAPMenuPickerTypeRanking];
        [self valueSelectedAtIndex:0 forType:kPAPMenuPickerTypeGenre];
        self.disableMenuLoading = NO;
        [self valueSelectedAtIndex:countryIndex forType:kPAPMenuPickerTypeCountry];
    }

    self.blankView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(24.0f, 113.0f, 270.0f, 144.0f)];
    containerView.backgroundColor = [UIColor clearColor];
    UILabel* messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f, 100.0f)];
    messageLabel.numberOfLines = 0;
    messageLabel.text = NSLocalizedString(@"apppicker.blank.message", nil);
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont italicSystemFontOfSize:24];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview: messageLabel];
    [self.blankView addSubview:containerView];
    
}

- (void) dealloc
{
    self.panelGenre.delegate = nil;
    self.panelCountry.delegate = nil;
    self.panelRanking.delegate = nil;
    [self.panelGenre.view removeFromSuperview];
    [self.panelCountry.view removeFromSuperview];
    [self.panelRanking.view removeFromSuperview];
    self.panelGenre = nil;
    self.panelCountry = nil;
    self.panelRanking = nil;
}

-(void)saveStatePickerApps
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"save_picker_app"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:menuRankingSelectedIndex forKey:@"save_picker_ranking"];
        [[NSUserDefaults standardUserDefaults] setInteger:menuGenreSelectedIndex forKey:@"save_picker_genre"];
        [[NSUserDefaults standardUserDefaults] setInteger:menuCountrySelectedIndex forKey:@"save_picker_country"];
        NSString* trimmedSearchText = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[NSUserDefaults standardUserDefaults] setObject:trimmedSearchText forKey:@"save_picker_text"];
    }
}

#pragma mark - Property methods

- (void)setAppsArray:(NSArray *)appsArray
{
    _appsArray = appsArray;
    [self.tableView  scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.tableView reloadData];
}

- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block
{
    PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
    query.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSString* country = [(NSString*)self.countryValues[menuCountrySelectedIndex] uppercaseString];
    [query loadAppsForTerm:searchTerm  withCountry:country completionBlock:^(NSArray* apps, NSError * error){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.appsArray = apps;
            dataWithSearchTerm = YES;
            if (block)
            {
                block(TRUE, NULL);
            }
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appsArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [PAPCommonGraphic getBackgroundWhiteAlpha];//(indexPath.row % 2 ? DARK_BACKGROUND_COLOR : LIGHT_BACKGROUND_COLOR);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DAAppViewCell";
    DAAppViewCell *cell = (DAAppViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DAAppViewCell" owner:self options:nil];
        cell = topLevelObjects[0];
    }
    cell.appObject = (self.appsArray)[indexPath.row];
    
    return cell;
}


#pragma mark- Table view delegate methods

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.appsArray.count) {
        PAApp* appSelected = self.appsArray[indexPath.row];
        if(self.delegateAppSearch)
        {
            [self saveStatePickerApps];
            [self.delegateAppSearch appSelected:appSelected modal:NO];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.appsArray.count) {
        PAApp *appObject = (self.appsArray)[indexPath.row];
        
        NSDictionary *appParameters = @{SKStoreProductParameterITunesItemIdentifier : appObject.appId, SKStoreProductParameterAffiliateToken:kPGHAffiliate};
        SKStoreProductViewController *productViewController = [[SKStoreProductViewController alloc] init];
        [productViewController setDelegate:self];
        [productViewController loadProductWithParameters:appParameters completionBlock:nil];
        [self presentViewController:productViewController
                           animated:YES
                         completion:nil];
    }
}

#pragma mark- Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self closeAllPanelsExcept:nil];
    [self.tableView setUserInteractionEnabled:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    
    NSString* text = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(text.length > 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self loadAppsWithSearchTerm:text completionBlock:^(BOOL result, NSError *error)
        {
            if(!result){
                [PAPErrorHandler handleError:error titleKey:nil];
            }
            [self showNoAppsMessage];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }
    [self.searchBar resignFirstResponder];
}

- (void)cancelButtonAction:(id)sender {
    [self saveStatePickerApps];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView setUserInteractionEnabled:NO];
    
    [self showPanelButton:NO];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self showPanelButton:YES];
    NSString* text = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(text.length == 0 && dataWithSearchTerm)
    {
        [self loadAppsWithFeed];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.searchBar isFirstResponder] && [touch view] != self.searchBar)
    {
        [self.searchBar resignFirstResponder];
        [self.tableView setUserInteractionEnabled:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidUnload {
    [self setMenuRanking:nil];
    [self setMenuGenre:nil];
    [self setMenuCountry:nil];
    [self setPanelCountry:nil];
    [self setPanelGenre:nil];
    [self setPanelRanking:nil];
    [super viewDidUnload];
}


#pragma mark - PAPMenuTableViewDelegate
-(void)valueSelectedAtIndex:(NSInteger)index forType:(tPAPMenuPickerType) type
{
    switch (type) {
        case kPAPMenuPickerTypeRanking:
            menuRankingSelectedIndex = index;
            [self.menuRanking setTitle:self.rankingTypeItems[index] forState: UIControlStateNormal];
            if(self.panelRanking.isOpen)
                [self toggleMenuPanel:self.menuRanking];
            [self.panelRanking.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            break;
        case kPAPMenuPickerTypeCountry:
            menuCountrySelectedIndex = index;
            [self.menuCountry setImage:[UIImage imageNamed:self.countryItems[index]] forState:UIControlStateNormal];
            [self.menuCountry setTitle:@"" forState: UIControlStateNormal];
            if(self.panelCountry.isOpen)
                [self toggleMenuPanel:self.menuCountry];
            [self.panelCountry.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        break;
        case kPAPMenuPickerTypeGenre:
            menuGenreSelectedIndex = index;
            [self.menuGenre setTitle:self.genreItems[index] forState: UIControlStateNormal];
            if(self.panelGenre.isOpen)
                [self toggleMenuPanel:self.menuGenre];
            [self.panelGenre.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            break;
    }
    self.searchBar.text = @"";
    [self loadAppsWithFeed];
}

-(void) loadAppsWithFeed
{
    if(self.disableMenuLoading)
    {
        return;
    }
    
    NSString* url = nil;
    NSString* type = self.rankingTypeValues[menuRankingSelectedIndex];
    NSString* limit = @"100";
    if([Sync currentSync])
    {
        NSNumber* val = [[Sync currentSync] objectForKey:kPAPSyncNumAppsPickerKey];
        if(val)
        {
            limit = [val stringValue];
        }
    }
    
    NSString* country = [(NSString*)self.countryValues[menuCountrySelectedIndex] lowercaseString];
    
    NSString* genre = self.genreValues[menuGenreSelectedIndex];
    if(menuGenreSelectedIndex == 0){
        url = [NSString stringWithFormat: @"https://itunes.apple.com/%@/rss/%@/limit=%@/xml",country,type,limit];
    }
    else
    {
        url = [NSString stringWithFormat: @"https://itunes.apple.com/%@/rss/%@/limit=%@/genre=%@/xml",country,type,limit,genre];
    }
    
    [self loadRssFeedWithURL:url];
}

-(void) loadRssFeedWithURL:(NSString*) url
{
    NSString* country = [(NSString*)self.countryValues[menuCountrySelectedIndex] uppercaseString];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [RSSParser parseRSSFeedForRequest:req success:^(NSArray *feedItems) {
        PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
        query.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [query loadApps:feedItems withCountry:country completionBlock:^(NSArray *apps, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];            
            if(error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.generic.dismiss",nil),NSLocalizedString(@"button.generic.retry",nil), nil];
                [alert show];
            }
            else
            {
                self.appsArray = apps;
                dataWithSearchTerm = NO;
            }
            [self showNoAppsMessage];
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error.userInfo.description);
        [self showNoAppsMessage];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.generic.dismiss",nil),NSLocalizedString(@"button.generic.retry",nil), nil];
        [alert show];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    } else if (buttonIndex == 1) {
        [self loadAppsWithFeed];
    }
}


- (IBAction)toggleMenuPanel:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    void (^completion)(BOOL isOpen) =  ^(BOOL isOpen){
    };
    
    if(sender == self.menuRanking)
    {
        [self closeAllPanelsExcept:self.panelRanking];
        [self.panelRanking togglePanelWithCompletionBlock:completion];
    }
    else if(sender == self.menuGenre)
    {
        [self closeAllPanelsExcept:self.panelGenre];
        [self.panelGenre togglePanelWithCompletionBlock:completion];
    }
    else if(sender == self.menuCountry)
    {
        [self closeAllPanelsExcept:self.panelCountry];
        [self.panelCountry togglePanelWithCompletionBlock:completion];
    }
}

-(void) closeAllPanelsExcept:(PAPMenuTableViewController*)panel
{
    if(panel != self.panelRanking && self.panelRanking.isOpen)
       [self.panelRanking togglePanel];
    if(panel != self.panelGenre && self.panelGenre.isOpen)
        [self.panelGenre togglePanel];
    if(panel != self.panelCountry && self.panelCountry.isOpen)
        [self.panelCountry togglePanel];
}

-(void) showPanelButton:(BOOL)show
{
    self.menuRanking.userInteractionEnabled = show;
    self.menuGenre.userInteractionEnabled = show;
    self.menuCountry.userInteractionEnabled = show;
    
    [self closeAllPanelsExcept:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self.menuRanking.alpha = show?1.0:0.0;
        self.menuGenre.alpha = show?1.0:0.0;
    }];
}

-(void)showNoAppsMessage
{
    if(self.appsArray.count == 0)
    {
        if (!self.blankView.superview) {
            self.blankView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankView;
        
            [UIView animateWithDuration:0.200f animations:^{
                self.blankView.alpha = 1.0f;
            }];
        }
    } else {
        self.tableView.tableHeaderView = nil;
        self.tableView.scrollEnabled = YES;
    }
}
    
@end
