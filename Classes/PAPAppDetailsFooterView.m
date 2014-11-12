//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppDetailsFooterView.h"
#import "PAPUtility.h"
#import "PAAppPreviewScrollView.h"

@interface PAPAppDetailsFooterView ()
@property (nonatomic, strong) UIView *containerShadowView;
@end

@implementation PAPAppDetailsFooterView

@synthesize commentField;
@synthesize mainView;
@synthesize hideDropShadow;


#pragma mark - NSObject

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.containerShadowView = [[UIView alloc] initWithFrame:CGRectMake( 10.0f, 0.0f, self.bounds.size.width - 10.0f * 2.0f, self.bounds.size.height-16.0f)];
        [self addSubview:self.containerShadowView];
        
        mainView = [[UIView alloc] initWithFrame:CGRectMake((screenWidth-mainImageWidth)/2.0, 0.0f, mainImageWidth, 51.0)];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail.icon.addComment.png"]];
        messageIcon.frame = CGRectMake( 9.0f, 17.0f, 19.0f, 17.0f);
        [mainView addSubview:messageIcon];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"detail.text.comment.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f)]];
        commentBox.frame = CGRectMake(35.0f, 8.0f, 250.0f, 35.0f);
        [mainView addSubview:commentBox];
        
        commentField = [[UITextField alloc] initWithFrame:CGRectMake( 38.0f, 10.0f, 247.0f, 31.0f)];
        commentField.font = [UIFont fontWithName:@"Avenir-Book" size:14.0f];
        commentField.placeholder = NSLocalizedString(@"detail.placeholder.addComment",nil);
        commentField.returnKeyType = UIReturnKeySend;
        commentField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        commentField.textColor = [UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
        commentField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [mainView addSubview:commentField];
        
        
        CALayer *layer = self.mainView.layer;
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        CALayer *shadowLayer = [self.containerShadowView layer];
        shadowLayer.backgroundColor = [[UIColor clearColor] CGColor];
        shadowLayer.masksToBounds = NO;
        shadowLayer.shadowRadius = 1.0f;
        shadowLayer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        shadowLayer.shadowOpacity = 0.5f;
        shadowLayer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, self.containerShadowView.frame.size.height - 4.0f, self.containerShadowView.frame.size.width, 4.0f)].CGPath;
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.mainView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(2.0, 2.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.mainView.layer.mask = maskLayer;
    }
    return self;
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!hideDropShadow) {
        [PAPUtility drawSideAndBottomDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}


#pragma mark - PAPAppDetailsFooterView

+ (CGRect)rectForView {
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 69.0f);
}

@end
