//
//  DKRequest.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 appcorner.it. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKRequest.h"
#import "DKManager.h"
#import "DKNetworkActivity.h"
#import <objc/runtime.h>
#import "NSData+Deploydkit.h"

@interface DKRequest ()
    @property (nonatomic, copy, readwrite) NSString *endpoint;
@end

// DEVNOTE: Allow untrusted certs in debug version.
// This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug

@interface NSURLRequest (DeploydKit)

+ (BOOL)setAllowsAnyHTTPSCertificate:(BOOL)flag forHost:(NSString *)host;

@end

#endif

@implementation DKRequest

+ (DKRequest *)request {
  return [[self alloc] init];
}

- (instancetype)init {
  return [self initWithEndpoint:[DKManager APIEndpoint]];
}

- (instancetype)initWithEndpoint:(NSString *)absoluteString {
  self = [super init];
  if (self) {
    self.endpoint = absoluteString;
    self.cachePolicy = DKCachePolicyIgnoreCache;
  }
  return self;
}

- (id)sendRequestWithMethod:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error {
  return [self sendRequestWithData:nil method:apiMethod entity:entityName error:error];
}

- (id)sendRequestWithObject:(id)JSONObject method:(NSString *)apiMethod entity:(NSString *)entityName error:(NSError **)error {
  // Wrap special objects before encoding JSON
  JSONObject = [object_setClass(self, [DKRequest class]) wrapSpecialObjectsInJSON:JSONObject];
    
  // Encode JSON
  NSError *JSONError = nil;
  NSData *JSONData = [NSJSONSerialization dataWithJSONObject:JSONObject options:0 error:&JSONError];
    
  if (JSONError != nil) {
    [NSError writeToError:error
                     code:DKErrorInvalidParams
              description:NSLocalizedString(@"Could not JSON encode request object", nil)
                 original:JSONError];
    return nil;
  }
    
  return [self sendRequestWithData:JSONData method:apiMethod entity:entityName error:error];
}

- (id)sendRequestWithData:(NSData *)bodyData method:(NSString *)apiMethod
                   entity:(NSString *)entityName error:(NSError **)error {
    
  //Append json to url
  if([apiMethod isEqualToString:@"query"] && bodyData && bodyData.length > 2){
        NSMutableString * queryParams = [NSMutableString stringWithString:entityName];
        NSString *jsonString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        if([entityName rangeOfString:@"?"].location == NSNotFound)
            [queryParams appendFormat:@"?"];
        else
            [queryParams appendFormat:@"&"];
        [queryParams appendString: jsonString];
        entityName = queryParams;
  }
    
  NSString* urlString = [self.endpoint stringByAppendingString:entityName];
    
  // Create url request
  NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:URL];
  req.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
  
  // DEVNOTE: Timeout interval is quirky
  // https://devforums.apple.com/thread/25282
  req.timeoutInterval = 20.0;
  req.HTTPMethod = [self httpMethod:apiMethod];
    
  if([req.HTTPMethod isEqualToString:@"POST"] || [req.HTTPMethod isEqualToString:@"PUT"]){
      if (bodyData.length > 0) {
          req.HTTPBody = bodyData;
      }
  
      [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  }
    
  // Log request
  [object_setClass(self, [DKRequest class]) logData:req.HTTPBody isOut:YES url:urlString];
    
  // DEVNOTE: Allow untrusted certs in debug version.
  // This has to be excluded in production versions - private API!
#ifdef CONFIGURATION_Debug
  [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:URL.host];
#endif
  
  NSError *requestError = nil;
  NSHTTPURLResponse *response = nil;
  NSData *result = nil;
    
  req.cachePolicy = [self getNSURLRequestCachePolicy];
  result = [self sendSynchronousRequest:req returningResponse:&response error:error];
    
  return [object_setClass(self, [DKRequest class]) parseResponse:response withData:result error:error];
}


-(NSURLRequestCachePolicy) getNSURLRequestCachePolicy{
    NSURLRequestCachePolicy policy = NSURLRequestReloadIgnoringCacheData;
    if(![DKManager endpointReachable]) //DKCachePolicyUseCacheIfOffline
    {
        [DKManager showErrorInStatusBar:NSLocalizedString(@"error.connection.title",nil)];
        return NSURLRequestReturnCacheDataDontLoad;
    }
    
    switch (self.cachePolicy)
    {
        case DKCachePolicyIgnoreCache:
            policy = NSURLRequestReloadIgnoringCacheData;
            break;
        case DKCachePolicyUseCacheElseLoad:
            policy = NSURLRequestReturnCacheDataElseLoad;
            break;
    }
    return policy;
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    // Start network activity indicator
    [DKNetworkActivity begin];
    
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:response timeout:20.0 error:error];
    
    // End network activity
    [DKNetworkActivity end];
    return data;
}

+ (BOOL)canParseResponse:(NSHTTPURLResponse *)response {
  NSInteger code = response.statusCode;
  return (code == 200 || code == 204 || code == 400);
}

