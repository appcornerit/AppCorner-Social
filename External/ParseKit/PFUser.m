//
//  PFUser.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//


#import "PFUser.h"

@implementation PFUser 

static PFUser* currentUser = nil;

+ (PFUser *)currentUser{
    
    return currentUser;
}

+ (void)logOut{
    if(currentUser){
        NSError *error = nil;
        [currentUser.dkEntity logout:&error];
        [DKManager clearAllCachedResults];
        
        currentUser = nil;
    }
    if (FBSession.activeSession.isOpen) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

+ (PFQuery *)query{
    PFQuery * query = [PFQuery queryWithClassName:kUserClassName];
    query.dkQuery.cachePolicy = DKCachePolicyUseCacheElseLoad;
    query.dkQuery.maxCacheAge = 86400 * 30; //30 days
    return query;
}

+ (void)setCurrentUser:(PFUser *)user{
    currentUser = user;
}

-(NSString*)username{
	return [self objectForKey:kUserNameKey];
}

- (void)setUsername:(NSString *)username{
	[self setObject:username forKey:kUserNameKey];
}

-(NSString*)password{
	return [self objectForKey:kUserPasswordKey];
}

- (void)setPassword:(NSString *)password{
	[self setObject:password forKey:kUserPasswordKey];
}

+ (PFUser *)user{
	PFObject * user = [PFUser objectWithClassName: kUserClassName];
    user.dkEntity.cachePolicy = DKCachePolicyUseCacheElseLoad;
    user.dkEntity.maxCacheAge = 86400 * 30; //30 days            
    return (PFUser*) user;
}

@end
