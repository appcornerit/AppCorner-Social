//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PFUser.h"

@interface PAApp : PFObject

@property (nonatomic, strong) NSString* appId;
@property (nonatomic, readonly) BOOL inCountryAppStore;
@property (nonatomic, readonly) NSString *inCountryFormattedPrice;
@property (nonatomic, readonly) NSDecimalNumber* inCountryPrice;

@property (nonatomic, strong) NSString *bundleId;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *formattedPrice;
@property (nonatomic, strong) NSString *iconURL;
@property (nonatomic, strong) NSString *iconThumbnailURL;
@property (nonatomic) BOOL iconIsPrerendered;
@property (nonatomic) NSInteger userRatingCount;
@property (nonatomic) CGFloat userRating;
@property (nonatomic) NSInteger userRatingCountAllVersions;
@property (nonatomic) CGFloat userRatingAllVersions;
@property (nonatomic) BOOL isUniversal;

@property (nonatomic, strong) NSString* artistName;
@property (nonatomic, strong) NSString* artworkURL60;
@property (nonatomic, strong) NSString* artworkURL100;
@property (nonatomic, strong) NSString* storeURL;
@property (nonatomic, strong) NSString* kind;
@property (nonatomic, strong) NSDecimalNumber* price;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic, strong) NSArray* screenshotUrls;


@property (nonatomic) BOOL loaded;

-(void) addScreenshotUrl:(NSString*)url;

+(PAApp *)createNewAppFromExistingApp:(PAApp *)app;

- (void)existsInUserCountryAppStore:(PFBooleanResultBlock)block;
- (void)existsInCountryAppStore:(NSString*)country block:(PFBooleanResultBlock)block;

@end
