//
//  YLActivityIndicatorView.h
//  YLActivityIndicator
//
//  Created by Eric Yuan on 13-1-15.
//  Copyright (c) 2013年 jimu.tv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLActivityIndicatorView : UIView {
    BOOL      _isAnimating;
    NSTimer*  _timer;
    BOOL      _hidesWhenStopped;
    NSInteger _currentStep;
    NSInteger _dotCount;
    CGFloat   _duration;
}

@property (nonatomic, assign)BOOL hidesWhenStopped;
@property (nonatomic, assign)NSInteger dotCount;
@property (nonatomic, assign)CGFloat duration;

- (void)startAnimating;
- (void)stopAnimating;
@property (NS_NONATOMIC_IOSONLY, getter=isAnimating, readonly) BOOL animating;

- (instancetype)init;

@end
