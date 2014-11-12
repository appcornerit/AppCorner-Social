//
//  RSSParser.h
//  RSSParser
//
//  Created by Thibaut LE LEVIER on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeploydKit/AFXMLRequestOperation.h>
#import "PAApp.h"

typedef NS_ENUM(NSInteger, tIconSize){
    kIcon53,
    kIcon75,
    kIcon100
} ;

@interface RSSParser : AFXMLRequestOperation <NSXMLParserDelegate> {
    PAApp *currentApp;
    NSMutableArray *items;
    NSMutableString *tmpString;
    tIconSize currentIconSize;
    void (^block)(NSArray *feedItems);
}



+ (void)parseRSSFeedForRequest:(NSURLRequest *)urlRequest
                       success:(void (^)(NSArray *feedItems))success
                       failure:(void (^)(NSError *error))failure;

- (void)parseRSSFeedForRequest:(NSURLRequest *)urlRequest
                       success:(void (^)(NSArray *feedItems))success
                       failure:(void (^)(NSError *error))failure;


@end
