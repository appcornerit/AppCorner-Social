//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//
#import <Foundation/Foundation.h>

@interface PAPCache : NSObject

+ (PAPCache*)sharedCache;

- (void)clear;
- (void)setAttributesForApp:(PAApp *)app likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
- (NSDictionary *)attributesForApp:(PAApp *)app;
- (NSNumber *)likeCountForApp:(PAApp *)app;
- (NSNumber *)commentCountForApp:(PAApp *)app;
- (NSArray *)likersForApp:(PAApp *)app;
- (NSArray *)commentersForApp:(PAApp *)app;
- (void)setAppIsLikedByCurrentUser:(PAApp *)app liked:(BOOL)liked;
- (BOOL)isAppLikedByCurrentUser:(PAApp *)app;
- (void)incrementLikerCountForApp:(PAApp *)app;
- (void)decrementLikerCountForApp:(PAApp *)app;
- (void)incrementCommentCountForApp:(PAApp *)app;
- (void)decrementCommentCountForApp:(PAApp *)app;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)appCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (void)setAppCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;

@property (NS_NONATOMIC_IOSONLY, copy) NSArray *facebookFriends;

- (void)setPFObject:(PFObject *)object;
- (PFObject *)pfObjectForClassName:(NSString *)className forObjectId:(NSString*)objectId;
@end
