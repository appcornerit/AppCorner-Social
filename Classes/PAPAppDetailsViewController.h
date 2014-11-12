//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppDetailsHeaderView.h"
#import "PAPBaseTextCell.h"
#import "PAPAppHeaderView.h"
#import <StoreKit/StoreKit.h>

@interface PAPAppDetailsViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, PAPAppDetailsHeaderViewDelegate, PAPAppHeaderViewDelegate, PAPBaseTextCellDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) PAApp *app;

@property(nonatomic,assign) BOOL openedFromAccount;
@property(nonatomic,strong) PFUser* openedFromUserAccount;

- (instancetype)initWithApp:(PAApp*)aApp NS_DESIGNATED_INITIALIZER;

@end
