//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "PAPFindFriendsCell.h"

@interface PAPFindFriendsViewController : PFQueryTableViewController <PAPFindFriendsCellDelegate, ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, FBFriendPickerDelegate>

@end
