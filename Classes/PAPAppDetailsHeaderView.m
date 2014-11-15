//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppDetailsHeaderView.h"
#import "PAPProfileImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAAppPreviewScrollView.h"

#define baseHorizontalOffset 10.0f
#define baseWidth 300.0f

#define horiBorderSpacing 0.0f
#define horiMediumSpacing 8.0f

#define vertBorderSpacing 0.0f
#define vertSmallSpacing 2.0f


#define nameHeaderX baseHorizontalOffset
#define nameHeaderY 0.0f
#define nameHeaderWidth 320.0f
#define nameHeaderHeight 44.0f

#define avatarImageX horiBorderSpacing
#define avatarImageY vertBorderSpacing
#define avatarImageDim 44.0f

#define nameLabelX avatarImageX+avatarImageDim+horiMediumSpacing
#define nameLabelY avatarImageY+vertSmallSpacing
#define nameLabelMaxWidth 280.0f - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

#define timeLabelX nameLabelX
#define timeLabelMaxWidth nameLabelMaxWidth

#define mainImageX baseHorizontalOffset
#define mainImageY nameHeaderHeight

#define likeBarX baseHorizontalOffset
#define likeBarY nameHeaderHeight + mainImageHeight
#define likeBarWidth baseWidth
#define likeBarHeight 44.0f

#define likeButtonX 4.0f
#define likeButtonY 5.0f
#define likeButtonDim 34.0f

#define likeProfileXBase 45.0f
#define likeProfileXSpace 2.0f
#define likeProfileY -1.0f
#define likeProfileDim 46.0f

#define viewTotalHeight likeBarY+likeBarHeight
#define numLikePics 7.0f

@interface PAPAppDetailsHeaderView ()

// View components
@property (nonatomic, strong) PAPAppHeaderView *nameHeaderView;
@property (nonatomic, strong) NSMutableArray* appImagesView;

@property (nonatomic, strong) UIView *likeBarView;
@property (nonatomic, strong) NSMutableArray *currentLikeAvatars;

// Redeclare for edit
@property (nonatomic, strong, readwrite) PFUser *apper;

// Private methods
- (void)createView;

@end


static TTTTimeIntervalFormatter *timeFormatter;

@implementation PAPAppDetailsHeaderView

@synthesize app;
@synthesize apper;
@synthesize likeUsers;
@synthesize nameHeaderView;
@synthesize likeBarView;
@synthesize likeButton;
@synthesize delegate;
@synthesize currentLikeAvatars;

#pragma mark - NSObject

- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)aApp {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }
        
        self.app = aApp;
        self.apper = [self.app objectForKey:kPAPAppUserKey];
        self.likeUsers = nil;
        
        self.backgroundColor = [UIColor clearColor];
        [self createView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)aApp apper:(PFUser*)aApper likeUsers:(NSArray*)theLikeUsers {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        self.app = aApp;
        self.apper = aApper;
        self.likeUsers = theLikeUsers;
        
        self.backgroundColor = [UIColor clearColor];

        if (self.app && self.apper && self.likeUsers) {
            [self createView];
        }
        
    }
    return self;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [PAPUtility drawSideDropShadowForRect:self.nameHeaderView.frame inContext:UIGraphicsGetCurrentContext()];
    [PAPUtility drawSideDropShadowForRect:self.appImageScrollView.frame inContext:UIGraphicsGetCurrentContext()];
    [PAPUtility drawSideDropShadowForRect:self.likeBarView.frame inContext:UIGraphicsGetCurrentContext()];
}


#pragma mark - PAPAppDetailsHeaderView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, viewTotalHeight);
}

- (void)setApp:(PAApp *)aApp{
    app = aApp;

    if (self.app && self.apper && self.likeUsers) {
        [self createView];
        [self setNeedsDisplay];
    }
}

- (void) setDelegate:(id<PAPAppDetailsHeaderViewDelegate,PAPAppHeaderViewDelegate>)del
{
    delegate = del;
    self.nameHeaderView.delegate = self.delegate;
}

