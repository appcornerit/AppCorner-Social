//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "DAAppViewCell.h"
#import "PAAppIconImageView.h"
static NSMutableDictionary *_iconCacheDictionary = nil;

@interface DAAppViewCell ()

@property (nonatomic, weak) IBOutlet PAAppIconImageView *iconView;
@property (nonatomic, weak) IBOutlet UILabel *appNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *genreLabel;
@property (nonatomic, weak) IBOutlet UIImageView *starImageView;
@property (nonatomic, weak) IBOutlet UILabel *noRatingsLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingsLabel;
@property (nonatomic, weak) IBOutlet UIButton *purchaseButton;
@property (nonatomic, weak) IBOutlet UIImageView *cellImageShadowView;
@property (nonatomic, strong)  UIImageView *separatorImage;
@property (weak, nonatomic) IBOutlet UIView *backgroundViewButtonDetail;
@property (weak, nonatomic) IBOutlet UIView *backgroundButtonView;
@property (weak, nonatomic) IBOutlet UIImageView *starAllVersionsImageView;
@property (weak, nonatomic) IBOutlet UILabel *ratingsAllVersionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noRatingsAllVersionsLabel;

- (void)purchaseButton:(UIButton *)button;

@end

@implementation DAAppViewCell

+ (void)initialize
{
    if (self == [DAAppViewCell class])
    {
        _iconCacheDictionary = [[NSMutableDictionary alloc] init];
    }    
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initCell];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initCell];
    }
    return self;
}

