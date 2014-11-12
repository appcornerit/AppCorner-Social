//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPCache.h"

@interface PAPCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forApp:(PAApp *)app;
@end

@implementation PAPCache
@synthesize cache;

#pragma mark - Initialization

+ (PAPCache*)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PAPCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForApp:(PAApp *)app likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = @{kPAPAppAttributesIsLikedByCurrentUserKey: @(likedByCurrentUser),
                                      kPAPAppAttributesLikeCountKey: [NSNumber numberWithInt:[likers count]],
                                      kPAPAppAttributesLikersKey: likers,
                                      kPAPAppAttributesCommentCountKey: [NSNumber numberWithInt:[commenters count]],
                                      kPAPAppAttributesCommentersKey: commenters};
    [self setAttributes:attributes forApp:app];
}

- (NSDictionary *)attributesForApp:(PAApp *)app {
    NSString *key = [self keyForApp:app];
    return [self.cache objectForKey:key];
}

- (NSNumber *)likeCountForApp:(PAApp *)app {
    NSDictionary *attributes = [self attributesForApp:app];
    if (attributes) {
        return attributes[kPAPAppAttributesLikeCountKey];
    }

    return @0;
}

- (NSNumber *)commentCountForApp:(PAApp *)app {
    NSDictionary *attributes = [self attributesForApp:app];
    if (attributes) {
        return attributes[kPAPAppAttributesCommentCountKey];
    }
    
    return @0;
}

- (NSArray *)likersForApp:(PAApp *)app {
    NSDictionary *attributes = [self attributesForApp:app];
    if (attributes) {
        return attributes[kPAPAppAttributesLikersKey];
    }
    
    return @[];
}

- (NSArray *)commentersForApp:(PAApp *)app {
    NSDictionary *attributes = [self attributesForApp:app];
    if (attributes) {
        return attributes[kPAPAppAttributesCommentersKey];
    }
    
    return @[];
}

- (void)setAppIsLikedByCurrentUser:(PAApp *)app liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForApp:app]];
    attributes[kPAPAppAttributesIsLikedByCurrentUserKey] = @(liked);
    [self setAttributes:attributes forApp:app];
}

- (BOOL)isAppLikedByCurrentUser:(PAApp *)app {
    NSDictionary *attributes = [self attributesForApp:app];
    if (attributes) {
        return [attributes[kPAPAppAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementLikerCountForApp:(PAApp *)app {
    NSNumber *likerCount = @([[self likeCountForApp:app] intValue] + 1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForApp:app]];
    attributes[kPAPAppAttributesLikeCountKey] = likerCount;
    [self setAttributes:attributes forApp:app];
}

- (void)decrementLikerCountForApp:(PAApp *)app {
    NSNumber *likerCount = @([[self likeCountForApp:app] intValue] - 1);
    if ([likerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForApp:app]];
    attributes[kPAPAppAttributesLikeCountKey] = likerCount;
    [self setAttributes:attributes forApp:app];
}

- (void)incrementCommentCountForApp:(PAApp *)app {
    NSNumber *commentCount = @([[self commentCountForApp:app] intValue] + 1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForApp:app]];
    attributes[kPAPAppAttributesCommentCountKey] = commentCount;
    [self setAttributes:attributes forApp:app];
}

- (void)decrementCommentCountForApp:(PAApp *)app {
    NSNumber *commentCount = @([[self commentCountForApp:app] intValue] - 1);
    if ([commentCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForApp:app]];
    attributes[kPAPAppAttributesCommentCountKey] = commentCount;
    [self setAttributes:attributes forApp:app];
}

- (void)setAttributesForUser:(PFUser *)user appCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = @{kPAPUserAttributesAppCountKey: count,
                                kPAPUserAttributesIsFollowedByCurrentUserKey: @(following)};
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)appCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *appCount = attributes[kPAPUserAttributesAppCountKey];
        if (appCount) {
            return appCount;
        }
    }
    
    return @0;
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = attributes[kPAPUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }

    return NO;
}

- (void)setAppCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    attributes[kPAPUserAttributesAppCountKey] = count;
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    attributes[kPAPUserAttributesIsFollowedByCurrentUserKey] = @(following);
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kPAPUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }

    return friends;
}

#pragma mark - PFObject

//Metodi aggiunti
- (void)setPFObject:(PFObject *)object {
    NSString *key = [NSString stringWithFormat:@"obj_%@_%@",object.className,object.objectId];
    [self.cache setObject:object forKey:key];
}

- (PFObject *)pfObjectForClassName:(NSString *)className forObjectId:(NSString*)objectId {
    NSString *key = [NSString stringWithFormat:@"obj_%@_%@",className,objectId];
    return [self.cache objectForKey:key];
}


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forApp:(PAApp *)app {
    NSString *key = [self keyForApp:app];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];    
}

- (NSString *)keyForApp:(PAApp *)app {
    return [NSString stringWithFormat:@"app_%@", [app objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
