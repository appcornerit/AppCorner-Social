//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPEditAppHeaderView.h"
#import "PAAppIconImageView.h"

@interface PAPEditAppHeaderView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *containerShadowView;
@property (nonatomic, strong) UIView *texturedBackgroundView;
@property (nonatomic, strong) PAAppIconImageView *appIconImageView;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UIButton *appNameButton;
@property (nonatomic, strong) UIButton *shareButton;
@end


@implementation PAPEditAppHeaderView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.containerShadowView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, 30.0f, self.bounds.size.width - 10.0f * 2.0f, self.bounds.size.height-30.0f)];
        [self addSubview:self.containerShadowView];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, 0.0f, self.bounds.size.width - 10.0f * 2.0f, self.bounds.size.height)];
        [self addSubview:self.containerView];
        
        // This is the app's display name, on a button so that we can tap on it
        self.appNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.containerView addSubview:self.appNameButton];
        [self.appNameButton setBackgroundColor:[UIColor clearColor]];
        [[self.appNameButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
        [self.appNameButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.appNameButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [[self.appNameButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.appNameButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.appNameButton addTarget:self action:@selector(didTapOnAppIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // app category
        self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50.0f, 24.0f, self.containerView.bounds.size.width - 50.0f - 72.0f, 18.0f)];
        [self.containerView addSubview:self.categoryLabel];
        [self.categoryLabel setTextColor:[UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        [self.categoryLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [self.categoryLabel setBackgroundColor:[UIColor clearColor]];
        
        CALayer *layer = [self.containerView layer];
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
    _app = aApp;
    
    self.appIconImageView = [[PAAppIconImageView alloc]initWithFrame:CGRectMake(2.0,2.0,40.0,40.0) app:self.app];
    self.appIconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnAppIconButtonAction:)];
    [self.appIconImageView addGestureRecognizer:singleFingerTap];
    [self.containerView addSubview:self.appIconImageView];
    CGFloat constrainWidth = self.containerView.frame.size.width - (self.appIconImageView.frame.size.width+self.appIconImageView.frame.origin.x+10.0);
    
    [self.appNameButton setTitle:self.app.name forState:UIControlStateNormal];
    
    // we resize the button to fit the user's name to avoid having a huge touch area
    CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
    CGSize constrainSize = CGSizeMake(constrainWidth, self.containerView.bounds.size.height - userButtonPoint.y*2.0f);
    CGSize userButtonSize = [self.appNameButton.titleLabel.text sizeWithFont:self.appNameButton.titleLabel.font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
    [self.appNameButton setFrame:userButtonFrame];
    
    self.categoryLabel.text = self.app.genre;
    
    //different user share app in your stream
    self.shareButton.hidden = [self.app.dkEntity.creatorId isEqualToString:[[PFUser currentUser] objectId]];
    
    [self setNeedsDisplay];
}

#pragma mark - ()

- (void)didTapOnAppIconButtonAction:(UITapGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAppHeaderView:didTapAppButton:app:)]) {
        [self.delegate editAppHeaderView:self didTapAppButton:nil app:self.app];
    }
}

@end
