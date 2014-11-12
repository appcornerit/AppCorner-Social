//
//  PFPush.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFPush : NSObject

//- (void)setChannel:(NSString *)channel;
//- (void)setChannels:(NSArray *)channels;
//- (void)setData:(NSDictionary *)data;
//- (void)sendPushInBackground;
+ (void)storeDeviceToken:(id)deviceToken;

@end
