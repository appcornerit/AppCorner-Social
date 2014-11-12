//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <UIKit/UIKit.h>
#import "PAAppIconImageView.h"
#import "TTTTimeIntervalFormatter.h"

@interface PAAppIconInfoView : UIView

@property (nonatomic,strong) PAApp* app;
@property (nonatomic,strong) PAAppIconImageView* iconImageView;

- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)app myApps:(BOOL)myApps NS_DESIGNATED_INITIALIZER;

@end
