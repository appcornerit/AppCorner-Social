//
//  PFObject.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//


#import "PFObject.h"
#import "PAPCache.h"

@interface PFObject ()

@end

@implementation PFObject

@synthesize hasBeenFetched;

- (NSDate *)createdAt {
    return self.dkEntity.createdAt;
}
- (NSString *)objectId {
    return self.dkEntity.entityId;
}
- (NSString *)className {
    return self.dkEntity.entityName;
}

- (instancetype)initWithName:(NSString *)entityName {
    self = [super init];
    if (self) {
        self.dkEntity = [DKEntity entityWithName:entityName];
        self.dkEntity.cachePolicy = DKCachePolicyIgnoreCache;
        self.dkEntity.maxCacheAge = 86400 * 30; //30 days
		self.hasBeenFetched = NO;
    }
    return self;
}

+ (PFObject *)objectWithClassName:(NSString *)className{
    return [[self alloc] initWithName:className];
}

+ (PFObject *)objectWithoutDataWithClassName:(NSString *)className
                                    objectId:(NSString *)objectId{
    PFObject *obj = [[self alloc] initWithName:className];
    //Change entityId property in DKEntity.h from readonly to strong
    [obj.dkEntity setObject:objectId forKey:kDKEntityIDField];
    return obj;
}

- (id)objectForKey:(NSString *)key{

    
//   if([PFApplicationKey isPFFileKey:key]){
//      NSString *fileName= [self.dkEntity objectForKey:key];
//       if(fileName){ //&& [DKFile fileExists:fileName]){
//           PFFile *file = [PFFile fileWithData:nil];
//           file.url = fileName;
//           file.dkFile = [DKFile fileWithName:fileName];
//           file.dkFile.cachePolicy = DKCachePolicyUseCacheElseLoad;
//           file.dkFile.maxCacheAge = 86400 * 30; //30 days
//           return file;
//       }
//       return nil;
//   }
   if([PFApplicationKey isPFUserKey:key]){
	   NSString* userId = [self.dkEntity objectForKey:key];
	   
	   PFUser* current = [PFUser currentUser];
	   if(current && [current.objectId isEqualToString: userId])
		   return current;
       PFUser* cachedUser = (PFUser*)[[PAPCache sharedCache] pfObjectForClassName:kUserClassName forObjectId:userId];
       if(cachedUser)
       {
           return cachedUser;
       }
       
	   
       PFQuery *query = [PFUser query];
       [query.dkQuery whereEntityIdMatches:userId];
       NSError *error = nil;
       NSArray *array = [query findObjects:&error];
       if([array count] > 0){
           PFUser* user = (PFUser*)array[0];
           [[PAPCache sharedCache] setPFObject:user];
           return user;
       }
       else
       {
           NSLog(@"User %@ not loaded",userId);
           return nil; //Data not loaded
       }
   }
//   else if([PFApplicationKey isPFGeoPointKey:key]){
//	   NSArray* arr = [self.dkEntity objectForKey:key];
//	   PFGeoPoint* point = [PFAdapterUtils convertObjToPF:arr];
//        [[PAPCache sharedCache] setPFObject:point];
//	   return point;
//   }
   else if([PFApplicationKey isPAAppObjectKey:key]){
       NSString* objId = [self.dkEntity objectForKey:key];
       if(!objId)
           return nil;
       PAApp* cachedApp = (PAApp*)[[PAPCache sharedCache] pfObjectForClassName:kAppClassName forObjectId:objId];
       if(cachedApp)
       {
           return cachedApp;
       }
       
       
       PFQuery *query = [PFQuery queryWithClassName:[PFApplicationKey getPAAppClassForKey:key]];
       [query.dkQuery whereEntityIdMatches:objId];
       NSError *error = nil;
       NSArray *array = [query findObjects:&error];
       if([array count] > 0){
           PFObject* obj = (PFObject*)array[0];
           PAApp* app = (PAApp*)[PAApp objectWithClassName:kPAPAppClassKey];
           app.dkEntity = obj.dkEntity;
           [[PAPCache sharedCache] setPFObject:app];
           return app;
       }
       else
       {
           NSLog(@"App %@ not loaded",objId);
           return nil; //Data not loaded
       }
   }
   else if([PFApplicationKey isBOOLKey:key]){
       NSString* boolValue= [self.dkEntity objectForKey:key];
       if (boolValue && [@([boolValue integerValue]) boolValue])
           return @([boolValue integerValue]); //return number as bool
       else
           return nil; //nil is always false
   }
   return [self.dkEntity objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key{
    [self.dkEntity setObject:[PFAdapterUtils convertObjToDK:object] forKey:key];
	self.hasBeenFetched = NO;
}

- (void)removeObjectForKey:(NSString *)key
{
    [self.dkEntity setObject:@"" forKey:key];
	self.hasBeenFetched = NO;
}

- (void)addUniqueObject:(id)object forKey:(NSString *)key{
    [self.dkEntity setObject: @[[PFAdapterUtils convertObjToDK:object]] forKey:key];
	self.hasBeenFetched = NO;
}

- (void)removeObject:(id)object forKey:(NSString *)key{
    [self.dkEntity setObject:@"" forKey:key];
	self.hasBeenFetched = NO;
}

- (void)saveInBackground{
    [self.dkEntity saveInBackground];
	self.hasBeenFetched = YES;
}

- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block{
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        BOOL ret = [self.dkEntity save:&error];
		self.hasBeenFetched = ret;
        if (block != NULL) {
            dispatch_async(q, ^{
                block(ret, error);
            });
        }
    });
}

- (void)saveEventually{
    [self.dkEntity saveInBackground];
	self.hasBeenFetched = YES;
}
- (void)saveEventually:(PFBooleanResultBlock)callback{
    [self saveInBackgroundWithBlock:callback];
}

- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        [self.dkEntity refresh:&error];
		self.hasBeenFetched = YES;
        if (selector != NULL) {
            dispatch_async(q, ^{
                if([target respondsToSelector:selector]){
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:self withObject:error];
                    #pragma clang diagnostic pop
                }
            });
        }
    });
}

- (void)fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block{
    block = [block copy];
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
		if(!self.hasBeenFetched){
			[self.dkEntity refresh:&error];
			self.hasBeenFetched = YES;
		}
        if (block != NULL) {
            dispatch_async(q, ^{
                block(self, error);
            });
        }
    });
}

- (BOOL)delete{
    return [self.dkEntity delete];
}

- (void)deleteEventually{
    [self.dkEntity deleteInBackground];
}

- (void)setValue:(id)value forKey:(NSString *)key{
  [self.dkEntity setObject:[PFAdapterUtils convertObjToDK:value] forKey:key];
  self.hasBeenFetched = NO;
}

- (PFObject *)fetchIfNeeded{
	if(!self.hasBeenFetched){
        NSError *error = nil;
        [self.dkEntity refresh:&error];
		self.hasBeenFetched = YES;
	}
    return self;
}


@end
