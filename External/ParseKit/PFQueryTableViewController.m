	//
//  PFQueryTableViewController.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFQueryTableViewController.h"
#import "PFTableViewCell.h"
#import "PFQuery.h"
#import "PAAppStoreQuery.h"
#import "MBProgressHUD.h"

// Macros
#define DKSynthesize(x) @synthesize x = x##_;


@interface PFQueryTableViewController ()
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign) NSUInteger currentOffset;
@property (nonatomic, strong, readwrite) NSMutableArray *objects;
@property (nonatomic, strong, readwrite) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchOverlay;
@property (nonatomic, assign) BOOL searchTextChanged;
@property (nonatomic, strong) NSMutableArray * orSkip;
@property (nonatomic, assign) UITableViewStyle style;
@end

@interface PFQueryTableNextPageCell : PFTableViewCell
@property (nonatomic, strong) UIActivityIndicatorView *activityAccessoryView;
@end


@implementation PFQueryTableViewController 

-(NSString*) className{
    return self.parseClassName;
}

-(void) setClassName:(NSString *)className_{
    self.parseClassName = className_;
}

-(NSString*) keyToDisplay{
    return self.displayedTitleKey;
}

-(void) setKeyToDisplay:(NSString *)keyToDisplay_{
    self.displayedTitleKey = keyToDisplay_;
}

- (instancetype)initWithStyle:(UITableViewStyle)otherStyle{
    return [self initWithStyle:otherStyle entityName:@""];
}

- (PFQuery *)queryForTable{
    DKQuery *q = [DKQuery queryWithEntityName:self.parseClassName];
    [q orderDescendingByCreationDate];
    PFQuery* pfQuery =[PFQuery queryWithClassName:self.parseClassName];
    pfQuery.dkQuery = q;
    return pfQuery;
}

- (void)loadObjects{
	[self reloadInBackground];
}

- (void)loadNextPage{
    [self loadNextPageWithFinishCallback:nil];
}

- (void)loadNextPageWithFinishCallback:(void (^)(NSError *error))callback
{
    if (self.isLoading) {
        return;
    }
    NSInteger count = [self getLoadedObjectsCount];
    [self appendNextPageWithFinishCallback:^(NSError *error){
        self.autoScrollLoad = count < [self getLoadedObjectsCount];
        if(callback)
        {
            callback(error);
        }
    }];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:self.style];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor clearColor];

    [self reloadInBackground];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![DKManager endpointReachable])
    {
        [PAPErrorHandler handleError:nil titleKey:@"error.connection.title"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object{

    
    if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
        return [self tableViewNextPageCell:tableView];
    }
    
    static NSString *identifier = @"PFObjectTableCell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.displayedTitleKey.length > 0) {
        cell.textLabel.text = [object objectForKey:self.displayedTitleKey];
    }
    if (self.displayedImageKey.length > 0) {
        cell.imageView.image = [UIImage imageWithData:[object objectForKey:self.displayedImageKey]];
    }
    
    return cell;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath{
    return (self.objects)[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath{
	if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
        return [self tableViewNextPageCell:tableView];
    }
	else{
        return [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
	}
}

- (void)objectsWillLoad{
}

- (void)objectsDidLoad:(NSError *)error{
    if(self.showHudForLoading)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
}


DKSynthesize(parseClassName)
DKSynthesize(displayedTitleKey)
DKSynthesize(displayedImageKey)
DKSynthesize(objectsPerPage)
DKSynthesize(isLoading)
DKSynthesize(objects)
DKSynthesize(searchBar)
DKSynthesize(searchOverlay)
DKSynthesize(searchTextChanged)
DKSynthesize(hasMore)
DKSynthesize(currentOffset)

- (void)initQueryTable {
    self.objectsPerPage = 25;
    self.currentOffset = 0;
    self.objects = [NSMutableArray new];
    _removedObjectsCount = 0;
    self.hasMore = NO;
    
    // Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.delegate = (id)self;
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    
    // Search overlay
    self.searchOverlay = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    
    [self.searchOverlay addTarget:self action:@selector(dismissOverlay:) forControlEvents:UIControlEventTouchUpInside];
    
    self.autoScrollLoad = YES;
    self.showHudForLoading = NO;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initQueryTable];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initQueryTable];
    }
    return self;
}

- (instancetype)initWithEntityName:(NSString *)entityName {
    return [self initWithStyle:UITableViewStylePlain entityName:entityName];
}

- (instancetype)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName {
    self = [super init];
    if (self) {
        [self initQueryTable];
        self.parseClassName = entityName;

        self.style = style;
    }
    return self;
}

