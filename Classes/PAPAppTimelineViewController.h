//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppHeaderView.h"
#import "PAPAppFooterView.h"
#import <StoreKit/StoreKit.h>
#import "POHorizontalList.h"

@interface PAPAppTimelineViewController : PFQueryTableViewController <PAPAppHeaderViewDelegate,PAPAppFooterViewDelegate,SKStoreProductViewControllerDelegate, POHorizontalListDelegate>

@property (NS_NONATOMIC_IOSONLY, readonly, strong) PAPAppHeaderView *dequeueReusableSectionHeaderView;

- (void) toggleAppsJumpBar:(id)sender;
@property (NS_NONATOMIC_IOSONLY, getter=getAppsJumpBarTitle, readonly, copy) NSString *appsJumpBarTitle;

@end
