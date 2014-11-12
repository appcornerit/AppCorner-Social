//
//  ParseKit.m
//  ParseKit
//
//  Created by Denis Berton on 20/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "Parse.h"

@implementation Parse

+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey{
    [DKManager setAPIEndpoint:applicationId];
    [DKManager setAPISecret:clientKey];
    [DKManager initCache];
}

+ (void)setRequestLogEnabled:(BOOL)flag{
	[DKManager setRequestLogEnabled:flag];
}

@end
