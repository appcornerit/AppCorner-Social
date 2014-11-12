//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "Sync.h"

@implementation Sync

static PFObject* currentSync = nil;

+ (PFObject *)currentSync{
    return currentSync;
}

+ (PFQuery *)query{
    PFQuery * query = [PFQuery queryWithClassName:kPAPSyncClassKey];
    query.dkQuery.cachePolicy = DKCachePolicyIgnoreCache;
    return query;
}

+ (void)setCurrentSync:(PFObject *)sync{
    currentSync = sync;
}

@end
