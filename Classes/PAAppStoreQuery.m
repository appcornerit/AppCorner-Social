//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAAppStoreQuery.h"
#import <DeploydKit/AFJSONRequestOperation.h>
#import "PAPiTunesCountry.h"


@implementation PAAppStoreQuery

+(void) initialize
{

}

-(void) loadAppWithAppId:(NSString *)appId completionBlock:(PAAppResultBlock)block{
    PAApp *app = (PAApp*)[PAApp objectWithClassName:kAppClassName];
    app.appId = appId;
    [self loadApp:app completionBlock:block];
}

-(void) loadApp:(PAApp *)app completionBlock:(PAAppResultBlock)block{
    NSArray* apps = @[app];
    [self loadApps:apps completionBlock:^(NSArray * apps, NSError * error) {
        if (block)
        {
            block(app, error);
        }
    }];
}

-(void) loadApps:(NSArray *)apps completionBlock:(void (^)(NSArray* apps, NSError * error))block{
    NSString *countryCode = [PAPiTunesCountry getStoreCountryForCurrenUser];
    [self loadApps: apps withCountry:countryCode completionBlock:block];
}

-(void) loadApps:(NSArray *)apps withCountry:(NSString*)country completionBlock:(void (^)(NSArray* apps, NSError * error))block{
    _isLoading = YES;
    
    NSMutableArray *appIds = [[NSMutableArray alloc]initWithCapacity:apps.count];
    for (PAApp* app in apps) {
        if(app.appId)
            [appIds addObject:app.appId];
    }
    
    NSSet *appsIdSet = [NSSet setWithArray:appIds];
    NSString *appString = [[appsIdSet allObjects] componentsJoinedByString:@","];
    NSMutableString *requestUrlString = [[NSMutableString alloc] init];
    [requestUrlString appendFormat:@"https://itunes.apple.com/lookup"];
    [requestUrlString appendFormat:@"?id=%@", appString];
    [requestUrlString appendFormat:@"&country=%@", country];
    NSURL *requestURL = [[NSURL alloc] initWithString:requestUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.cachePolicy = self.cachePolicy;
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             [self parseDictionary:JSON withApps:apps countryCode:country];
                                             _isLoading = NO;
                                             if (block)
                                             {
                                                 block(apps, nil);
                                             }
                                         }
                                         
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             _isLoading = NO;                                             
                                             if (block)
                                             {
                                                 block(apps, error);
                                             }
                                         }];
    [operation start];
}

-(void) loadAppsForTerm:(NSString*)searchTerm completionBlock:(void (^)(NSArray* apps, NSError * error))block{
    NSString *countryCode = [PAPiTunesCountry getStoreCountryForCurrenUser];
    [self loadAppsForTerm:searchTerm withCountry:countryCode completionBlock:block];
}


-(void) loadAppsForTerm:(NSString*)searchTerm withCountry:(NSString*)countryCode completionBlock:(void (^)(NSArray* apps, NSError * error))block{

    _isLoading = YES;
    NSMutableString *requestUrlString = [[NSMutableString alloc] init];
    [requestUrlString appendFormat:@"https://itunes.apple.com/search"];
    [requestUrlString appendFormat:@"?term=%@", searchTerm];
    [requestUrlString appendFormat:@"&country=%@", countryCode];
    [requestUrlString appendFormat:@"&entity=software"];
    NSURL *requestURL = [[NSURL alloc] initWithString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    request.cachePolicy = self.cachePolicy;
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                         {
                                             NSArray* apps = [self parseDictionary:JSON countryCode:countryCode];
                                             _isLoading = NO;
                                             if (block)
                                             {
                                                 block(apps, nil);
                                             }
                                         }
                                         
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                         {
                                             _isLoading = NO;
                                             if (block)
                                             {
                                                 block([[NSArray alloc]init], error);
                                             }
                                         }];
    [operation start];
}


-(void) parseDictionary:(NSDictionary *) dictionary withApps:(NSArray*)apps countryCode:(NSString*)countryCode
{
    NSArray *array = dictionary[@"results"];
    if(array == nil){
        NSLog(@"Expected 'results' array");
        return;
    }
    for (PAApp* app in apps) {
        for (NSDictionary *resultDict in array) {
            if(app.appId && [app.appId isEqualToString:[resultDict[@"trackId"] stringValue]])
            {
                [self parseApp:resultDict withApp:app countryCode:countryCode];
                break;
            }
        }
    }
}

-(NSArray*) parseDictionary:(NSDictionary *) dictionary countryCode:(NSString*)countryCode
{
    NSMutableArray* results = [[NSMutableArray alloc]init];
    
    NSArray *array = dictionary[@"results"];
    if(array == nil){
        NSLog(@"Expected 'results' array");
        return results;
    }
    
    for (NSDictionary *resultDict in array) {
        PAApp* app = (PAApp*)[PAApp objectWithClassName:kPAPAppClassKey];
        [self parseApp:resultDict withApp:app countryCode:countryCode];
        [results addObject:app];
    }
    return results;
}

-(void)parseApp:(NSDictionary *)result withApp:(PAApp*)app countryCode:(NSString*)countryCode
{
    app.bundleId = result[@"bundleId"];
    app.name = result[@"trackName"];
    app.genre = NSLocalizedString(result[@"primaryGenreName"],nil);
    app.appId = [result[@"trackId"] stringValue];
    app.iconIsPrerendered = [result[@"icon-is-prerendered"] boolValue];
    
    NSArray *features = result[@"features"];
    app.isUniversal = [features containsObject:@"iosUniversal"];
    app.formattedPrice = NSLocalizedString([result[@"formattedPrice"] uppercaseString],nil);
    NSString *iconUrlString = result[@"artworkUrl512"];
    
    NSString *iconThumbnailUrlString = result[@"artworkUrl60"];
    app.iconThumbnailURL = iconThumbnailUrlString;
    
    app.iconURL = result[@"artworkUrl100"];
    app.userRatingAllVersions = [result[@"averageUserRating"] floatValue];
    app.userRatingCountAllVersions = [result[@"userRatingCount"] integerValue];
    app.userRating = [result[@"averageUserRatingForCurrentVersion"] floatValue];
    app.userRatingCount = [result[@"userRatingCountForCurrentVersion"] integerValue];
    app.loaded = YES;
    
    [app setObject:app.appId forKey:kPAPAppIDKey];
    [app setObject:[countryCode lowercaseString] forKey:kPAPAppCountryKey];
    
    app.artistName= result[@"artistName"];
    app.artworkURL60= result[@"artworkUrl60"];
    app.artworkURL100= result[@"artworkUrl100"];
    app.storeURL= result[@"trackViewUrl"];
    app.kind= result[@"kind"];
    app.price= result[@"price"];
    app.currency= result[@"currency"];
    
    app.screenshotUrls = result[@"screenshotUrls"];
    
    if(app.screenshotUrls.count == 0 && iconUrlString)
    {
        app.screenshotUrls = @[iconUrlString];
    }
}


@end
