//
//  PFPush.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFPush.h"

@implementation PFPush

//NSString * paramChannel = nil;
//NSArray * paramChannels = nil;
//NSDictionary * paramData = nil;
//
//- (void)setChannel:(NSString *)channel{
//    paramChannel = channel;
//    paramChannels = nil;
//}
//
//- (void)setChannels:(NSArray *)channels{
//    paramChannel = nil;
//    paramChannels = channels;
//}
//
//- (void)setData:(NSDictionary *)data{
//    paramData = data;
//}
//
//- (void)sendPushInBackground{
//    DKChannel* dkChannel = ((DKChannel*)[PFInstallation currentInstallation].dkEntity);
//    if(paramChannel && paramData){
//        [dkChannel sendPushInBackground:paramData channel:paramChannel];
//    }
//    else if(paramChannels && paramData){
//        [dkChannel sendPushInBackground:paramData channels:paramChannels];
//    }    
//}

+ (void)storeDeviceToken:(id)deviceToken{
    [DKChannel storeDeviceToken:deviceToken];
}

@end
