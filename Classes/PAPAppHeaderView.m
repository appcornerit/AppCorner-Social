//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAPUtility.h"
#import "PAAppIconImageView.h"

@interface PAPAppHeaderView () 
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *containerShadowView;
@property (nonatomic, strong) PAAppIconImageView *appIconImageView;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end


@implementation PAPAppHeaderView
@synthesize containerView;
@synthesize avatarImageView;
@synthesize userButton;
@synthesize timestampLabel;
@synthesize timeIntervalFormatter;
@synthesize app;
@synthesize buttons;
@synthesize likeButton;
@synthesize commentButton;
@synthesize delegate;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame buttons:(PAPAppHeaderButtons)otherButtons {
    self = [super initWithFrame:frame];
    if (self) {
        [PAPAppHeaderView validateButtons:otherButtons];
        buttons = otherButtons;

        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
    
         self.containerShadowView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, self.bounds.size.height, self.bounds.size.width - 10.0f * 2.0f, 0.0f)];
        
        [self addSubview:self.containerShadowView];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, 0.0f, self.bounds.size.width - 10.0f * 2.0f, self.bounds.size.height)];
        [self addSubview:self.containerView];

        self.avatarImageView = [[PAPProfileImageView alloc] initWithFrame:CGRectMake(-1.0f, -1.0f, 46.0f, 46.0f)];
        [self.avatarImageView.profileButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:self.avatarImageView];
        
        
        if (self.buttons & PAPAppHeaderButtonsComment) {
            // comments button
            commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.commentButton];
            [self.commentButton setFrame:CGRectMake(260.0f, 6.0f, 34.0f, 33.0f)];
            [self.commentButton setBackgroundColor:[UIColor clearColor]];
            [self.commentButton setTitle:@"" forState:UIControlStateNormal];
            [self.commentButton setTitleColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake( -4.0f, 0.0f, 0.0f, 0.0f)];
            [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
            [[self.commentButton titleLabel] setMinimumFontSize:11.0f];
            [[self.commentButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"home.button.comment.png"] forState:UIControlStateNormal];
            [self.commentButton setBackgroundImage:[UIImage imageNamed:@"home.button.comment.selected.png"] forState:UIControlStateHighlighted];
            [self.commentButton setSelected:NO];
            
        }
        
        if (self.buttons & PAPAppHeaderButtonsLike) {
            // like button
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.likeButton];
            [self.likeButton setFrame:CGRectMake(220.0f, 6.0f, 34.0f, 33.0f)];
            [self.likeButton setBackgroundColor:[UIColor clearColor]];
            [self.likeButton setTitle:@"" forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
            [[self.likeButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
            [[self.likeButton titleLabel] setMinimumFontSize:11.0f];
            [[self.likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
            [self.likeButton setAdjustsImageWhenHighlighted:NO];
            [self.likeButton setAdjustsImageWhenDisabled:NO];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"home.button.love.png"] forState:UIControlStateNormal];
            [self.likeButton setBackgroundImage:[UIImage imageNamed:@"home.button.love.selected.png"] forState:UIControlStateSelected];
            [self.likeButton setSelected:NO];
        }
        
        if (self.buttons & PAPAppHeaderButtonsUser) {
            // This is the user's display name, on a button so that we can tap on it
            self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [containerView addSubview:self.userButton];
            [self.userButton setBackgroundColor:[UIColor clearColor]];
            [[self.userButton titleLabel] setFont:[UIFont fontWithName:@"Avenir-Black" size:15.0f]];
            [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
            [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        }
        
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        // timestamp
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 22.0f, containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [containerView addSubview:self.timestampLabel];
        [self.timestampLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [self.timestampLabel setFont:[UIFont fontWithName:@"Cochin-BoldItalic" size:11.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        
        CALayer *layer = containerView.layer;
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        CALayer *shadowLayer = self.containerShadowView.layer;
        shadowLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        shadowLayer.masksToBounds = NO;
        shadowLayer.shadowRadius = 1.0f;
        shadowLayer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        shadowLayer.shadowOpacity = 0.5f;
        shadowLayer.shouldRasterize = YES;
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, self.containerShadowView.frame.size.height - 4.0f, self.containerShadowView.frame.size.width, 4.0f)].CGPath;
        
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(2.0, 2.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;        
        self.containerView.layer.mask = maskLayer;
        

    }

    return self;
}


#pragma mark - PAPAppHeaderView

- (void)setApp:(PAApp *)aApp {
    app = aApp;

    // user's avatar
    PFUser *user = [self.app objectForKey:kPAPAppUserKey];
    [self.avatarImageView setProfileID:[user objectForKey:kPAPUserFacebookIDKey]];

    NSString *authorName = [user objectForKey:kPAPUserDisplayNameKey];
    [self.userButton setTitle:authorName forState:UIControlStateNormal];
    
    CGFloat constrainWidth = containerView.bounds.size.width;

    if (self.buttons & PAPAppHeaderButtonsUser) {
        [self.userButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PAPAppHeaderButtonsComment) {
        constrainWidth = self.commentButton.frame.origin.x;
        [self.commentButton addTarget:self action:@selector(didTapCommentOnAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PAPAppHeaderButtonsLike) {
        constrainWidth = self.likeButton.frame.origin.x;
        [self.likeButton addTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.buttons & PAPAppHeaderButtonsAppIcon) {
        self.appIconImageView = [[PAAppIconImageView alloc]initWithFrame:CGRectMake(self.containerView.frame.size.width-42.0,2.0,40.0,40.0) app:self.app];
        self.appIconImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnAppIconButtonAction:)];
        [self.appIconImageView addGestureRecognizer:singleFingerTap];
        [self.containerView addSubview:self.appIconImageView];
    }
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    constrainWidth -= userButtonPoint.x+10.0;
    CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
    CGSize userButtonSize = [self.userButton.titleLabel.text sizeWithFont:self.userButton.titleLabel.font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.userButton setFrame:userButtonFrame];
    
    NSTimeInterval timeInterval = [[self.app createdAt] timeIntervalSinceNow];
    NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
    [self.timestampLabel setText:timestamp];

    PFUser* appUser = [app objectForKey:kPAPAppUserKey];
    NSNumber* internal = [appUser objectForKey:kPAPUserInternal];
    BOOL boolInternal = (internal && [internal boolValue]);
    
    CALayer *layer = containerView.layer;
    CALayer *shadowLayer = self.containerShadowView.layer;
    if(boolInternal)
    {
        layer.backgroundColor = [[PAPCommonGraphic getBackgroundInternalUser] CGColor];
        shadowLayer.backgroundColor = [[PAPCommonGraphic getBackgroundInternalUser] CGColor];
    }
    else
    {
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        shadowLayer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
    
    [self setNeedsDisplay];
}

- (void)setLikeStatus:(BOOL)liked {
    [self.likeButton setSelected:liked];
    
    if (liked) {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(-1.0f, 1.0f, 0.0f, 0.0f)];
    } else {
        [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 0.0f)];
    }
}

- (void)shouldEnableLikeButton:(BOOL)enable {
    if (enable) {
        [self.likeButton removeTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.likeButton addTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ()

+ (void)validateButtons:(PAPAppHeaderButtons)buttons {
    if (buttons == PAPAppHeaderButtonsNone) {
        [NSException raise:NSInvalidArgumentException format:@"Buttons must be set before initializing in AppHeaderView."];
    }
}

- (void)didTapUserButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(appHeaderView:didTapUserButton:user:)]) {
        [delegate appHeaderView:self didTapUserButton:sender user:[self.app objectForKey:kPAPAppUserKey]];
    }
}

- (void)didTapLikeAppButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(appHeaderView:didTapLikeAppButton:app:)]) {
        [delegate appHeaderView:self didTapLikeAppButton:button app:self.app];
    }
}

- (void)didTapCommentOnAppButtonAction:(UIButton *)sender {
    if (delegate && [delegate respondsToSelector:@selector(appHeaderView:didTapCommentOnAppButton:app:)]) {
        [delegate appHeaderView:self didTapCommentOnAppButton:sender app:self.app];
    }
}

- (void)didTapOnAppIconButtonAction:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appHeaderView:didTapOnAppIconButton:app:)]) {
        [self.delegate appHeaderView:self didTapOnAppIconButton:nil app:self.app];
    }
}

@end
