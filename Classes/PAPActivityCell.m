//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPActivityCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "PAAppIconImageView.h"
#import "PAPActivityFeedViewController.h"
#import "PAAppStoreQuery.h"

#define avatarSpacingX 1.0f
#define avatarSpacingY 4.0f
#define avatarDimActivity 48.0f

static TTTTimeIntervalFormatter *timeFormatter;

@interface PAPActivityCell ()

/*! Private view components */
@property (nonatomic, strong) PAAppIconImageView *activityImageView;
@property (nonatomic, strong) UIButton *activityImageButton;

/*! Flag to remove the right-hand side image if not necessary */
@property (nonatomic,assign) BOOL hasActivityImage;

/*! Private setter for the right-hand side image */
- (void)setActivityApp:(PAApp *)app;

/*! Button touch handler for activity image button overlay */
- (void)didTapActivityButton:(id)sender;

/*! Static helper method to calculate the space available for text given images and insets */
+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth;

@end

@implementation PAPActivityCell


#pragma mark - NSObject

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:0];
        
        if (!timeFormatter) {
            timeFormatter = [[TTTTimeIntervalFormatter alloc] init];
        }

        // Create subviews and set cell properties
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.hasActivityImage = NO; //No until one is set
        
        self.activityImageView = [[PAAppIconImageView alloc] init];
        [self.activityImageView setBackgroundColor:[UIColor clearColor]];
        [self.activityImageView setOpaque:YES];
        [self.mainView addSubview:self.activityImageView];
        
        self.activityImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.activityImageButton setBackgroundColor:[UIColor clearColor]];
        [self.activityImageButton addTarget:self action:@selector(didTapActivityButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.activityImageButton];
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.avatarImageButton setFrame:CGRectMake(avatarSpacingX, avatarSpacingY, avatarDimActivity, avatarDimActivity)];
    [self.avatarImageView setFrame:CGRectMake(avatarSpacingX, avatarSpacingY, avatarDimActivity, avatarDimActivity)];
    
    // Layout the activity image and show it if it is not nil (no image for the follow activity).
    // Note that the image view is still allocated and ready to be dispalyed since these cells
    // will be reused for all types of activity.
    [self.activityImageView setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 6.0f, 44.0f, 44.0f)];
    [self.activityImageButton setFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width - 46.0f, 6.0f, 44.0f, 44.0f)];

    CGFloat appImageSize = 46.0f;
    
    // Add activity image if one was set
    if (self.hasActivityImage) {
        [self.activityImageView setHidden:NO];
        [self.activityImageButton setHidden:NO];
    } else {
        [self.activityImageView setHidden:YES];
        [self.activityImageButton setHidden:YES];
        appImageSize = 0.0;
    }

    // Change frame of the content text so it doesn't go through the right-hand side picture
    CGSize contentSize = [self.contentLabel.text sizeWithFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 72.0f - appImageSize, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    [self.contentLabel setFrame:CGRectMake( 54.0f, 8.0f, contentSize.width, contentSize.height)];
    
    // Layout the timestamp label given new vertical 
    CGSize timeSize = [self.timeLabel.text sizeWithFont:[UIFont fontWithName:@"Cochin-BoldItalic" size:11.0f] forWidth:[UIScreen mainScreen].bounds.size.width - 72.0f - appImageSize lineBreakMode:NSLineBreakByTruncatingTail];
    [self.timeLabel setFrame:CGRectMake( 54.0f, self.contentLabel.frame.origin.y + self.contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];
}


#pragma mark - PAPActivityCell

- (void)setIsNew:(BOOL)isNew {
    if (isNew) {
        [self.mainView setBackgroundColor:[PAPCommonGraphic getBackgroundBlueAlpha]];
    } else {
        [self.mainView setBackgroundColor:[PAPCommonGraphic getBackgroundWhiteWithAlpha:0.8]];
    }
}

- (void)setIsPriceDrop:(BOOL)isPriceDrop {
    if (isPriceDrop) {
        [self.mainView setBackgroundColor:[PAPCommonGraphic getBackgroundGreenAlpha]];
    }
}


- (void)setActivity:(PFObject *)activity {
    // Set the activity property
    _activity = activity;
    if ([[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeFollow] || [[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypeJoined]) {
        [self setActivityApp:nil];
    } else {
        PAApp* app = (PAApp*)[activity objectForKey:kPAPActivityAppIDKey];
        PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
        query.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        [query loadApp:app completionBlock:^(PFObject *object, NSError *error) {
            [self setActivityApp:app];
            [self setNeedsLayout];
        }];
    }
    
    NSString *activityString = [PAPActivityFeedViewController stringForActivityType:(NSString*)[activity objectForKey:kPAPActivityTypeKey]];
    if ([(NSString*)[activity objectForKey:kPAPActivityTypeKey] isEqualToString:kPAPActivityTypePriceDrop]) {
        activityString = [PAPUtility priceDropToString:[activity objectForKey:kPAPActivityContentKey] withActivityString:activityString];
    }
    self.user = [activity objectForKey:kPAPActivityFromUserKey];
    
    // Set name button properties and avatar image
    [self.avatarImageView setProfileID:[self.user objectForKey:kPAPUserFacebookIDKey]];
    
    NSString *nameString = NSLocalizedString(@"Someone", nil);
    if (self.user && [self.user objectForKey:kPAPUserDisplayNameKey] && [[self.user objectForKey:kPAPUserDisplayNameKey] length] > 0) {
        nameString = [self.user objectForKey:kPAPUserDisplayNameKey];
    }
    
    [self.nameButton setTitle:nameString forState:UIControlStateNormal];
    [self.nameButton setTitle:nameString forState:UIControlStateHighlighted];
    
    // If user is set after the contentText, we reset the content to include padding
    if (self.contentLabel.text) {
        [self setContentText:self.contentLabel.text];
    }

    if (self.user) {
        CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont fontWithName:@"Avenir-Black" size:13.0f] forWidth:nameMaxWidth lineBreakMode:NSLineBreakByTruncatingTail];
        NSString *paddedString = [PAPBaseTextCell padString:activityString withFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f] toWidth:nameSize.width];
        [self.contentLabel setText:paddedString];
    } else { // Otherwise we ignore the padding and we'll add it after we set the user
        [self.contentLabel setText:activityString];
    }

    [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[activity createdAt]]];

    [self setNeedsDisplay];
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    [super setCellInsetWidth:insetWidth];
    horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:insetWidth];
}