- (void)processQueryResults:(NSArray *)results removedObjects:(NSInteger)removedObjects error:(NSError *)error callback:(void (^)(NSError *error))callback {
    NSAssert(dispatch_get_current_queue() == dispatch_get_main_queue(), @"query results not processed on main queue");
    
    if (results != nil && ![results isKindOfClass:[NSArray class]]) {
        NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Query did not return a result NSArray or nil", nil)};
        NSError* error = [[NSError alloc] initWithDomain:kPAPErrorDomain code:0 userInfo:userInfo];
        [self objectsDidLoad:error];
        return;
    } else if ([results isKindOfClass:[NSArray class]]) {
        for (id object in results) {
            if (!([object isKindOfClass:[PFObject class]] || [object isKindOfClass:[NSDictionary class]])) {
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Query results contained invalid objects", nil)};
                NSError* error = [[NSError alloc] initWithDomain:kPAPErrorDomain code:0 userInfo:userInfo];
                [self objectsDidLoad:error];
                return;
            }
        }
    }
    
    if(self.currentOffset == 0)
    {
        if(self.objects)
            [self.objects removeAllObjects];
        else
            self.objects = [[NSMutableArray alloc]init];
    }
    
    if (results.count > 0) {
		[self.objects addObjectsFromArray:results];
        _removedObjectsCount += removedObjects;
    }
    else
    {
        _removedObjectsCount = 0;
    }
    
    self.currentOffset += results.count;
    self.hasMore = ((results.count+removedObjects) == self.objectsPerPage);
    self.isLoading = NO;
    self.tableView.userInteractionEnabled = YES;
    
    if (error != nil) {
        [PAPErrorHandler handleError:error titleKey:nil];
    }
    
    // Post process results
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self postProcessResults];
        
        dispatch_async(q, ^{
            [self objectsWillLoad];
			[self.tableView reloadData];
            [self objectsDidLoad:error];
            
            if (callback != NULL) {
                callback(error);
            }
        });
    });
}

- (void)appendNextPageWithFinishCallback:(void (^)(NSError *error))callback {
    callback = [callback copy];
    
    self.isLoading = YES;
    self.tableView.userInteractionEnabled = NO;
    
    PFQuery *q = nil;
    DKQuery *qk = nil;
    NSString *queryText = self.searchBar.text;
    
    // Form search query for text if possible
    if ([self hasSearchBar] && queryText.length > 0) {
        q = [self tableQueryForSearchText:self.searchBar.text];
    }
    
    // Otherwise use default query
    if (q == nil) {
        q = [self queryForTable];
        qk = q.dkQuery;
    }
    q.orSkip = self.orSkip;
    
    NSAssert(q != nil, @"query cannot be nil");
    
    qk.skip = self.currentOffset;
    qk.limit = self.objectsPerPage;
    
    q.dkQuery = qk;

    if(self.showHudForLoading && (!self.objects || self.objects.count == 0))
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
        [q findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
            self.orSkip = q.orSkip;
            
            //HANDLE APPS OBJECTS
            NSMutableArray* apps = [[NSMutableArray alloc]init];
            for (PFObject* obj in results) {
                if([obj isKindOfClass:[PAApp class]])
                {
                    [apps addObject:obj];
                }
            }
            if(apps.count == 0)
            {
                [self processQueryResults:results removedObjects:0 error:error callback:callback];
            }
            else
            {
                PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
                query.cachePolicy = [self getCachePolicy:q.cachePolicy];
                [query loadApps:apps completionBlock:^(NSArray* apps, NSError * error){
                    //Removes apps not loaded (ex: removed from app store), to prevent show empty data (icon/images/name missing)
                    NSMutableArray* appResults = [[NSMutableArray alloc]initWithArray: results];
                    NSInteger removedObjects = 0;
                    for (PAApp* app in apps)
                    {
                        if(!app.loaded)
                        {
                            [appResults removeObject:app];
                            removedObjects++;
                        }
                    }
                    
                    [self processQueryResults:appResults removedObjects:removedObjects error:error callback:callback];
                }];
            }
        }];
    //}
}
    
-(NSURLRequestCachePolicy) getCachePolicy:(PFCachePolicy)cachePolicy{
    NSURLRequestCachePolicy policy = NSURLRequestReloadIgnoringCacheData;
    switch (cachePolicy)
    {
        case kPFCachePolicyIgnoreCache:
            policy = NSURLRequestReloadIgnoringLocalCacheData;
            break;
        case kPFCachePolicyCacheOnly:
            policy = NSURLRequestReturnCacheDataDontLoad;
            break;
        case kPFCachePolicyNetworkOnly:
            policy = NSURLRequestReloadIgnoringLocalCacheData;
            break;
        case kPFCachePolicyCacheElseNetwork:
            policy = NSURLRequestReturnCacheDataElseLoad;
            break;
        case kPFCachePolicyNetworkElseCache:
            policy = NSURLRequestUseProtocolCachePolicy;
            break;
        case kPFCachePolicyCacheThenNetwork:
            policy = NSURLRequestReturnCacheDataElseLoad;
            break;
    }
    return policy;
}

- (void)reloadInBackground {
    [self reloadInBackgroundWithBlock:NULL];
}

- (void)reloadInBackgroundWithBlock:(void (^)(NSError *))block {
    if (self.isLoading) {
        return;
    }
	
    // Display search bar if necessary
    if ([self hasSearchBar]) {
        self.tableView.tableHeaderView = self.searchBar;
    } else {
        [self.searchOverlay removeFromSuperview];
        self.tableView.tableHeaderView = nil;
    }
    
    self.hasMore = NO;
    self.currentOffset = 0;
    self.autoScrollLoad = YES;

    [self appendNextPageWithFinishCallback:block];
}

