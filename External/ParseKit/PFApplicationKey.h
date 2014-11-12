//
//  PFApplicationKey.h
//  ParseKit
//
//  Created by Denis Berton on 13/10/12.
//
//

#import <Foundation/Foundation.h>

@interface PFApplicationKey : NSObject
//    +(BOOL)isPFFileKey:(NSString *)key;
    +(BOOL)isPFUserKey:(NSString *)key;
    +(BOOL)isPFGeoPointKey:(NSString *)key;
    +(BOOL)isPAAppObjectKey:(NSString *)key;
    +(BOOL)isBOOLKey:(NSString *)key;
    +(NSString*)getPAAppClassForKey:(NSString *)key;
@end
