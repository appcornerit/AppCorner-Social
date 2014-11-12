//
//  PFFacebookUtils.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFFacebookUtils.h"

@implementation PFFacebookUtils

NSString *const FBSessionStateChangedNotification = @"it.appcorner.Login:FBSessionStateChangedNotification";

+ (void)initializeWithPermissions:(NSArray *)permissions {
    @synchronized([PFFacebookUtils class]) {
        //[self initFacebook:permissions];
    }
}


+ (PF_Session *)facebook{
    return [FBSession activeSession];
}

+ (BOOL)extendAccessTokenIfNeededForUser:(PFUser *)user block:(PFBooleanResultBlock)block{return NO;}

+ (BOOL)handleOpenURL:(NSURL *)url{
    // attempt to extract a token from the url
    return [[FBSession activeSession] handleOpenURL:url];
}

+ (void)initializeFacebook
{
    //do nothing
}

@end
