//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

@interface PAPiTunesCountry : NSObject

+(void)saveAppStoreCountryForCurrenUser:(PFBooleanResultBlock)callback;
+(NSString*)getStoreCountryForCurrenUser;

@end
