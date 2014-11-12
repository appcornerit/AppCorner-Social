//
//  YLActivityIndicatorView.m
//  YLActivityIndicator
//
//  Created by Eric Yuan on 13-1-15.
//  Copyright (c) 2013年 jimu.tv. All rights reserved.
//

#import "YLActivityIndicatorView.h"

@implementation YLActivityIndicatorView

@synthesize hidesWhenStopped = _hidesWhenStopped;
@synthesize dotCount = _dotCount;
@synthesize duration = _duration;

- (void)setDefaultProperty
{
    _currentStep = 0;
    _dotCount = 3;
    _isAnimating = NO;
    _duration = .6f;
    _hidesWhenStopped = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setDefaultProperty];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithFrame:CGRectMake(0, 0, 20, 10)];
    
    return self;
}

#pragma mark - public
- (void)startAnimating
{
    if (_isAnimating) {
        return;
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_duration/(_dotCount*2+1)
                                              target:self
                                            selector:@selector(repeatAnimation)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    _isAnimating = YES;
    
    if (_hidesWhenStopped) {
        self.hidden = NO;
    }
}

- (void)stopAnimating
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    
    _isAnimating = NO;
    
    if (_hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

//#pragma mark - drawing
//- (UIColor*)currentBorderColor:(NSInteger)index
//{
//    if (_currentStep == index) {
//        return [UIColor colorWithRed:82.0f/255.0f
//                               green:111.0f/255.0f
//                                blue:167.0f/255.0f
//                               alpha:1];
//    } else if (_currentStep < index) {
//        return [UIColor clearColor];
//    } else {
//        if (_currentStep - index == 1) {
//            return [UIColor colorWithRed:158.0f/255.0f
//                                   green:172.0f/255.0f
//                                    blue:203.0f/255.0f
//                                   alpha:1];
//        } else {
//            return [UIColor colorWithRed:239.0f/255.0f
//                                   green:242.0f/255.0f
//                                    blue:246.0f/255.0f
//                                   alpha:1];
//        }
//    }
//}

- (UIColor*)currentInnerColor:(NSInteger)index
{
    if (_currentStep == index) {
        return [UIColor colorWithRed:0.0f/255.0f
                               green:122.0f/255.0f
                                blue:255.0f/255.0f
                               alpha:1];
//    } else if (_currentStep < index) {
//        return [UIColor clearColor];
    } else {
//        if (_currentStep - index == 1) {
//            return [UIColor colorWithRed:189.0f/255.0f
//                                   green:198.0f/255.0f
//                                    blue:219.0f/255.0f
//                                   alpha:1];
//        } else {
            return [UIColor colorWithRed:255.0f/255.0f
                                   green:255.0f/255.0f
                                    blue:255.0f/255.0f
                                   alpha:1];
//        }
    }
}

- (CGRect)currentRect:(NSInteger)index
{
    return CGRectMake(self.frame.size.width/(_dotCount*2+1),
                      0,
                      self.frame.size.width/(_dotCount*2+1),
                      self.frame.size.width/(_dotCount*2+1));
//    if (_currentStep == index) {
//        return CGRectMake(self.frame.size.width/(_dotCount*2+1),
//                          0,
//                          self.frame.size.width/(_dotCount*2+1),
//                          self.frame.size.height/(_dotCount*2+1));
//    } else { //if (_currentStep < index) {
//        return CGRectMake(self.frame.size.width/(_dotCount*2+1),
//                          self.frame.size.height/5.0,
//                          self.frame.size.width/(_dotCount*2+1),
//                          self.frame.size.height*3.0/5.0);
//    }
//    else {
//        if (_currentStep - index == 1) {
//            return CGRectMake(self.frame.size.width/(_dotCount*2+1),
//                              self.frame.size.height/10.0,
//                              self.frame.size.width/(_dotCount*2+1),
//                              self.frame.size.height*4.0/5.0);
//        } else {
//            return CGRectMake(self.frame.size.width/(_dotCount*2+1),
//                              self.frame.size.height/5.0,
//                              self.frame.size.width/(_dotCount*2+1),
//                              self.frame.size.height*3.0/5.0);
//        }
//    }
}

- (void)repeatAnimation
{
    _currentStep = ++_currentStep % (_dotCount*2+1);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    for (int i = 0; i < _dotCount; i++) {
        [[self currentInnerColor:i] setFill];
        [[self currentInnerColor:i] setStroke];
      //  [[self currentBorderColor:i] setStroke];
    
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect rect1 = [self currentRect:i];
        CGPathAddEllipseInRect(path, NULL, CGRectInset(rect1,1,1));
//        CGPathAddRect(path, NULL, rect1);
        
        CGContextBeginPath(context);
        CGContextAddPath(context, path);
//        CGContextSetLineWidth(context, 1);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
     
        CGContextTranslateCTM(context, self.frame.size.width/_dotCount, 0);
        CGPathRelease(path);
     
        
//        CGContextAddEllipseInRect(context, rect1);
//        CGContextSetFillColor(context, CGColorGetComponents([[UIColor blueColor] CGColor]));
//        CGContextFillPath(context);
    }
}

@end
