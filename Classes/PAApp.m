//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAApp.h"
#import "PAAppStoreQuery.h"
#import "PAPiTunesCountry.h"

@implementation PAApp

+ (PAApp *)createNewAppFromExistingApp:(PAApp *)app
{
    PAApp *newApp = [[self alloc] initWithName:kAppClassName];
    newApp.appId = [app.appId copy];
    [newApp setObject:newApp.appId forKey:kPAPAppIDKey];    
    newApp.bundleId = [app.bundleId copy];
    
    newApp.name = [app.name copy];
    newApp.genre = [app.genre copy];
    newApp.formattedPrice = [app.formattedPrice copy];
    newApp.iconURL = [app.iconURL copy];
    newApp.iconThumbnailURL = [app.iconThumbnailURL copy];
    newApp.iconIsPrerendered = app.iconIsPrerendered;
    newApp.userRatingCount = app.userRatingCount;
    newApp.userRating = newApp.userRating;
    newApp.isUniversal = newApp.isUniversal;
    
    newApp.artistName = [app.artistName copy];
    newApp.artworkURL60 = [app.artworkURL60 copy];
    newApp.artworkURL100 = [app.artworkURL100 copy];
    newApp.storeURL = [app.storeURL copy];
    newApp.kind = [app.kind copy];
    newApp.price = [app.price copy];
    newApp.currency = [app.currency copy];
    newApp.screenshotUrls = [[NSArray alloc]initWithArray:app.screenshotUrls];
    
    return newApp;
}


-(void) addScreenshotUrl:(NSString*)url
{
    if(!url)
    {
        return;
    }
    if(!self.screenshotUrls)
    {
        self.screenshotUrls = [[NSArray alloc]init];
    }
    if([self.screenshotUrls containsObject:url])
    {
        return;
    }

    NSMutableArray* array = [[NSMutableArray alloc]initWithArray:self.screenshotUrls];
    [array addObject:url];
    self.screenshotUrls = [[NSArray alloc] initWithArray:array];
}

-(void)setDkEntity:(DKEntity *)dkEntity
{
    super.dkEntity = dkEntity;
    self.appId = [dkEntity objectForKey:kPAPAppIDKey];
    _inCountryAppStore = NO;
}

- (id)objectForKey:(id)aKey
{
    if([aKey isKindOfClass:[NSString class]] && [aKey isEqualToString: kPAPAppIconKey])
    {
        PFFile *file = [PFFile fileWithData:nil];
        file.url = self.screenshotUrls[0];
        return file;
    }
    else if([aKey isKindOfClass:[NSString class]] && [aKey isEqualToString: kPAPAppIconThumbnailKey])
    {
        PFFile *file = [PFFile fileWithData:nil];
        file.url = self.iconThumbnailURL;
        return file;
    }
    else
    {
        return [super objectForKey:aKey];
    }
}

- (void)fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block {
    [super fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
        query.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.appId = [object objectForKey:kPAPAppIDKey];
        [query loadApp:self completionBlock:block];
    }];
}

- (void)existsInUserCountryAppStore:(PFBooleanResultBlock)block {
    NSString* appCountry = [self objectForKey:kPAPAppCountryKey];
    NSString* userCountry = [PAPiTunesCountry getStoreCountryForCurrenUser];
    if(appCountry && userCountry && [appCountry isEqualToString:userCountry])
    {
        _inCountryAppStore = YES;
        block(YES,nil);
        return;
    }
    
    PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
    query.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [query loadAppWithAppId:[self.appId copy] completionBlock:^(PAApp *app, NSError *error) {
        if(!error && app && app.loaded && [app.appId isEqualToString:self.appId])
        {
            _inCountryAppStore = YES;
            _inCountryFormattedPrice = app.formattedPrice;
            _inCountryPrice = app.price;
            block(YES,error);
        }
        else
        {
            _inCountryAppStore = NO;
            _inCountryFormattedPrice = nil;
            _inCountryPrice = 0;
            block(NO,error);
        }
    }];
}

- (void)existsInCountryAppStore:(NSString*)country block:(PFBooleanResultBlock)block {
    NSString* appCountry = [self objectForKey:kPAPAppCountryKey];
    if(appCountry && [appCountry isEqualToString:country])
    {
        block(YES,nil);
        return;
    }
    
    PAAppStoreQuery* query = [[PAAppStoreQuery alloc]init];
    query.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    PAApp *app = (PAApp*)[PAApp objectWithClassName:kAppClassName];    
    app.appId = [self.appId copy];
    NSArray* apps = @[app];
    [query loadApps:apps withCountry:country completionBlock:^(NSArray *apps, NSError *error) {
        if(!error && app && app.loaded && [app.appId isEqualToString:self.appId])
        {
            block(YES,error);
        }
        else
        {
            block(NO,error);
        }
    }];
}

@end
