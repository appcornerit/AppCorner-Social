//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

@class PFImageView;
@interface PAPProfileImageView : UIView

@property (nonatomic, strong) UIButton *profileButton;
@property (nonatomic, strong) FBProfilePictureView *profileImageView;
@property (nonatomic, assign) BOOL hidePlaceholder;

- (void)setProfileID:(NSString*)profileID;

@end
