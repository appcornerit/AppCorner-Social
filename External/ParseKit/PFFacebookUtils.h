//
//  PFFacebookUtils.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

//@protocol PF_FBRequestDelegate;
@compatibility_alias PF_Session FBSession;
@compatibility_alias PF_FBRequest FBRequest;


@interface PFFacebookUtils : NSObject

    extern NSString *const FBSessionStateChangedNotification;

    + (PF_Session *)facebook;
//+ (void)initializeWithApplicationId:(NSString *)appId withPermissions:(NSArray*)permissions;
    + (void)initializeWithPermissions:(NSArray *)permissions;
    + (BOOL)extendAccessTokenIfNeededForUser:(PFUser *)user block:(PFBooleanResultBlock)block;
    + (BOOL)handleOpenURL:(NSURL *)url;

/*!
 Initializes the Facebook singleton. You must invoke this in order to use the Facebook functionality.
 You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file as
 described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
 */
+ (void)initializeFacebook;

@end
