//
//  PFApplicationKey.m
//  ParseKit
//
//  Created by Denis Berton on 13/10/12.
//
//

#import "PFApplicationKey.h"

#ifdef ANYWALL
#import "PAWAppDelegate.h"
#endif

@implementation PFApplicationKey

//+ (BOOL) isPFFileKey:(NSString *)key{
//#ifdef ANYPIC
//    return  
////    [key isEqualToString: kPAPUserProfilePicSmallKey]||
////    [key isEqualToString: kPAPUserProfilePicMediumKey] ||
//    [key isEqualToString: kPAPAppIconKey] ||  
//    [key isEqualToString: kPAPAppIconThumbnailKey];
//#endif
//	return NO;
//}

+ (BOOL) isPFUserKey:(NSString *)key{
    return [key isEqualToString: kPAPAppUserKey] ||
    [key isEqualToString: kPAPActivityFromUserKey] ||
    [key isEqualToString: kPAPActivityToUserKey];
}

+ (BOOL) isPFGeoPointKey:(NSString *)key{
//	return [key isEqualToString: kPAWParseLocationKey];
    return NO;
}

+ (BOOL) isPAAppObjectKey:(NSString *)key{
    return [key isEqualToString: kPAPActivityAppIDKey];
}

+ (BOOL) isBOOLKey:(NSString *)key{
    return [key isEqualToString: kPAPUserAlreadyAutoFollowedFacebookFriendsKey];
}

+ (NSString*) getPAAppClassForKey:(NSString *)key{
    if([key isEqualToString: kPAPActivityAppIDKey]){
        return kPAPAppClassKey;
    }
    return nil;
}

@end