-(void) initCell
{
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.appNameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.appNameLabel.backgroundColor = [UIColor clearColor];
    self.appNameLabel.textColor = [UIColor colorWithWhite:78.0f/255.0f alpha:1.0f];
    self.appNameLabel.numberOfLines = 1;
    self.appNameLabel.minimumFontSize = 12.0;
    self.appNameLabel.adjustsFontSizeToFitWidth = YES;
    self.genreLabel.font = [UIFont systemFontOfSize:10.0f];
    self.genreLabel.backgroundColor = [UIColor clearColor];
    self.genreLabel.textColor = [UIColor colorWithWhite:99.0f/255.0f alpha:1.0f];
    self.starImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.starImageView.clipsToBounds = YES;
    self.starImageView.frame = CGRectMake(self.starImageView.frame.origin.x,self.starImageView.frame.origin.y,self.starImageView.frame.size.width,9.5f);
    
    self.starAllVersionsImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.starAllVersionsImageView.clipsToBounds = YES;
    self.starAllVersionsImageView.frame = CGRectMake(self.starAllVersionsImageView.frame.origin.x,self.starAllVersionsImageView.frame.origin.y,self.starAllVersionsImageView.frame.size.width,9.5f);
    
    self.noRatingsLabel.font = [UIFont systemFontOfSize:9.0f];
    self.noRatingsLabel.textColor = [UIColor colorWithWhite:99.0f/255.0f alpha:1.0f];
    self.noRatingsLabel.backgroundColor = [UIColor clearColor];
    self.noRatingsLabel.text = NSLocalizedString(@"appPicker.noratings",nil);
    self.noRatingsLabel.hidden = YES;
    
    self.noRatingsAllVersionsLabel.font = [UIFont systemFontOfSize:9.0f];
    self.noRatingsAllVersionsLabel.textColor = [UIColor colorWithWhite:99.0f/255.0f alpha:1.0f];
    self.noRatingsAllVersionsLabel.backgroundColor = [UIColor clearColor];
    self.noRatingsAllVersionsLabel.text = NSLocalizedString(@"appPicker.noratings.allversions",nil);
    self.noRatingsAllVersionsLabel.hidden = YES;
    
    self.ratingsLabel.font = [UIFont systemFontOfSize:10.0f];
    self.ratingsLabel.textColor = [UIColor colorWithWhite:90.0f/255.0f alpha:1.0f];
    self.ratingsLabel.backgroundColor = [UIColor clearColor];
    
    self.ratingsAllVersionsLabel.font = [UIFont systemFontOfSize:10.0f];
    self.ratingsAllVersionsLabel.textColor = [UIColor colorWithWhite:90.0f/255.0f alpha:1.0f];
    self.ratingsAllVersionsLabel.backgroundColor = [UIColor clearColor];
    self.ratingsAllVersionsLabel.minimumFontSize = 9.0;
    self.ratingsAllVersionsLabel.adjustsFontSizeToFitWidth = YES;
 
    [self.purchaseButton addTarget:self
                            action:@selector(purchaseButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    self.priceLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.priceLabel.backgroundColor = [UIColor clearColor];
    self.priceLabel.textColor = [UIColor colorWithWhite:78.0f/255.0f alpha:1.0f];
    
    self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"common.separator.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
    [self addSubview:self.separatorImage];
}

- (void)purchaseButton:(UIButton *)button
{
    UITableView *tableView = (UITableView *)self.superview;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        tableView = (UITableView *)tableView.superview;
    }
    NSIndexPath *pathOfTheCell = [tableView indexPathForCell:self];
    if ([tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
    {
        [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:pathOfTheCell];
    }
}

#pragma mark - Property methods

- (void)setAppObject:(PAApp *)appObject
{
    _appObject = appObject;
    self.appNameLabel.text = appObject.name;    
    self.genreLabel.text = appObject.genre;
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    self.ratingsLabel.text = [NSString stringWithFormat:@"(%@)", [formatter stringFromNumber:@(appObject.userRatingCount)]];
    self.ratingsLabel.hidden = appObject.userRatingCount == 0;
    self.noRatingsLabel.hidden = appObject.userRatingCount > 0;
    self.starImageView.hidden = appObject.userRatingCount == 0;

    NSNumber* userRatingCountAllVersions = @(appObject.userRatingCountAllVersions);
    if(appObject.userRatingCountAllVersions < appObject.userRatingCount)
    {
        userRatingCountAllVersions = @(appObject.userRatingCount);
    }
    
    self.ratingsAllVersionsLabel.text = [NSString stringWithFormat:@"(%@ %@)", [formatter stringFromNumber:userRatingCountAllVersions],NSLocalizedString(@"appPicker.label.allVersions",nil)];
    self.ratingsAllVersionsLabel.hidden = appObject.userRatingCountAllVersions == 0;
    self.noRatingsAllVersionsLabel.hidden = appObject.userRatingCountAllVersions > 0;
    self.starAllVersionsImageView.hidden = appObject.userRatingCountAllVersions == 0;
    
    self.priceLabel.text = appObject.formattedPrice;
    [self.purchaseButton setTitle:NSLocalizedString(@"appPicker.button.detail",nil) forState:UIControlStateNormal];
    
    UIImage *starsImage = [UIImage imageNamed:@"apppicker.stars.png"];
    UIGraphicsBeginImageContextWithOptions(self.starImageView.frame.size, NO, 0);
    CGPoint starPoint = (CGPoint) {
        .y = (self.starImageView.frame.size.height * (2 * appObject.userRating + 1)) - starsImage.size.height
    };
    [starsImage drawAtPoint:starPoint];
    self.starImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *starsAllVersionsImage = [UIImage imageNamed:@"apppicker.stars.png"];
    UIGraphicsBeginImageContextWithOptions(self.starAllVersionsImageView.frame.size, NO, 0);
    CGPoint starAllVersionsPoint = (CGPoint) {
        .y = (self.starAllVersionsImageView.frame.size.height * (2 * appObject.userRatingAllVersions + 1)) - starsAllVersionsImage.size.height
    };
    [starsAllVersionsImage drawAtPoint:starAllVersionsPoint];
    self.starAllVersionsImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.iconView.app = self.appObject;
    
}

-(void) prepareForReuse
{
    [super prepareForReuse];
    self.starImageView.frame = CGRectMake(self.starImageView.frame.origin.x,self.starImageView.frame.origin.y,self.starImageView.frame.size.width,9.5f);
    self.starAllVersionsImageView.frame = CGRectMake(self.starAllVersionsImageView.frame.origin.x,self.starAllVersionsImageView.frame.origin.y,self.starAllVersionsImageView.frame.size.width,9.5f);
}
@end
