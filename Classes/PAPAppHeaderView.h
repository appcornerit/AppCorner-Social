//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//
#import "PAPProfileImageView.h"

typedef NS_OPTIONS(NSUInteger, PAPAppHeaderButtons) {
    PAPAppHeaderButtonsNone = 0,
    PAPAppHeaderButtonsLike = 1 << 0,
    PAPAppHeaderButtonsComment = 1 << 1,
    PAPAppHeaderButtonsUser = 1 << 2,
    PAPAppHeaderButtonsAppIcon = 1 << 3,
    PAPAppHeaderButtonsDefault = PAPAppHeaderButtonsLike | PAPAppHeaderButtonsComment | PAPAppHeaderButtonsUser
} ;

@protocol PAPAppHeaderViewDelegate;

@interface PAPAppHeaderView : UIView

/*! @name Creating App Header View */
/*!
 Initializes the view with the specified interaction elements.
 @param buttons A bitmask specifying the interaction elements which are enabled in the view
 */
- (instancetype)initWithFrame:(CGRect)frame buttons:(PAPAppHeaderButtons)otherButtons NS_DESIGNATED_INITIALIZER;

/// The app associated with this view
@property (nonatomic,strong) PAApp *app;

/// The bitmask which specifies the enabled interaction elements in the view
@property (nonatomic, readonly, assign) PAPAppHeaderButtons buttons;

/*! @name Accessing Interaction Elements */

/// The Like App button
@property (nonatomic,readonly) UIButton *likeButton;

/// The Comment On App button
@property (nonatomic,readonly) UIButton *commentButton;

/*! @name Delegate */
@property (nonatomic,weak) id <PAPAppHeaderViewDelegate> delegate;

@property (nonatomic, strong) PAPProfileImageView *avatarImageView;

/*! @name Modifying Interaction Elements Status */

/*!
 Configures the Like Button to match the given like status.
 @param liked a BOOL indicating if the associated app is liked by the user
 */
- (void)setLikeStatus:(BOOL)liked;

/*!
 Enable the like button to start receiving actions.
 @param enable a BOOL indicating if the like button should be enabled.
 */
- (void)shouldEnableLikeButton:(BOOL)enable;

@end


/*!
 The protocol defines methods a delegate of a PAPAppHeaderView should implement.
 All methods of the protocol are optional.
 */
@protocol PAPAppHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the user button is tapped
 @param user the PFUser associated with this button
 */
- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user;

/*!
 Sent to the delegate when the like app button is tapped
 @param app the PAApp for the app that is being liked or disliked
 */
- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapLikeAppButton:(UIButton *)button app:(PAApp *)app;

/*!
 Sent to the delegate when the comment on app button is tapped
 @param app the PAApp for the app that will be commented on
 */
- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapCommentOnAppButton:(UIButton *)button app:(PAApp *)app;

- (void)appHeaderView:(PAPAppHeaderView *)appHeaderView didTapOnAppIconButton:(UIButton *)button app:(PAApp *)app;

@end