//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAApp.h"

@interface PAAppStoreQuery : NSObject

@property(nonatomic, assign, readonly) BOOL isLoading;
@property(nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

-(void) loadAppWithAppId:(NSString *)appId completionBlock:(PAAppResultBlock)block;
-(void) loadApp:(PAApp *)app completionBlock:(PAAppResultBlock)block;
-(void) loadApps:(NSArray *)apps completionBlock:(void (^)(NSArray* apps, NSError * error))block;
- (void) loadApps:(NSArray *)apps withCountry:(NSString*)country completionBlock:(void (^)(NSArray* apps, NSError * error))block;

-(void) loadAppsForTerm:(NSString*)searchTerm completionBlock:(void (^)(NSArray* apps, NSError * error))block;
-(void) loadAppsForTerm:(NSString*)searchTerm withCountry:(NSString*)countryCode completionBlock:(void (^)(NSArray* apps, NSError * error))block;

@end
