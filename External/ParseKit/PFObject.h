//
//  PFObject.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface PFObject : NSObject 

@property (nonatomic, strong) DKEntity * dkEntity;
@property (nonatomic, strong) NSString *objectId;
@property (readonly) NSDate *createdAt;
@property (readonly) NSString *className;
@property (nonatomic, strong) PFACL *ACL;

@property (nonatomic,assign) BOOL hasBeenFetched;

+ (PFObject *)objectWithClassName:(NSString *)className;
+ (PFObject *)objectWithoutDataWithClassName:(NSString *)className
                                    objectId:(NSString *)objectId;
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
//- (void)removeObjectForKey:(NSString *)key;
- (void)addUniqueObject:(id)object forKey:(NSString *)key;
- (void)removeObject:(id)object forKey:(NSString *)key;
- (void)saveInBackground;
- (void)saveInBackgroundWithBlock:(PFBooleanResultBlock)block;
- (void)saveEventually;
- (void)saveEventually:(PFBooleanResultBlock)callback;
- (void)refreshInBackgroundWithTarget:(id)target selector:(SEL)selector;
- (void)fetchIfNeededInBackgroundWithBlock:(PFObjectResultBlock)block;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL delete;
- (void)deleteEventually;
- (void)setValue:(id)value forKey:(NSString *)key;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) PFObject *fetchIfNeeded;

/*!
 Unsets a key on the object.
 @param key The key.
 */
- (void)removeObjectForKey:(NSString *)key;

@end
