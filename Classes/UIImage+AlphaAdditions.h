//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

// http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/

@interface UIImage (Alpha)
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasAlpha;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
@end