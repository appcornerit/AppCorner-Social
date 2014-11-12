//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "SyncManager.h"
#import "Sync.h"
#import "Country.h"
#import "AppDelegate.h"
#import "PAPiTunesCountry.h"

@implementation SyncManager

+(void)sync:(PFBooleanResultBlock)callback
{
    PFQuery* query = [Sync query];
    NSError* error = nil;
    NSArray *array = [query findObjects:&error];
    NSNumber * appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    
    if(!error && [array count] > 0)
    {
        PFObject* sync = (PFObject*)array[0];
        [Sync setCurrentSync:sync];
        NSNumber* version = [[Sync currentSync] objectForKey:kPAPSyncMinVersionKey];
        
        if([appVersion floatValue] < [version floatValue])
        {
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"sync.error.update", nil)};
            error = [[NSError alloc]initWithDomain:kPAPErrorDomain code:0 userInfo:userInfo];
            callback(NO,error);
            return;
        }
    }
    else
    {
        callback(NO,error);
        return;
    }

    //update storeCountry
    [PAPiTunesCountry saveAppStoreCountryForCurrenUser:^(BOOL succeeded, NSError *error) {
        
        if(!succeeded)
        {
            [PAPErrorHandler handleErrorMessage:@"sync.error.countrymissing" titleKey:@"error.generic"];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
            return;
        }
        
        error = nil;
        PFQuery* queryCountry = [Country query];
        NSArray* array = [queryCountry findObjects:&error];
        
        if(!error && [array count] > 0)
        {
            //current locale is AppStore country
            NSString * currentLocale = [PAPiTunesCountry getStoreCountryForCurrenUser];
            
            BOOL found = NO;
            PFObject *countryDefault = nil;
            for (Country *country in array) {
                NSString* strCountry = [country objectForKey:kPAPCountry];
                
                if(strCountry)
                {
                    strCountry = [strCountry lowercaseString];
                    
                    if(!found &&
                       [strCountry isEqualToString:currentLocale])
                    {
                        [Country setCurrentCountry:country];
                        found = YES;
                    }
                    if([strCountry isEqualToString:[[Sync currentSync] objectForKey:kPAPSyncDefaultLocaleKey]])
                    {
                        countryDefault = country;
                    }
                }
            }
            if(!found)
            {
                if(countryDefault)
                {
                    [Country setCurrentCountry:countryDefault];
                }
                else
                {
                    //Must never succeded
                    NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"sync.error.countrynotfound", @"")};
                    error = [[NSError alloc]initWithDomain:kPAPErrorDomain code:0 userInfo:userInfo];
                    callback(NO,error);
                    return;
                }
            }
        }
        else
        {
            callback(NO,error);
            return;
        }
        
        callback(YES,nil);
        
    }];
    
}



@end