- (void)reloadInBackgroundIfSearchTextChanged {
    if (self.searchTextChanged) {
        self.searchTextChanged = NO;
        [self reloadInBackground];
    }
}

- (void)postProcessResults {

}


- (BOOL)hasSearchBar {
    return NO;
}

- (PFQuery *)tableQueryForSearchText:(NSString *)text {
    return nil;
}

- (void)loadNextPageWithNextPageCell:(PFQueryTableNextPageCell *)cell {
    if (self.isLoading) {
        return;
    }
    [cell.activityAccessoryView startAnimating];
    [cell setNeedsLayout];
    
    NSInteger count = [self getLoadedObjectsCount];
    [self appendNextPageWithFinishCallback:^(NSError *error){
        self.autoScrollLoad = count < [self getLoadedObjectsCount];
        [cell.activityAccessoryView stopAnimating];
        [cell setNeedsLayout];
    }];
}

-(NSInteger)getLoadedObjectsCount
{
  return self.objects.count + self.removedObjectsCount;
}
    
#pragma mark UITableViewDelegate & Related

- (BOOL)tableViewCellIsNextPageCellAtIndexPath:(NSIndexPath *)indexPath {
    return (self.hasMore && (indexPath.row == self.objects.count));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count + (self.hasMore ? 1 : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
        UITableViewCell* cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        if (indexPath.row == self.objects.count  //|| indexPath.section == self.objects.count)
            && self.paginationEnabled && self.autoScrollLoad) {
            // Load More Cell
            [self loadNextPage];
        }
        return cell;
    }
    
    id object = [self objectAtIndexPath:indexPath];
    return [self tableView: tableView cellForRowAtIndexPath:indexPath object:object];
}

- (PFTableViewCell *)tableViewNextPageCell:(UITableView *)tableView {
    static NSString *identifier = @"PFQueryTableNextPageCell";
    PFQueryTableNextPageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PFQueryTableNextPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%i more ...", nil), self.objectsPerPage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self tableViewCellIsNextPageCellAtIndexPath:indexPath]) {
        UITableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
        if([cell isKindOfClass:[PFQueryTableNextPageCell class]])
            [self loadNextPageWithNextPageCell:(PFQueryTableNextPageCell*)cell];
        else
            [self loadNextPage];
    }
    else {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath object:(self.objects)[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object {
    // stub
}

#pragma mark UISearchBarDelegate & Overlay

- (void)dismissOverlay:(UIButton *)sender {
    [sender removeFromSuperview];
    [self.searchBar resignFirstResponder];
    [self reloadInBackgroundIfSearchTextChanged];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchOverlay removeFromSuperview];
    [self.searchBar resignFirstResponder];
    [self reloadInBackgroundIfSearchTextChanged];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    CGRect bounds = self.tableView.bounds;
    CGRect barBounds = self.searchBar.bounds;
    CGRect overlayFrame = CGRectMake(CGRectGetMinX(bounds),
                                     CGRectGetMaxY(barBounds),
                                     CGRectGetWidth(barBounds),
                                     CGRectGetHeight(bounds) - CGRectGetHeight(barBounds));
    
    self.searchOverlay.frame = overlayFrame;
    
    [self.tableView addSubview:self.searchOverlay];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchTextChanged = YES;
}

@end



@implementation PFQueryTableNextPageCell
DKSynthesize(activityAccessoryView)

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIActivityIndicatorView *accessoryView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        accessoryView.hidesWhenStopped = YES;
        
        self.activityAccessoryView = accessoryView;
        
        [self.contentView addSubview:self.activityAccessoryView];
        
        self.textLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        self.textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        self.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Center text label
    UIFont *font = self.textLabel.font;
    NSString *text = self.textLabel.text;
    
    CGRect bounds = self.bounds;
    CGSize textSize = [text sizeWithFont:font
                                forWidth:CGRectGetWidth(bounds)
                           lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize spinnerSize = self.activityAccessoryView.frame.size;
    CGFloat padding = 10.0;
    
    BOOL isAnimating = self.activityAccessoryView.isAnimating;
    
    CGRect textFrame = CGRectMake((CGRectGetWidth(bounds) - textSize.width - (isAnimating ? spinnerSize.width - padding : 0)) / 2.0,
                                  (CGRectGetHeight(bounds) - textSize.height) / 2.0,
                                  textSize.width,
                                  textSize.height);
    
    self.textLabel.frame = CGRectIntegral(textFrame);
    
    if (isAnimating) {
        CGRect spinnerFrame = CGRectMake(CGRectGetMaxX(textFrame) + padding,
                                         (CGRectGetHeight(bounds) - spinnerSize.height) / 2.0,
                                         spinnerSize.width,
                                         spinnerSize.height);
        
        self.activityAccessoryView.frame = spinnerFrame;
    }
}

@end
