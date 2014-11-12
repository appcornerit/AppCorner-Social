//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPAppCell.h"
#import "PAPUtility.h"
#import <DeploydKit/UIImageView+AFNetworking.h>

@implementation PAPAppCell
{
    CGRect headerFrame;
    CGRect footerFrame;
    UIView* cellHeaderView;
    UIView* cellFooterView;
}

@synthesize appButton;

#pragma mark - NSObject

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        cellHeaderView = nil;
        cellFooterView = nil;
        headerFrame = CGRectMake(0.0, 0.0, screenWidth, 44.0f);
        footerFrame = CGRectMake(0.0, mainImageHeight+44.0f, screenWidth, 44.0f);
        
        self.appImageScrollView = [[PAAppPreviewScrollView alloc] initWithFrame:CGRectMake((screenWidth-mainImageWidth)/2.0f, 44.0f, mainImageWidth, mainImageHeight)];
        [self.contentView addSubview:self.appImageScrollView];        
        
        self.appButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.appButton.frame = CGRectMake((screenWidth-mainImageWidth)/2.0f, 44.0f, mainImageWidth, mainImageHeight);
        self.appButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.appButton];
        
        [self.contentView bringSubviewToFront:self.appImageScrollView];
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];        
    }

    return self;
}

-(void) setHeadView:(UIView *)headView
{
    if(cellHeaderView)
    {
        [cellHeaderView removeFromSuperview];
        cellHeaderView = nil;
    }
    cellHeaderView = headView;
    [self.contentView insertSubview:cellHeaderView belowSubview:self.appImageScrollView];
    cellHeaderView.frame = headerFrame;
}

-(void) setFootView:(UIView *)footView
{
    if(cellFooterView)
    {
        [cellFooterView removeFromSuperview];
        cellFooterView = nil;
    }
    cellFooterView = footView;
    [self addSubview:cellFooterView];
    cellFooterView.frame = footerFrame;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [PAPUtility drawSideDropShadowForRect:self.appImageScrollView.frame inContext:UIGraphicsGetCurrentContext()];    
    [PAPUtility drawSideDropShadowForRect:CGRectInset(cellFooterView.frame, 10.0f, 0.0f) inContext:UIGraphicsGetCurrentContext()];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.appButton.frame = CGRectMake((screenWidth-mainImageWidth)/2.0f, 0.0f, mainImageWidth, mainImageHeight);
}

-(void) setApp:(PAApp *)app
{
    _app = app;
    self.appImageScrollView.app = self.app;
}

@end
