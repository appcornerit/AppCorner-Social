//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <Foundation/Foundation.h>

@interface PAPErrorHandler : NSObject

+(void) handleError:(NSError*)error titleKey:(NSString*)titleKey;
+(void) handleErrorMessage:(NSString*)messageKey titleKey:(NSString*)titleKey;

+(void) handleSuccess:(NSString*)success;
+(void) handleMessage:(NSString*)message;
+(void) dismissMessage;

@end
