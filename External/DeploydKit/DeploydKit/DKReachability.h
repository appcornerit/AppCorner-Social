//
//  DKReachability.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 appcorner.it. All rights reserved.
//
/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE. 
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

/**
 * Does ARC support support GCD objects?
 * It does if the minimum deployment target is iOS 6+ or Mac OS X 8+
 **/
#if TARGET_OS_IPHONE

// Compiling for iOS

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif

#else

// Compiling for Mac OS X

#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080     // Mac OS X 10.8 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1     // Mac OS X 10.7 or earlier
#endif

#endif


extern NSString *const kReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, DKNetworkStatus) 
{
	// Apple NetworkStatus Compatible Names.
	DKNotReachable     = 0,
	DKReachableViaWiFi = 2,
	DKReachableViaWWAN = 1
} ;

@class DKReachability;

typedef void (^NetworkReachable)(DKReachability * reachability);
typedef void (^NetworkUnreachable)(DKReachability * reachability);

@interface DKReachability : NSObject

@property (nonatomic, copy) NetworkReachable    reachableBlock;
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;


@property (nonatomic, assign) BOOL reachableOnWWAN;

+(DKReachability*)reachabilityWithHostname:(NSString*)hostname;
+(DKReachability*)reachabilityForInternetConnection;
+(DKReachability*)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;
+(DKReachability*)reachabilityForLocalWiFi;

-(DKReachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL startNotifier;
-(void)stopNotifier;

@property (NS_NONATOMIC_IOSONLY, getter=isReachable, readonly) BOOL reachable;
@property (NS_NONATOMIC_IOSONLY, getter=isReachableViaWWAN, readonly) BOOL reachableViaWWAN;
@property (NS_NONATOMIC_IOSONLY, getter=isReachableViaWiFi, readonly) BOOL reachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
@property (NS_NONATOMIC_IOSONLY, getter=isConnectionRequired, readonly) BOOL connectionRequired; // Identical DDG variant.
//@property (NS_NONATOMIC_IOSONLY, readonly) BOOL connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
@property (NS_NONATOMIC_IOSONLY, getter=isConnectionOnDemand, readonly) BOOL connectionOnDemand;
// Is user intervention required?
@property (NS_NONATOMIC_IOSONLY, getter=isInterventionRequired, readonly) BOOL interventionRequired;

@property (NS_NONATOMIC_IOSONLY, readonly) DKNetworkStatus currentReachabilityStatus;
@property (NS_NONATOMIC_IOSONLY, readonly) SCNetworkReachabilityFlags reachabilityFlags;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *currentReachabilityString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *currentReachabilityFlags;

@end
