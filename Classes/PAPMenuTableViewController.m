//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPMenuTableViewController.h"
#import "PAPFlagMenuItemTableCell.h"

@interface PAPMenuTableViewController ()

@end

@implementation PAPMenuTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.closeOffset = 0.0f;
    }
    return self;
}

-(void)setOpenFrame:(CGRect)openFrame
{
    _openFrame = openFrame;
    closeFrame = openFrame;
    
    switch (self.openDirection) {
        case kPAPMenuOpenDirectionRight:
            closeFrame.origin.x -= self.view.frame.size.width;
            break;
        case kPAPMenuOpenDirectionDown:
            closeFrame.origin.y -= self.view.frame.size.height;
        break;
        case kPAPMenuOpenDirectionLeft:
            closeFrame.origin.x += self.view.frame.size.width;
            break;
    }
    
    self.view.frame = closeFrame;
    self.view.hidden = YES;
    _isOpen = NO;
}

-(void) setOpenDirection:(kPAPMenuOpenDirection)openDirection
{
    _openDirection = openDirection;
    UISwipeGestureRecognizer *swipeGestureRecognize = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanel)];
    switch (openDirection) {
        case kPAPMenuOpenDirectionRight:
            swipeGestureRecognize.direction = UISwipeGestureRecognizerDirectionLeft;
            break;
        case kPAPMenuOpenDirectionDown:
            break;
            swipeGestureRecognize.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        case kPAPMenuOpenDirectionLeft:
            swipeGestureRecognize.direction = UISwipeGestureRecognizerDirectionRight;
            break;
    }
    [self.view addGestureRecognizer:swipeGestureRecognize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = menuItemHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[UIView alloc]initWithFrame:self.backgroundAreaDismissRect];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.view.clipsToBounds = NO;
    
    self.blurView.backgroundColor = [UIColor clearColor];
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanel)];
    tapGestureRecognize.numberOfTapsRequired = 1;
    [tapGestureRecognize requireGestureRecognizerToFail:tapGestureRecognize];
    [self.backgroundView addGestureRecognizer:tapGestureRecognize];
}

-(void)setBackgroundAreaDismissRect:(CGRect)backgroundAreaDismissRect
{
    _backgroundAreaDismissRect = backgroundAreaDismissRect;
    self.backgroundView.frame = backgroundAreaDismissRect;
}

-(void) togglePanel
{
    [self togglePanelWithCompletionBlock:nil];
}

-(void) togglePanelWithCompletionBlock:(void (^)(BOOL isOpen))completion
{
    if(!_isOpen)
    {
        self.view.hidden = NO;
    }
    [UIView animateWithDuration:0.4 animations:^{
        if(self.isOpen){
            self.view.frame = closeFrame;
            [self.backgroundView removeFromSuperview];
        }
        else
        {
            self.view.frame = self.openFrame;
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        }
    } completion:^(BOOL finished) {
        
        _isOpen = !self.isOpen;
        if(!_isOpen)
        {
            self.view.hidden = YES;
        }

        if(completion)
        {
            completion(self.isOpen);
        }
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"MenuItemCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        if(self.type == kPAPMenuPickerTypeCountry)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PAPFlagMenuItemTableCell" owner:self options:nil];
            cell = topLevelObjects[0];
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    if(self.type != kPAPMenuPickerTypeCountry)
    {
        cell.textLabel.text = self.items[indexPath.row];
        if(self.type == kPAPMenuPickerTypeGenre)
        {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                cell.separatorInset = UIEdgeInsetsMake(0.0,0.0,0.0,15.0f);
            }
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        }
        
    }
    else
    {        
        [((PAPFlagMenuItemTableCell*)cell).flagImageView setImage:[UIImage imageNamed:self.items[indexPath.row]]];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [PAPCommonGraphic getAquaColor];
    cell.textLabel.font = [UIFont fontWithName:@"Cochin-BoldItalic" size:16.0];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.delegate)
    {
        [self.delegate valueSelectedAtIndex:indexPath.row forType:self.type];
    }
    [self togglePanel];
}


@end