// Since we remove the compile-time check for the delegate conforming to the protocol
// in order to allow inheritance, we add run-time checks.
- (id<PAPActivityCellDelegate>)delegate {
    return (id<PAPActivityCellDelegate>)_delegate;
}

- (void)setDelegate:(id<PAPActivityCellDelegate>)delegate {
    if(_delegate != delegate) {
        _delegate = delegate;
    }
}


#pragma mark - ()

+ (CGFloat)horizontalTextSpaceForInsetWidth:(CGFloat)insetWidth {
    return ([UIScreen mainScreen].bounds.size.width - (insetWidth * 2.0f)) - 72.0f - 46.0f;
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content {
    return [self heightForCellWithName:name contentString:content cellInsetWidth:0.0f];
}

+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset {
    CGSize nameSize = [name sizeWithFont:[UIFont fontWithName:@"Avenir-Black" size:13.0f] forWidth:200.0f lineBreakMode:NSLineBreakByTruncatingTail];
    NSString *paddedString = [PAPBaseTextCell padString:content withFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f] toWidth:nameSize.width];
    CGFloat horizontalTextSpace = [PAPActivityCell horizontalTextSpaceForInsetWidth:cellInset];
    
    CGSize contentSize = [paddedString sizeWithFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f] constrainedToSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat singleLineHeight = [@"Test" sizeWithFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f]].height;
    
    // Calculate the added height necessary for multiline text. Ensure value is not below 0.
    CGFloat multilineHeightAddition = contentSize.height - singleLineHeight;

    return 48.0f + fmax(0.0f, multilineHeightAddition);
}

- (void)setActivityApp:(PAApp *)app
{
    if (app) {
        self.activityImageView.app = app;
        [self setHasActivityImage:YES];
    } else {
        [self setHasActivityImage:NO];
    }
}

- (void)didTapActivityButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapActivityButton:)]) {
        [self.delegate cell:self didTapActivityButton:self.activity];
    }    
}

@end
