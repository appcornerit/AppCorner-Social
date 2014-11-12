//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPActivityCell.h"
#import <StoreKit/StoreKit.h>

@interface PAPActivityFeedViewController : PFQueryTableViewController <PAPActivityCellDelegate,SKStoreProductViewControllerDelegate>

+ (NSString *)stringForActivityType:(NSString *)activityType;

@end
