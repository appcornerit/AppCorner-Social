//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPSettingsButtonItem.h"

@implementation PAPSettingsButtonItem

#pragma mark - Initialization

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self = [super initWithCustomView:settingsButton];
    if (self) {
        [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
        [settingsButton setImage:[UIImage imageNamed:@"toolbar.settings.png"] forState:UIControlStateNormal];
        [settingsButton setImage:[UIImage imageNamed:@"toolbar.settings.selected.png"] forState:UIControlStateHighlighted];
    }
    
    return self;
}
@end
