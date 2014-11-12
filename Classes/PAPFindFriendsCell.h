//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

@class PAPProfileImageView;
@protocol PAPFindFriendsCellDelegate;

@interface PAPFindFriendsCell : UITableViewCell {
    id _delegate;
}

@property (nonatomic, strong) id<PAPFindFriendsCellDelegate> delegate;

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *separatorImage;

/*! The user represented in the cell */
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *appLabel;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) PAPProfileImageView *avatarImageView;

/*! Setters for the cell's content */
- (void)setUser:(PFUser *)user;

- (void)didTapUserButtonAction:(id)sender;
- (void)didTapFollowButtonAction:(id)sender;

/*! Static Helper methods */
+ (CGFloat)heightForCell;

@end

/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol PAPFindFriendsCellDelegate <NSObject>
@optional

/*!
 Sent to the delegate when a user button is tapped
 @param aUser the PFUser of the user that was tapped
 */
- (void)cell:(PAPFindFriendsCell *)cellView didTapUserButton:(PFUser *)aUser;
- (void)cell:(PAPFindFriendsCell *)cellView didTapFollowButton:(PFUser *)aUser;

@end
