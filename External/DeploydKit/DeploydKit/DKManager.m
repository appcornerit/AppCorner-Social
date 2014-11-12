//
//  DKManager.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 appcorner.it. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKManager.h"
#import "DKRequest.h"
#import "DKReachability.h"
#import "KGStatusBar.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <DeploydKit/UIImageView+AFNetworking.h>

@implementation DKManager

static NSString *kDKManagerAPIEndpoint;
static BOOL kDKManagerRequestLogEnabled;
static NSString *kDKManagerAPISecret;
static NSString *kDKManagerSessionId;
static BOOL kDKManagerReachable;
static NSTimeInterval kDKManagerMaxCacheAge;


+ (DKManager *)sharedClient {
    static DKManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[DKManager alloc] initWithBaseURL:[NSURL URLWithString:kDKManagerAPIEndpoint]];
    });
    
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
    if ([[url scheme] isEqualToString:@"https"]){ // && [[url host] isEqualToString:@"alpha-api.app.net"]) {
        self.defaultSSLPinningMode = AFSSLPinningModePublicKey;
    } else {
        self.defaultSSLPinningMode = AFSSLPinningModeNone;
    }
    
    return self;
}

+ (void)setAPIEndpoint:(NSString *)absoluteString {
  NSURL *ep = [NSURL URLWithString:absoluteString];
  if (![ep.scheme isEqualToString:@"https"]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSLog(@"\n\nWARNING: DeploydKit API endpoint not secured! "
            "It's highly recommended to use SSL (current scheme is '%@')\n\n",
            ep.scheme);
    });
    
  }
  kDKManagerAPIEndpoint = [absoluteString copy];
    
  // allocate a reachability object
  DKReachability* reach = [DKReachability reachabilityWithHostname:ep.host];
  DKNetworkStatus internetStatus = [reach currentReachabilityStatus];
  if(internetStatus == DKNotReachable)
    kDKManagerReachable = NO;
  else
    kDKManagerReachable = YES;

  // here we set up a NSNotification observer. The Reachability that caused the notification
  // is passed in the object parameter
  [[NSNotificationCenter defaultCenter] addObserver:[self class]
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
  [reach startNotifier];
    
  [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

+ (void)setAPISecret:(NSString *)secret {
    kDKManagerAPISecret = [secret copy];
}

+ (void)setSessionId:(NSString *)sid {
  kDKManagerSessionId = [sid copy];
}

+ (NSString *)APIEndpoint {
  if (kDKManagerAPIEndpoint.length == 0) {
    [NSException raise:NSInternalInconsistencyException format:@"No API endpoint specified"];
    return nil;
  }
  return kDKManagerAPIEndpoint;
}

+ (NSURL *)endpointForMethod:(NSString *)method {
  NSString *ep = [[self APIEndpoint] stringByAppendingPathComponent:method];
  return [NSURL URLWithString:ep];
}

+ (NSString *)APISecret {
    if (kDKManagerAPISecret.length == 0) {
//        [NSException raise:NSInternalInconsistencyException format:@"No API secret specified"];
        return nil;
    }
    return kDKManagerAPISecret;
}

+ (NSString *)sessionId {
  return kDKManagerSessionId;
}

+ (dispatch_queue_t)queue {
  static dispatch_queue_t q;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    q = dispatch_queue_create("DeploydKit queue", DISPATCH_QUEUE_SERIAL);
  });
  return q;
}

+ (void)setRequestLogEnabled:(BOOL)flag {
  kDKManagerRequestLogEnabled = flag;
}

+ (BOOL)requestLogEnabled {
  return kDKManagerRequestLogEnabled;
}

+ (BOOL)endpointReachable {
    return kDKManagerReachable;
}

+ (void)setMaxCacheAge:(NSTimeInterval)maxCacheAge{
  kDKManagerMaxCacheAge = maxCacheAge;
}

+ (NSTimeInterval)maxCacheAge{
    return kDKManagerMaxCacheAge;
}

+(void)initCache
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024
                                                         diskCapacity:100 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[UIImageView af_sharedImageCache] setCountLimit : 30]; //avoid crash for image caching on device only
}

+ (void)clearAllCachedResults{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[UIImageView af_sharedImageCache] removeAllObjects];
}

//Called by DKReachability whenever status changes.
+ (void)reachabilityChanged: (NSNotification* )note
{    
    DKReachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [DKReachability class]]);
    DKNetworkStatus internetStatus = [curReach currentReachabilityStatus];
    if(internetStatus == DKNotReachable) {
        kDKManagerReachable = NO;
        [KGStatusBar showErrorWithStatus:NSLocalizedString(@"error.connection.title",nil)];
        return;
    }
    kDKManagerReachable = YES;
    [KGStatusBar dismiss];
}

+ (void)showMessageInStatusBar:(NSString*)status
{
    [KGStatusBar showOrUpdateStatus:status];
}

+ (void)showErrorInStatusBar:(NSString*)status
{
    [KGStatusBar showErrorWithStatus:status];
}

+ (void)showSuccessInStatusBar:(NSString*)status
{
    [KGStatusBar showSuccessWithStatus:status];
}

+ (void)dismissMessageInStatusBar
{
    [KGStatusBar dismiss];
}

@end
