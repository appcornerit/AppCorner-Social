//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "Country.h"

@implementation Country

static PFObject* currentCountry = nil;

+ (PFObject *)currentCountry{
    return currentCountry;
}

+ (PFQuery *)query{
    PFQuery * query = [PFQuery queryWithClassName:kPAPCountryClassKey];
    query.dkQuery.cachePolicy = DKCachePolicyIgnoreCache;
    return query;
}

+ (void)setCurrentCountry:(PFObject *)country{
    currentCountry = country;
}

@end
