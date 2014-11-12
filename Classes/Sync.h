//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <Foundation/Foundation.h>

@interface Sync : PFObject

+ (PFObject *)currentSync;
+ (PFQuery *)query;
+ (void)setCurrentSync:(PFObject *)sync;

@end
