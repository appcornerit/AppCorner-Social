//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPBackButtonItem.h"

@implementation PAPBackButtonItem


- (instancetype)initWithTarget:(id)target action:(SEL)action {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:backButton];
    if (self) {
        [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [backButton setFrame:CGRectMake( 0.0f, 0.0f, 44.0f, 44.0f)];
        [backButton setImage:[UIImage imageNamed:@"toolbar.back.png"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"toolbar.back.selected.png"] forState:UIControlStateHighlighted];
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    return self;
}


@end
