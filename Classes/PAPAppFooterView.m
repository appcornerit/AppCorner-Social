//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppFooterView.h"
#import "PAAppIconImageView.h"

@interface PAPAppFooterView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *containerShadowView;
@property (nonatomic, strong) UIView *texturedBackgroundView;
@property (nonatomic, strong) PAAppIconImageView *appIconImageView;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIButton *appNameButton;
@property (nonatomic, strong) UIButton *shareButton;
@end


@implementation PAPAppFooterView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.zPosition = 100; //workaround to avoid header shadow over the footer
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGRect containerFrame = CGRectMake( 10.0f, 0.0f, self.bounds.size.width - 10.0f * 2.0f, self.bounds.size.height-16.0);
        
        //container shadow (workround for self.containerView.layer.mask = maskLayer that hide shadow)
        self.containerShadowView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, 0.0f, self.bounds.size.width - 10.0f * 2.0f, self.bounds.size.height-16.0f)];
        [self addSubview:self.containerShadowView];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:containerFrame];
        [self addSubview:self.containerView];
        [self.containerView setBackgroundColor:[PAPCommonGraphic getBackgroundWhiteAlpha]];


        // comments button
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.containerView addSubview:self.shareButton];
        [self.shareButton setFrame:CGRectMake(3.0f, 3.0f, 38.0f, 38.0f)];
        [self.shareButton setBackgroundColor:[UIColor clearColor]];
        [self.shareButton setBackgroundImage:[UIImage imageNamed:@"home.button.share.png"] forState:UIControlStateNormal];
        [self.shareButton setSelected:NO];
        [self.shareButton addTarget:self action:@selector(didTapOnShareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.shareButton.hidden = YES;
        
        // This is the app's display name, on a button so that we can tap on it
        self.appNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.containerView addSubview:self.appNameButton];
        [self.appNameButton setBackgroundColor:[UIColor clearColor]];
        [[self.appNameButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
        [self.appNameButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.appNameButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [[self.appNameButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.appNameButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, -8.0f, 0.0f, 0.0f)];
        [[self.appNameButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        self.appNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.appNameButton addTarget:self action:@selector(didTapOnAppIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // app category
        self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 24.0f, self.containerView.bounds.size.width - (50.0f + 50.0f), 18.0f)];
        [self.containerView addSubview:self.categoryLabel];
        [self.categoryLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [self.categoryLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.categoryLabel setBackgroundColor:[UIColor clearColor]];
        self.categoryLabel.textAlignment = NSTextAlignmentRight;
        
        CALayer *layer = self.containerView.layer;
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        CALayer *shadowLayer = [self.containerShadowView layer];
        shadowLayer.backgroundColor = [[UIColor clearColor] CGColor];
        shadowLayer.masksToBounds = NO;
        shadowLayer.shadowRadius = 1.0f;
        shadowLayer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        shadowLayer.shadowOpacity = 0.5f;
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, self.containerShadowView.frame.size.height - 4.0f, self.containerShadowView.frame.size.width, 4.0f)].CGPath;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(2.0, 2.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.containerView.layer.mask = maskLayer;
    }
    
    return self;
}


#pragma mark - PAPAppHeaderView

- (void)setApp:(PAApp *)aApp {
    _app = aApp;

    if(self.appIconImageView)
    {
        [self.appIconImageView removeFromSuperview];
        self.appIconImageView = nil;
    }
    self.appIconImageView = [[PAAppIconImageView alloc]initWithFrame:CGRectMake(self.containerView.frame.size.width-42.0,2.0,40.0,40.0) app:self.app];
    self.appIconImageView.userInteractionEnabled = YES;    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnAppIconButtonAction:)];
    [self.appIconImageView addGestureRecognizer:singleFingerTap];
    [self.containerView addSubview:self.appIconImageView];
    
    [self.appNameButton setTitle:self.app.name forState:UIControlStateNormal];
    
    self.categoryLabel.text = self.app.genre;
    
    //different user share app in your stream
    self.shareButton.hidden = [self.app.dkEntity.creatorId isEqualToString:[[PFUser currentUser] objectId]];
    CGFloat width = self.containerView.bounds.size.width-((self.shareButton.hidden?10:50.0f) +50.0f);
    CGRect userButtonFrame = CGRectMake((self.shareButton.hidden?10:50.0f), 0.0f, width, self.containerView.bounds.size.height - 12.0f);
    [self.appNameButton setFrame:userButtonFrame];
    
    PFUser* appUser = [aApp objectForKey:kPAPAppUserKey];
    NSNumber* internal = [appUser objectForKey:kPAPUserInternal];
    BOOL boolInternal = (internal && [internal boolValue]);
    CALayer *layer = self.containerView.layer;    
    if(boolInternal)
    {
        layer.backgroundColor = [[PAPCommonGraphic getBackgroundInternalUser] CGColor];
    }
    else
    {
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
    
    [self setNeedsDisplay];
}

#pragma mark - ()

- (void)didTapOnAppIconButtonAction:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appFooterView:didTapAppButton:app:)]) {
        [self.delegate appFooterView:self didTapAppButton:nil app:self.app];
    }
}

- (void)didTapOnShareButtonAction:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appFooterView:didTapShareButton:app:)]) {
        [self.delegate appFooterView:self didTapShareButton:nil app:self.app];
    }
}

@end