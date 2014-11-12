//
//  DKChannel.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 appcorner.it. All rights reserved.
//

#import "DKChannel.h"
#import "DKRequest.h"
#import "DKManager.h"
#import "DKEntity-Private.h"

static NSString * AFNormalizedDeviceTokenStringWithDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@implementation DKChannel

static DKChannel* currentChannel = nil;

+(DKChannel *)currentChannel{
    if(currentChannel){
        [currentChannel updateChannel];
        return currentChannel;
    }
    
    currentChannel = [[self alloc] initWithName:kDKEntityChannel];
        
    //NSString *identifier = [SecureUDID UDIDForDomain:[DKManager APIEndpoint] usingKey:[DKManager APISecret]];
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    DKQuery* query = [DKQuery queryWithEntityName:kDKEntityChannel];
    [query whereKey:kDKEntityChannelUDID equalTo:identifier];
    NSError* error = nil;
    NSArray* results = [query findAll:&error];
    if(!error)
    {
        if(results.count > 0){
            DKEntity *channel = [results lastObject];
            currentChannel.resultMap = channel.resultMap;
        }
        else{
            [currentChannel setObject:identifier forKey:kDKEntityChannelUDID];
        }
        [currentChannel updateChannel];
        return currentChannel;
    }
    return nil;
}

-(void)updateChannel
{
    NSString * appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    [currentChannel setObject:appVersion forKey:kDKEntityChannelAppVersion];
    //NSString * appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString * timeZone = [[NSTimeZone systemTimeZone] name]; //[[NSTimeZone defaultTimeZone] name];
    [currentChannel setObject:timeZone forKey:kDKEntityChannelTimeZone];
    NSString * currentLocale = [[NSLocale currentLocale] localeIdentifier];
    [currentChannel setObject:currentLocale forKey:kDKEntityChannelLocale];
    NSString * preferredLanguage = [NSLocale preferredLanguages][0];
    [currentChannel setObject:preferredLanguage forKey:kDKEntityChannelLanguage];
    NSString * deviceModel = [[UIDevice currentDevice] model];
    [currentChannel setObject:deviceModel forKey:kDKEntityChannelDeviceModel];
    NSString * deviceSystem = [NSString stringWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    [currentChannel setObject:deviceSystem forKey:kDKEntityChannelDeviceSystem];
    NSNumber * badge = @([UIApplication sharedApplication].applicationIconBadgeNumber);
    [currentChannel setObject:badge forKey:kDKEntityChannelBadge];
}

+ (void)storeDeviceToken:(id)deviceToken{
    [[DKChannel currentChannel] setObject:AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken) forKey:kDKEntityChannelDeviceToken];
}

//+ (void)storePrivateChannel:(id)privateChannel{
//    [[DKChannel currentChannel] setObject:privateChannel forKey:kDKEntityChannelPrivateChannels];
//}
//
//#ifdef __CORELOCATION__
//+ (CLLocationManager *)sharedLocationManager {
//    static CLLocationManager *_sharedLocationManager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if ([CLLocationManager locationServicesEnabled]) {
//            _sharedLocationManager = [[CLLocationManager alloc] init];
//            NSString * appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//            _sharedLocationManager.purpose = NSLocalizedStringFromTable(@"This application uses your current location to send targeted push notifications.", appName, nil);
//            _sharedLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//            [_sharedLocationManager startUpdatingLocation];
//        }
//    });
//    
//    return _sharedLocationManager;
//}
//#endif
//
//- (void)sendPushInBackground:(NSDictionary *)data channel:(NSString *)channel{
//    dispatch_async([DKManager queue], ^{
//        [self sendPush:data channels: @[channel]];
//    });
//}
//
//- (void)sendPushInBackground:(NSDictionary *)data channels:(NSArray *)channels{
//    dispatch_async([DKManager queue], ^{
//        [self sendPush:data channels:channels];
//    });
//}
//
//- (void)sendPush:(NSDictionary *)data channels:(NSArray *)channels{
//    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
//    
//    NSMutableArray *chArr = [NSMutableArray arrayWithArray: channels];    
//    NSArray * curChannels = [currentChannel objectForKey:kDKEntityChannelPrivateChannels];
//    if(curChannels)
//        [chArr removeObjectsInArray:curChannels];
//    if([chArr count] == 0) return;
//    
//    requestDict[@"data"] = data;
//    requestDict[kDKEntityChannelPrivateChannels] = chArr;    
//    
//    // Send request synchronously
//    DKRequest *request = [DKRequest request];
//    request.cachePolicy = DKCachePolicyIgnoreCache;
//    
//    NSError *requestError = nil;
//    [request sendRequestWithObject:requestDict method:@"apn" entity:kDKRequestPushChannel error:&requestError];
//}


@end
