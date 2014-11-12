//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "POHorizontalList.h"

@implementation POHorizontalList

-(void) setupViewWithParentView:(UIView*)parentView
{
    self.backgroundColor = [UIColor clearColor];
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;

    [self.titleLabel setFont:[UIFont fontWithName:@"Cochin-BoldItalic" size:18.0]];
    [self.titleLabel setTextColor:[PAPCommonGraphic getAquaColor]];
    
    [self.titleLabel setOpaque:YES];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    
    
    [self.noAppsLabel setFont:[UIFont fontWithName:@"Cochin-Italic" size:18.0f]];
    [self.noAppsLabel setTextColor:[PAPCommonGraphic getAquaColor]];
    [self.noAppsLabel setOpaque:YES];
    [self.noAppsLabel setBackgroundColor:[UIColor clearColor]];
    self.noAppsLabel.text = NSLocalizedString(@"appJumpBar.noapps.label", nil);
    
    openFrame = self.frame;
    closeFrame = openFrame;
    closeFrame.origin.y -= self.frame.size.height+self.offsetY;
    self.frame = closeFrame;
    _isOpen = NO;

}

-(void)setPAAppItems:(NSMutableArray *)items
{
    _pAAppItems = items;
    
    for (UIView *subview in self.scrollView.subviews) {
        if([subview isKindOfClass:[PAAppIconInfoView class]])
            [subview removeFromSuperview];
    }
    
    if(!_pAAppItems)
        return;
    
    NSMutableArray* iconImageViewArray = [[NSMutableArray alloc]init];
    CGRect iconFrame = CGRectMake(0.0f,0.0f,ITEM_WIDTH,ITEM_WIDTH);
    
    NSMutableSet* existingApps = [NSMutableSet set];
    NSMutableArray* filteredApps = [NSMutableArray array];
    PFUser* currentUser = [PFUser currentUser];
    for (PAApp* app in _pAAppItems) {
        BOOL itsme =[[[app objectForKey:kPAPAppUserKey] objectId]isEqualToString:[currentUser objectId]];
        if (![existingApps containsObject:app.appId] &&
            (!self.excludeCurrentUserApps || (self.excludeCurrentUserApps && !itsme))) {
            [existingApps addObject:app.appId];
            [filteredApps addObject:app];
            PAAppIconInfoView* iconImageView = [[PAAppIconInfoView alloc]initWithFrame:iconFrame app:app myApps:itsme];
            [iconImageViewArray addObject:iconImageView];
        }
    }

    CGSize pageSize = CGSizeMake(ITEM_WIDTH, ITEM_WIDTH);
    NSUInteger page = 0;
    
    for(PAAppIconInfoView *item in iconImageViewArray) {
        [item setFrame:CGRectMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, 0, pageSize.width, pageSize.height)];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
        [item addGestureRecognizer:singleFingerTap];
        item.userInteractionEnabled = YES;
        [self.scrollView addSubview:item];
    }
    
    self.scrollView.contentSize = CGSizeMake(LEFT_PADDING + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * [iconImageViewArray count], pageSize.height);
    
    self.noAppsLabel.hidden = iconImageViewArray.count > 0;
}

- (void)itemTapped:(UITapGestureRecognizer *)recognizer {
    PAAppIconInfoView *iconView = (PAAppIconInfoView *)recognizer.view;

    if (iconView != nil) {
        [self.delegate didSelectApp:iconView.app];
    }
}

- (IBAction)handleSwipeUpGesture:(id)sender
{
    if(self.isOpen)
        [self togglePanel:sender];
}

- (IBAction)togglePanel:(id)sender
{
    [self togglePanel:sender withCompletionBlock:nil];
}

-(void)togglePanel:(id)sender withCompletionBlock:(void (^)(BOOL isOpen))completion
{
    
    [UIView animateWithDuration:0.4 animations:^{
        if(self.isOpen){
            self.frame = closeFrame;
        }
        else
        {
            self.frame = openFrame;
        }
    } completion:^(BOOL finished) {
        _isOpen = !self.isOpen;
        
        if(completion)
        {
            completion(_isOpen);
        }
    }];
}


@end
