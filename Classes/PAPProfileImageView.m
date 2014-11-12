//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPProfileImageView.h"

@interface PAPProfileImageView ()
@property (nonatomic, strong) UIImageView *borderImageview;
@property (nonatomic, strong) UIImageView *placeholderImageview;
@property (nonatomic, strong) UIActivityIndicatorView *placeholderActivityIndicatorView;
@end

@implementation PAPProfileImageView

@synthesize borderImageview;
@synthesize profileImageView;
@synthesize profileButton;


#pragma mark - NSObject

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.placeholderActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [self.placeholderActivityIndicatorView startAnimating];
        self.placeholderActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.placeholderActivityIndicatorView.hidden = YES;
        [self addSubview:self.placeholderActivityIndicatorView];
        
        self.placeholderImageview = [[UIImageView alloc] initWithFrame:self.bounds];
        self.placeholderImageview.image = [UIImage imageNamed:@"home.profile.placeholder.png"];
        self.placeholderImageview.alpha = 0.6;
        [self addSubview:self.placeholderImageview];
        
        self.profileImageView = [[FBProfilePictureView alloc] initWithFrame:self.bounds];
        self.profileImageView.pictureCropping = FBProfilePictureCroppingSquare; //FBProfilePictureCroppingOriginal;
        
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];
        
        self.profileImageView.clipsToBounds = YES;
        self.profileImageView.layer.cornerRadius = (self.frame.size.width/2.0f)-2.0f; //20.0f;
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profileImageView.frame = CGRectMake( 2.0f, 2.0f, self.frame.size.width - 4.0f, self.frame.size.height - 4.0f);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.placeholderImageview.frame = CGRectMake( 3.0f, 3.0f, self.frame.size.width - 6.0f, self.frame.size.height - 6.0f);
    self.placeholderActivityIndicatorView.frame = CGRectMake( 3.0f, 3.0f, self.frame.size.width - 6.0f, self.frame.size.height - 6.0f);
}

- (void)setProfileID:(NSString*)profileID
{
    self.profileImageView.profileID = profileID;
}

-(void)setHidePlaceholder:(BOOL)hidePlaceholder
{
    self.placeholderImageview.hidden = hidePlaceholder;
    self.placeholderActivityIndicatorView.hidden = !hidePlaceholder;
}

@end
