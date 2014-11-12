//
//  PFFile.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFFile.h"
#import <DeploydKit/UIImageView+AFNetworking.h>

@implementation PFFile
{
    UIImageView* fileImageView;
}

- (BOOL)isDataAvailable {
    return (self.url &&  self.url.length > 0);
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        fileImageView = [[UIImageView alloc] init];
        if(data)
        {
            fileImageView.image = [UIImage imageWithData:data];
        }
    }
    return self;
}

+ (instancetype)fileWithData:(NSData *)data{
    PFFile *file = [[self alloc] initWithData:data];
    return file;
}

- (void)getDataInBackgroundWithBlock:(PFDataResultBlock)block{
    if(!self.url)
    {
        NSLog(@"getDataInBackgroundWithBlock nil url");
        return;
    }
    
    block = [block copy];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:self.url]];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [fileImageView setImageWithURLRequest:request placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                      if (block != NULL) {
                                          block(UIImagePNGRepresentation(image), nil);
                                      }
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                      if (block != NULL) {
                                          block(nil, error);
                                      }
                                  }];
}


@end