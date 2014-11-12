//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <Foundation/Foundation.h>

@interface Country : PFObject

+ (PFObject *)currentCountry;
+ (PFQuery *)query;
+ (void)setCurrentCountry:(PFObject *)country;

@end
