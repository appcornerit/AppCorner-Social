//
//  PFConstants.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;
@class PFUser;
@class PAApp;

//typedef enum {
//    PFLogInFieldsFacebook = 1 << 3,
//} PFLogInFields;

typedef NS_OPTIONS(NSUInteger, PFLogInFields) {
    PFLogInFieldsNone = 0,
    PFLogInFieldsUsernameAndPassword = 1 << 0,
    PFLogInFieldsPasswordForgotten = 1 << 1,
    PFLogInFieldsLogInButton = 1 << 2,
    PFLogInFieldsFacebook = 1 << 3,
    PFLogInFieldsTwitter = 1 << 4,
    PFLogInFieldsSignUpButton = 1 << 5,
    PFLogInFieldsDismissButton = 1 << 6,
    
    PFLogInFieldsDefault = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton
} ;

typedef NS_ENUM(NSInteger, PFCachePolicy) {
    kPFCachePolicyIgnoreCache = 0,
    kPFCachePolicyCacheOnly,
    kPFCachePolicyNetworkOnly,
    kPFCachePolicyCacheElseNetwork,
    kPFCachePolicyNetworkElseCache,
    kPFCachePolicyCacheThenNetwork
} ;

extern NSInteger const kPFErrorObjectNotFound;
extern NSInteger const kPFErrorCacheMiss;

typedef void (^PFBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^PFIntegerResultBlock)(int number, NSError *error);
typedef void (^PFArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^PFObjectResultBlock)(PFObject *object, NSError *error);
typedef void (^PFSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^PFUserResultBlock)(PFUser *user, NSError *error);
typedef void (^PFDataResultBlock)(NSData *data, NSError *error);
typedef void (^PFDataStreamResultBlock)(NSInputStream *stream, NSError *error);
typedef void (^PFProgressBlock)(int percentDone);

//Class keys
extern NSString *const kUserClassName;
extern NSString *const kAppClassName;
extern NSString *const kInstallationClassName;

//Field keys
extern NSString *const kUserNameKey;
extern NSString *const kUserPasswordKey;
extern NSString *const kUserFacebookIDKey;
extern NSString *const kUserDisplayNameKey;
extern NSString *const kUserFBAccessTokenKey;
extern NSString *const kUserEmailKey;
extern NSString *const kUserEmailVerifiedKey;


typedef void (^PAAppResultBlock)(PAApp *app, NSError *error);
