//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPCommonGraphic.h"

@implementation PAPCommonGraphic

+(UIColor*) getBackgroundWhiteAlpha
{
    return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.6f];
}
+(UIColor*) getBackgroundWhiteWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:alpha];
}
+(UIColor*) getBackgroundBlueAlpha
{
    return [UIColor colorWithRed:21.0f/255.0f green:125.0f/255.0f blue:251.0f/255.0f alpha:0.6f];
}
+(UIColor*) getBackgroundBlueWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:21.0f/255.0f green:125.0f/255.0f blue:251.0f/255.0f alpha:alpha];
}
+(UIColor*) getBackgroundBlackAlpha
{
    return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.7f];
}
+(UIColor*) getBackgroundGreenAlpha
{
    return [UIColor colorWithRed:76.0f/255.0f green:217.0f/255.0f blue:100.0f/255.0f alpha:0.6f];
}
+(UIColor*) getBackgroundInternalUser
{
    return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.6f];
}
+(UIColor*) getBackgroundBlueBlur
{
   return [UIColor colorWithRed:0.0f/255.0f green:122.0/255.0f blue:255.0f/255.0f  alpha:1.0f];
}
+(UIColor*) getAquaColor
{
  return [UIColor colorWithRed:52.0f/255.0f green:170.0f/255.0f blue:220.0f/255.0f alpha:1.0];
}

@end
