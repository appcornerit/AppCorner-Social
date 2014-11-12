//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "PAPMenuTableViewController.h"


@protocol DAAppsViewControllerDelegate <NSObject>
    -(void)appSelected:(PAApp*)app modal:(BOOL) modal;
@end

@interface DAAppsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SKStoreProductViewControllerDelegate, PAPMenuTableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, assign) id<DAAppsViewControllerDelegate> delegateAppSearch;

- (void)loadAppsWithSearchTerm:(NSString *)searchTerm completionBlock:(void(^)(BOOL result, NSError *error))block;

@end
