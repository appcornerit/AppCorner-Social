//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPErrorHandler.h"

static NSError* lastError = nil;
static NSDate* lastErrorDate = nil;
static BOOL lastErrorShow = NO;

@implementation PAPErrorHandler

+(void) handleErrorMessage:(NSString*)messageKey titleKey:(NSString*)titleKey
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(messageKey,@"")};    
    NSError* error = [[NSError alloc] initWithDomain:kPAPErrorDomain code:0 userInfo:userInfo];
    [PAPErrorHandler handleError:error titleKey:titleKey];
}

+(void) handleError:(NSError*)error titleKey:(NSString*)titleKey
{
    if(!error && !titleKey)
        return;
    
    NSArray* keyForStatusBar = @[@""];
    
    if(![DKManager endpointReachable])
    {
        lastError = error;
        lastErrorDate = [NSDate date];
        lastErrorShow = YES;
        [DKManager showErrorInStatusBar:NSLocalizedString(@"error.connection.title",nil)];
    }
    else
    {
        //hide the same error
        if(lastError && lastError.code == error.code && lastErrorShow)
        {
            NSTimeInterval intervall = [[NSDate date] timeIntervalSinceDate: lastErrorDate];
            if(intervall < 2.0)
            {
                lastError = error;
                lastErrorDate = [NSDate date];
                lastErrorShow = NO;
                return;
            }
        }
        
        lastError = error;
        lastErrorDate = [NSDate date];
        lastErrorShow = YES;
        
        
        NSString* errorKey = @"error.generic";
        if(error) errorKey = [error localizedDescription];
        if(!titleKey) titleKey = @"error.generic";
        
        //Status message
        if([keyForStatusBar containsObject:errorKey])
        {
            [DKManager showErrorInStatusBar:NSLocalizedString(errorKey, @"")];
        }
        else
        {            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(titleKey, nil) message:NSLocalizedString(errorKey,@"") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
        }
    }
}

+(void) handleSuccess:(NSString*)success
{
    [DKManager showSuccessInStatusBar:NSLocalizedString(success,nil)];
}

+(void) handleMessage:(NSString*)message
{
    [DKManager showMessageInStatusBar:NSLocalizedString(message,nil)];
}

+(void) dismissMessage
{
    [DKManager dismissMessageInStatusBar];
}
@end
