//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppHeaderView.h"
#import "PAAppPreviewScrollView.h"

@protocol PAPAppDetailsHeaderViewDelegate;

@interface PAPAppDetailsHeaderView : UIView

/*! @name Managing View Properties */

/// The app displayed in the view
@property (nonatomic, strong, readonly) PAApp *app;

/// The user that took the app
@property (nonatomic, strong, readonly) PFUser *apper;

/// Array of the users that liked the app
@property (nonatomic, strong) NSArray *likeUsers;

/// Heart-shaped like button
@property (nonatomic, strong, readonly) UIButton *likeButton;

@property (nonatomic, strong) PAAppPreviewScrollView* appImageScrollView;

/*! @name Delegate */
@property (nonatomic, strong) id<PAPAppDetailsHeaderViewDelegate,PAPAppHeaderViewDelegate> delegate;

+ (CGRect)rectForView;

- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)aApp NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)aApp apper:(PFUser*)apper likeUsers:(NSArray*)theLikeUsers NS_DESIGNATED_INITIALIZER;

- (void)setLikeButtonState:(BOOL)selected;
- (void)reloadLikeBar;
@end

/*!
 The protocol defines methods a delegate of a PAPAppDetailsHeaderView should implement.
 */
@protocol PAPAppDetailsHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the photgrapher's name/avatar is tapped
 @param button the tapped UIButton
 @param user the PFUser for the apper
 */
- (void)appDetailsHeaderView:(PAPAppDetailsHeaderView *)headerView didTapUserButton:(UIButton *)button user:(PFUser *)user;

@end