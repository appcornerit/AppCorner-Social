//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//


#import <UIKit/UIKit.h>
#import <DeploydKit/UIImageView+AFNetworking.h>

@interface PAAppIconImageView : UIImageView

@property (nonatomic,strong) PAApp* app;

- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)app NS_DESIGNATED_INITIALIZER;
    
@property (nonatomic, strong) UIActivityIndicatorView *placeholderActivityIndicatorView;

@end
