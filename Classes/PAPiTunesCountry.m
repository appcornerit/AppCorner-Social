//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPiTunesCountry.h"
#import "Sync.h"
#import "Country.h"

@implementation PAPiTunesCountry

+(void)saveAppStoreCountryForCurrenUser:(PFBooleanResultBlock)callback
{
    NSArray *identifiers = nil;
    if([Sync currentSync])
    {
        NSString* identifier = [[Sync currentSync] objectForKey:kPAPSyncCountryCheckProductId];
        if(identifier)
        {
            identifiers = @[identifier];
        }
    }
    
    PFUser* user = [PFUser currentUser];
    if(!user)
    {
        callback(NO, nil);
        return;
    }
    
    NSString* storeCountry = [[[NSLocale currentLocale]objectForKey: NSLocaleCountryCode] lowercaseString];
    [user setObject:storeCountry forKey:kPAPUserAppStoreCountry];
    [user saveEventually];
    callback(YES, nil);
    return;
}

+(NSString*)getStoreCountryForCurrenUser
{
    NSString* storeCountry = [[[NSLocale currentLocale]objectForKey: NSLocaleCountryCode] lowercaseString];
    PFUser* user = [PFUser currentUser];
    if(!user)
    {
        return storeCountry;
    }
    NSString* priceLocaleCountry = [user objectForKey:kPAPUserAppStoreCountry];
    if(priceLocaleCountry)
    {
        return priceLocaleCountry;
    }
    return storeCountry;
}

@end