+ (id)parseResponse:(NSHTTPURLResponse *)response withData:(NSData *)data error:(NSError **)error{
  if (![self canParseResponse:response]) {
    if(!error)
    {
        [NSError writeToError:error
                     code:DKErrorUnknownStatus
              description:[NSString stringWithFormat:NSLocalizedString(@"Unknown response (%i)", nil), response.statusCode]
                 original:nil];
    }
    else
    {
//        NSError* resError = *error;
//        NSLog(@"Handled error: %@",resError.localizedDescription);
    }
  }
  else {

    // Log response
    [self logData:data isOut:NO url:response.URL.absoluteString];
    
    if (response.statusCode == DKResponseStatusSuccess) {
      id resultObj = nil;
      NSError *JSONError = nil;
      
      // A successful operation must not always return a JSON body
      if (data.length > 0) {      
        resultObj = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingAllowFragments
                                                      error:&JSONError];
      }
      if (JSONError != nil) {
        [NSError writeToError:error
                         code:DKErrorInvalidResponse
                  description:NSLocalizedString(@"Could not deserialize JSON response", nil)
                     original:JSONError];
      }
      else {
        return [self unwrapSpecialObjectsInJSON:resultObj];
      }
    }
    else if (response.statusCode == DKResponseStatusError && error){
          //e.x.: NSLocalizedRecoverySuggestion = "{\"errors\":{\"errorKey\":\"error.apppurchase.limit.duplicate\"},\"status\":400}";
          NSError* resError = *error;
          id objErr = (resError.userInfo)[NSLocalizedRecoverySuggestionErrorKey];
          if(objErr)
          {
              NSError *JSONError = nil;
              NSData *jsonData = [objErr dataUsingEncoding:NSUTF8StringEncoding];
              id resultObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&JSONError];
              if (JSONError != nil) {
                  [NSError writeToError:error
                                   code:DKErrorInvalidResponse
                            description:NSLocalizedString(@"Could not deserialize JSON error response", nil)
                               original:JSONError];
              }
              else if ([resultObj isKindOfClass:[NSDictionary class]]) {
                  NSNumber *status = resultObj[@"status"];
                  NSString *message = resultObj[@"message"];
                  if(!message)
                  {
                      NSDictionary *errors = resultObj[@"errors"];
                      if(errors)
                      {
                          message = NSLocalizedString([errors valueForKey:@"errorKey"],@"");
                      }
                  }
                  [NSError writeToError:error
                                   code:status.integerValue
                            description:message
                               original:nil];
              }
          }
          else{
              [NSError writeToError:error
                               code:DKErrorInvalidResponse
                        description:NSLocalizedString(@"Could not deserialize JSON error", nil)
                           original:nil];
          }
      }
  }
  return nil;
}

-(NSString*)httpMethod:(NSString*)op{
    if([op isEqualToString:@"save"] || [op isEqualToString:@"login"] || [op isEqualToString:@"fblogin"] ||
       [op isEqualToString:@"logout"] || [op isEqualToString:@"apn"]) return @"POST";
    if([op isEqualToString:@"update"]) return @"PUT";
    if([op isEqualToString:@"delete"]) return @"DELETE";
    return @"GET"; //refresh/query/me
}

@end

@implementation DKRequest (Wrapping)

+ (id)iterateJSON:(id)JSONObject modify:(id (^)(id obj))handler {
  id converted = handler(JSONObject);
  if ([converted isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (id key in converted) {
      id obj = converted[key];
      dict[key] = [self iterateJSON:obj modify:handler];
    }
    converted = [NSDictionary dictionaryWithDictionary:dict];
  }
  else if ([converted isKindOfClass:[NSArray class]]) {
    NSMutableArray *ary = [NSMutableArray new];
    for (id obj in converted) {
      [ary addObject:[self iterateJSON:obj modify:handler]];
    }
    converted = [NSArray arrayWithArray:ary];
  }
  return converted;
}


#define kDKObjectDataToken @"dk:data"

+ (id)wrapSpecialObjectsInJSON:(id)obj {
    return [self iterateJSON:obj modify:^id(id objectToModify) {
        // NSData
        if ([objectToModify isKindOfClass:[NSData class]]) {
            return @{kDKObjectDataToken: [(NSData *)objectToModify base64String]};
        }
        return objectToModify;
    }];
}

+ (id)unwrapSpecialObjectsInJSON:(id)obj {
    return [self iterateJSON:obj modify:^id(id objectToModify) {
        if ([objectToModify isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)objectToModify;
            
            // NSData
            NSString *base64 = dict[kDKObjectDataToken];
            if ([base64 isKindOfClass:[NSString class]]) {
                if (base64.length > 0 && dict.count == 1) {
                    return [NSData dataWithBase64String:base64];
                }
            }
        }
        return objectToModify;
    }];
}

@end

@implementation DKRequest (Logging)

+ (void)logData:(NSData *)data isOut:(BOOL)isOut url:(NSString*)url{
  if ([DKManager requestLogEnabled]){ 
    if (data.length > 0) {
      NSData *logData = data;
      if (data.length > 3000) {
        logData = [data subdataWithRange:NSMakeRange(0, 3000)];
      }
      NSLog(@"URL[%@ %@] BODY: %@",
            (isOut ? @"OUT" : @"IN"),(url?url:@""),
            [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding]);
    }
    else
    {
        NSLog(@"URL[%@ %@]",(isOut ? @"OUT" : @"IN"),(url?url:@""));
    }
  }
}

@end
