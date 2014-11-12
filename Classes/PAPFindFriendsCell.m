//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPFindFriendsCell.h"
#import "PAPProfileImageView.h"

@interface PAPFindFriendsCell ()
/*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UIButton *avatarImageButton;

@end


@implementation PAPFindFriendsCell
@synthesize delegate;
@synthesize user;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize appLabel;
@synthesize followButton;

#pragma mark - NSObject

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [self.mainView setBackgroundColor:[PAPCommonGraphic getBackgroundWhiteAlpha]];
        
        self.mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.avatarImageView = [[PAPProfileImageView alloc] initWithFrame:CGRectMake( 4.0f, 8.0f, 54.0f, 54.0f)];
        [self.mainView addSubview:self.avatarImageView];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton setFrame:self.avatarImageView.frame];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.avatarImageButton];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        [self.nameButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Black" size:15.0f]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.nameButton setTitleColor:[UIColor colorWithRed:87.0f/255.0f green:72.0f/255.0f blue:49.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.nameButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.nameButton];
        
        self.appLabel = [[UILabel alloc] init];
        [self.appLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.appLabel setTextColor:[UIColor grayColor]];
        [self.appLabel setBackgroundColor:[UIColor clearColor]];
        [self.mainView addSubview:self.appLabel];
        
        self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.followButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self.followButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 10.0f, 0.0f, 0.0f)];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"findFriends.button.follow.png"] forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"findFriends.button.following.png"] forState:UIControlStateSelected];
        [self.followButton setImage:[UIImage imageNamed:@"findFriends.button.tick.png"] forState:UIControlStateSelected];
        [self.followButton setTitle:NSLocalizedString(@"findFriends.button.follow",nil) forState:UIControlStateNormal]; // space added for centering
        [self.followButton setTitle:NSLocalizedString(@"findFriends.button.following",nil) forState:UIControlStateSelected];
        [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected | UIControlStateNormal];
        self.followButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.followButton addTarget:self action:@selector(didTapFollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.followButton];
        
        self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"common.separator.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        [self.mainView addSubview:self.separatorImage];
        
        [self.contentView addSubview:self.mainView];
    }
    return self;
}


#pragma mark - PAPFindFriendsCell

- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Configure the cell
    [avatarImageView setProfileID:[self.user objectForKey:kPAPUserFacebookIDKey]];
    
    // Set name
    NSString *nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    CGSize nameSize = [nameString sizeWithFont:[UIFont fontWithName:@"Avenir-Black" size:15.0f] forWidth:144.0f lineBreakMode:NSLineBreakByTruncatingTail];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateNormal];
    [nameButton setTitle:[self.user objectForKey:kPAPUserDisplayNameKey] forState:UIControlStateHighlighted];

    [nameButton setFrame:CGRectMake( 60.0f, 17.0f, nameSize.width, nameSize.height)];
    
    // Set app number label
    CGSize appLabelSize = [@"apps" sizeWithFont:[UIFont systemFontOfSize:11.0f] forWidth:144.0f lineBreakMode:NSLineBreakByTruncatingTail];
    [appLabel setFrame:CGRectMake( 60.0f, 17.0f + nameSize.height, 140.0f, appLabelSize.height)];
    
    // Set follow button
    [followButton setFrame:CGRectMake(self.frame.size.width-100.0f,2.0f,100.0f,self.frame.size.height-2.0f)];
}

#pragma mark - ()

+ (CGFloat)heightForCell {
    return 67.0f;
}

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapUserButton:)]) {
        [self.delegate cell:self didTapUserButton:self.user];
    }    
}

/* Inform delegate that the follow button was tapped */
- (void)didTapFollowButtonAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapFollowButton:)]) {
        [self.delegate cell:self didTapFollowButton:self.user];
    }        
}

@end
