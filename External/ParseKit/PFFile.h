//
//  PFFile.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFFile : NSObject

@property (strong, nonatomic) NSString *url;
@property (readonly) BOOL isDataAvailable;

+ (instancetype)fileWithData:(NSData *)data;

- (void)getDataInBackgroundWithBlock:(PFDataResultBlock)block;

@end