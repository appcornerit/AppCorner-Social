//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPEditAppContainerView.h"
#import "PAAppPreviewScrollView.h"

@implementation PAPEditAppContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    rect.origin.x = (screenWidth-mainImageWidth)/2.0;
    rect.size.width = mainImageWidth;
    // Drawing code
    [PAPUtility drawSideDropShadowForRect:rect inContext:UIGraphicsGetCurrentContext()];
}


@end
