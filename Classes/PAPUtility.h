//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

@interface PAPUtility : NSObject

+ (void)likeAppInBackground:(PAApp*)app block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unlikeAppInBackground:(PAApp*)app block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)unfollowUserEventually:(PFUser *)user;
+ (void)unfollowUsersEventually:(NSArray *)users;

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;  
+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController;

+ (PFQuery *)queryForActivitiesOnApp:(PAApp *)app cachePolicy:(PFCachePolicy)cachePolicy;

+ (NSString*) priceDropToString:(NSString *)price withActivityString:(NSString*)activityString;
@end
