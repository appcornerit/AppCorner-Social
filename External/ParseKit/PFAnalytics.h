//
//  PFAnalytics.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PFAnalytics : NSObject

+ (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions;

+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo;

@end