- (void)setLikeUsers:(NSMutableArray *)anArray {
    likeUsers = [anArray sortedArrayUsingComparator:^NSComparisonResult(PFUser *liker1, PFUser *liker2) {
        NSString *displayName1 = [liker1 objectForKey:kPAPUserDisplayNameKey];
        NSString *displayName2 = [liker2 objectForKey:kPAPUserDisplayNameKey];
        
        if ([[liker1 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedAscending;
        } else if ([[liker2 objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            return NSOrderedDescending;
        }
        
        return [displayName1 compare:displayName2 options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
    }];;
    
    for (PAPProfileImageView *image in currentLikeAvatars) {
        [image removeFromSuperview];
    }

    [likeButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)self.likeUsers.count] forState:UIControlStateNormal];

    self.currentLikeAvatars = [[NSMutableArray alloc] initWithCapacity:likeUsers.count];
    int i;
    int numOfPics = numLikePics > self.likeUsers.count ? self.likeUsers.count : numLikePics;

    for (i = 0; i < numOfPics; i++) {
        PAPProfileImageView *profilePic = [[PAPProfileImageView alloc] initWithFrame:CGRectMake(likeProfileXBase + i * (likeProfileXSpace + likeProfileDim), likeProfileY, likeProfileDim, likeProfileDim)];
        [profilePic.profileButton addTarget:self action:@selector(didTapLikerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        profilePic.profileButton.tag = i;
        [profilePic setProfileID:[(self.likeUsers)[i] objectForKey:kPAPUserFacebookIDKey]];
        [likeBarView addSubview:profilePic];
        [currentLikeAvatars addObject:profilePic];
    }
}

- (void)setLikeButtonState:(BOOL)selected {
    if (selected) {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( -1.0f, 1.0f, 0.0f, 0.0f)];
    } else {
        [likeButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 1.0f, 0.0f, 0.0f)];
    }
    [likeButton setSelected:selected];
}

- (void)reloadLikeBar {
    self.likeUsers = [[PAPCache sharedCache] likersForApp:self.app];
    [self setLikeButtonState:[[PAPCache sharedCache] isAppLikedByCurrentUser:self.app]];
    [likeButton addTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - ()

- (void)createView {    
    
    self.nameHeaderView = [[PAPAppHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.bounds.size.width, 44.0f) buttons:PAPAppHeaderButtonsUser | PAPAppHeaderButtonsAppIcon];
    [self.nameHeaderView setApp:app];
    self.nameHeaderView.delegate = self.delegate;
    [self addSubview:self.nameHeaderView];
    
    self.appImageScrollView = [[PAAppPreviewScrollView alloc] initWithFrame:CGRectMake((screenWidth-mainImageWidth)/2.0, 44.0f, mainImageWidth, mainImageHeight)];
    self.appImageScrollView.app = self.app;
    [self addSubview:self.appImageScrollView];
    
    /*
     Create bottom section fo the header view; the likes
     */
    likeBarView = [[UIView alloc] initWithFrame:CGRectMake(likeBarX, likeBarY, likeBarWidth, likeBarHeight)];
    [likeBarView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:likeBarView];
    
    // Create the heart-shaped like button
    likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeButton setFrame:CGRectMake(likeButtonX, likeButtonY, likeButtonDim, likeButtonDim)];
    [likeButton setBackgroundColor:[UIColor clearColor]];
    [likeButton setTitle:@"" forState:UIControlStateNormal];    
    [likeButton setTitleColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f] forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [[likeButton titleLabel] setFont:[UIFont systemFontOfSize:12.0f]];
    [[likeButton titleLabel] setMinimumFontSize:11.0f];
    [[likeButton titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [likeButton setAdjustsImageWhenDisabled:NO];
    [likeButton setAdjustsImageWhenHighlighted:NO];
    [likeButton setBackgroundImage:[UIImage imageNamed:@"home.button.love.png"] forState:UIControlStateNormal];
    [likeButton setBackgroundImage:[UIImage imageNamed:@"home.button.love.selected.png"] forState:UIControlStateSelected];
    [likeButton addTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [likeBarView addSubview:likeButton];
    
    [self reloadLikeBar];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"common.separator.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 1.0f, 0.0f, 1.0f)]];
    [separator setFrame:CGRectMake(0.0f, likeBarView.frame.size.height - 2.0f, likeBarView.frame.size.width, 2.0f)];
    [likeBarView addSubview:separator];    
}

- (void)didTapLikeAppButtonAction:(UIButton *)button {
    BOOL liked = !button.selected;
    [button removeTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self setLikeButtonState:liked];

    NSArray *originalLikeUsersArray = [NSArray arrayWithArray:self.likeUsers];
    NSMutableSet *newLikeUsersSet = [NSMutableSet setWithCapacity:[self.likeUsers count]];
    
    for (PFUser *likeUser in self.likeUsers) {
        // add all current likeUsers BUT currentUser
        if (![[likeUser objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
            [newLikeUsersSet addObject:likeUser];
        }
    }
    
    if (liked) {
        [[PAPCache sharedCache] incrementLikerCountForApp:self.app];
        [newLikeUsersSet addObject:[PFUser currentUser]];
    } else {
        [[PAPCache sharedCache] decrementLikerCountForApp:self.app];
    }
    
    [[PAPCache sharedCache] setAppIsLikedByCurrentUser:self.app liked:liked];

    [self setLikeUsers:[newLikeUsersSet allObjects]];

    if (liked) {
        [PAPUtility likeAppInBackground:self.app block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:NO];
                [PAPErrorHandler handleError:error titleKey:nil];
            }
            else{
//               [PAPErrorHandler handleSuccess:@"message.action.like"];
            }
        }];
    } else {
        [PAPUtility unlikeAppInBackground:self.app block:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [button addTarget:self action:@selector(didTapLikeAppButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [self setLikeUsers:originalLikeUsersArray];
                [self setLikeButtonState:YES];
                [PAPErrorHandler handleError:error titleKey:nil]; 
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDetailsViewControllerUserLikedUnlikedAppNotification object:self.app userInfo:@{PAPAppDetailsViewControllerUserLikedUnlikedAppNotificationUserInfoLikedKey: @(liked)}];
}

- (void)didTapLikerButtonAction:(UIButton *)button {
    PFUser *user = (self.likeUsers)[button.tag];
    if (delegate && [delegate respondsToSelector:@selector(appDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate appDetailsHeaderView:self didTapUserButton:button user:user];
    }    
}

- (void)didTapUserNameButtonAction:(UIButton *)button {
    if (delegate && [delegate respondsToSelector:@selector(appDetailsHeaderView:didTapUserButton:user:)]) {
        [delegate appDetailsHeaderView:self didTapUserButton:button user:self.apper];
    }    
}


@end
