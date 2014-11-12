//
//  PFQuery.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFQuery.h"

@interface PFQuery ()
      @property (strong, nonatomic) NSArray * orSubqueries;
@end

@implementation PFQuery

@synthesize dkQuery;

-(void) setLimit:(NSInteger)limit{
    self.dkQuery.limit = limit;
}
-(NSInteger) getLimit{
    return self.dkQuery.limit;
}
-(void) setCachePolicy:(PFCachePolicy)cachePolicy{
    DKCachePolicy policy = DKCachePolicyIgnoreCache;
    switch (cachePolicy)
    {
        case kPFCachePolicyIgnoreCache:
            policy = DKCachePolicyIgnoreCache;
            break;
        case kPFCachePolicyCacheOnly:
            policy = DKCachePolicyUseCacheElseLoad;
            break;
        case kPFCachePolicyNetworkOnly:
            policy = DKCachePolicyIgnoreCache;
            break;
        case kPFCachePolicyCacheElseNetwork:
            policy = DKCachePolicyUseCacheElseLoad;
            break;
        case kPFCachePolicyNetworkElseCache:
            policy = DKCachePolicyIgnoreCache;
            break;
        case kPFCachePolicyCacheThenNetwork:
            policy = DKCachePolicyUseCacheElseLoad;
            break;
    }    
    self.dkQuery.cachePolicy = policy;
}
-(PFCachePolicy) getCachePolicy{
    DKCachePolicy policy = self.dkQuery.cachePolicy;
    PFCachePolicy mappedPolicy = kPFCachePolicyIgnoreCache;
    switch (policy)
    {
        case DKCachePolicyIgnoreCache:
            mappedPolicy = kPFCachePolicyIgnoreCache;
            break;
        case DKCachePolicyUseCacheElseLoad:
            mappedPolicy = kPFCachePolicyCacheElseNetwork;
            break;
//        case DKCachePolicyUseCacheIfOffline:
//            mappedPolicy = kPFCachePolicyCacheOnly;
//            break;
    }
    return mappedPolicy;
}

- (instancetype)initWithName:(NSString *)entityName {
    self = [super init];
    if (self) {
        self.dkQuery = [DKQuery queryWithEntityName:entityName];
        self.dkQuery.cachePolicy = DKCachePolicyIgnoreCache;
        self.dkQuery.maxCacheAge = 86400 * 30; //30 days        
    }
    return self;
}

+ (PFQuery *)queryWithClassName:(NSString *)className{
    return [[self alloc] initWithName:className];
}

- (void)includeKey:(NSString *)key{
    //[self.dkQuery includeKeys: [NSArray arrayWithObject:key]];
}

- (void)whereKeyExists:(NSString *)key{
    [self.dkQuery whereKeyExists:key];
}

- (void)whereKey:(NSString *)key equalTo:(id)object{
    [self.dkQuery whereKey:key equalTo:[PFAdapterUtils convertObjToDK: object]];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object{
    [self.dkQuery whereKey:key notEqualTo:[PFAdapterUtils convertObjToDK: object]];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)array{
    [self.dkQuery whereKey:key containedIn: [PFAdapterUtils convertArrayToDK:array]];
}

+ (PFQuery *)orQueryWithSubqueries:(NSArray *)queries{
    PFQuery * q = [[self alloc] initWithName:@""];
    q.orSubqueries = queries;
    return q;
}

NSInteger comparator(id id1, id id2, void *context)
{
    DKEntity* entity1 = (DKEntity*)id1;
    DKEntity* entity2 = (DKEntity*)id2;
    return ([entity2.createdAt compare:entity1.createdAt]);
}

- (NSArray *)findAllWithOrSubqueries:(NSError **)error {
    //client-side orSubqueries
    
    if(!self.orSkip){
        self.orSkip = [[NSMutableArray alloc] initWithCapacity:self.orSubqueries.count];
        for (int x = 0; x < self.orSubqueries.count; x++){
            [self.orSkip addObject:@0];
        }
    }
    
    NSMutableArray* tmpResArray = [[NSMutableArray alloc] init];
    NSMutableArray* qArray = [[NSMutableArray alloc] initWithCapacity:self.orSubqueries.count];
    for (int i = 0; i < self.orSubqueries.count; i++){
        DKQuery* q = ((PFQuery*)self.orSubqueries[i]).dkQuery;
        q.limit = self.dkQuery.limit;
        if(self.dkQuery.skip == 0)
            self.orSkip[i] = @0;
        q.skip = [((NSNumber*)self.orSkip[i]) integerValue];
        
        [q orderDescendingByCreationDate]; //order forced
        NSArray* resArray = [q findAll:error];
        if(!resArray) resArray = [[NSMutableArray alloc] init];
        //union client-side
        [tmpResArray addObjectsFromArray:resArray];
        //need for calc skip
        [qArray addObject:resArray];
    }
    
    //order forced with sortedArrayUsingFunction like [query orderDescendingByCreationDate];
    NSArray* orderedArray = [tmpResArray sortedArrayUsingFunction:comparator context:nil];
    
    //calc result size
    NSInteger limit = self.dkQuery.limit;
    if(limit == 0) //skip ignored
        return orderedArray;
    if(orderedArray.count < limit)
        limit = orderedArray.count;
    
    //truncate array and set skip for next page
    NSMutableArray* resArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < limit; i++)
    {
        id obj = orderedArray[i];
        [resArray addObject:obj];
        for (int x = 0; x < self.orSubqueries.count; x++){
            NSArray* subQueryResArr = qArray[x];
            if([subQueryResArr containsObject:obj])
                self.orSkip[x] = [NSNumber numberWithInt: [((NSNumber*)self.orSkip[x]) integerValue]+1];
        }
    }
    
    return resArray;
}

- (NSArray *)findAll:(NSError **)error {
    if(self.orSubqueries)
        return [self findAllWithOrSubqueries:error];
    return [self.dkQuery findAll:error];
}

- (void)whereKey:(NSString *)key matchesKey:(NSString *)otherKey inQuery:(PFQuery *)query{
    NSMutableArray* newArray = [[NSMutableArray alloc] init];
    NSError *error = nil;
    NSArray *ar= [query.dkQuery findAll:&error];
    for (id el in ar) {
        DKEntity* e = nil;
        if(![el isKindOfClass:[DKEntity class]])
          e = ((PFObject*)el).dkEntity;
        else
          e = (DKEntity*)el;
        [newArray addObject: [e objectForKey:otherKey]];
    }
    [self.dkQuery whereKey:key containedIn:newArray];
}

- (void)orderByAscending:(NSString *)key{
    if([key isEqualToString:kDKEntityCreatedAtField])
        [self.dkQuery orderAscendingByCreationDate];
    else
        [self.dkQuery orderAscendingByKey:key];
}

- (void)orderByDescending:(NSString *)key{
    if([key isEqualToString:kDKEntityCreatedAtField])
        [self.dkQuery orderDescendingByCreationDate];
    else
        [self.dkQuery orderDescendingByKey:key];
}

- (void)getObjectInBackgroundWithId:(NSString *)objectId
                              block:(PFObjectResultBlock)block{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSArray *array = [self findObjects:&error];
        if([array count] > 0){
            PFObject *object = array[0];
            if (block != NULL) {
                dispatch_async(q, ^{
                    block(object, error);
                });
            }
        }
    });
}

- (NSArray *)findObjects:(NSError **)error{
    NSArray* array = [self findAll:error];
    return [PFAdapterUtils convertArrayToPF:array];
}

- (void)findObjectsInBackgroundWithBlock:(PFArrayResultBlock)block{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
		NSArray* array = [self findAll:&error];
		NSArray* newArray = [PFAdapterUtils convertArrayToPF:array];
        if (block != NULL) {
            dispatch_async(q, ^{
                block(newArray, error);
            });
        }
    });
}

- (void)findObjectsInBackgroundWithTarget:(id)target selector:(SEL)selector{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSArray* array = [self findAll:&error];
		NSArray* newArray = [PFAdapterUtils convertArrayToPF:array];
        if (selector != NULL) {
            dispatch_async(q, ^{
                if([target respondsToSelector:selector]){
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [target performSelector:selector withObject:newArray withObject:error];
                    #pragma clang diagnostic pop
                }
            });
        }
    });
}

- (void)countObjectsInBackgroundWithBlock:(PFIntegerResultBlock)block{
    dispatch_queue_t q = dispatch_get_current_queue();
    dispatch_async([DKManager queue], ^{
        NSError *error = nil;
        NSInteger count = [self.dkQuery countAll:&error];
        if (block != NULL) {
            dispatch_async(q, ^{
                block(count, error);
            });
        }
    });        
}

+ (void)clearAllCachedResults
{
    [DKManager clearAllCachedResults];
}

//unused methods
//- (void)whereKey:(NSString *)key nearGeoPoint:(PFGeoPoint *)geopoint withinKilometers:(double)maxDistance{
//	double earthRadius = 6378; // km  
//	double radians = maxDistance/earthRadius; //to radians
//    [self.dkQuery whereKey:key nearPoint:[PFAdapterUtils convertObjToDK: geopoint] withinDistance:[NSNumber numberWithDouble:radians]];
//}
//
//- (void)whereKey:(NSString *)key nearGeoPoint:(PFGeoPoint *)geopoint withinMiles:(double)maxDistance{
//	double earthRadius = 3959; // miles
//	double radians = maxDistance/earthRadius; //to radians
//    [self.dkQuery whereKey:key nearPoint:[PFAdapterUtils convertObjToDK: geopoint] withinDistance:[NSNumber numberWithDouble:radians]];
//}
//
//- (void)whereKey:(NSString *)key nearGeoPoint:(PFGeoPoint *)geopoint withinRadians:(double)maxDistance{
//    [self.dkQuery whereKey:key nearPoint:[PFAdapterUtils convertObjToDK: geopoint] withinDistance:[NSNumber numberWithDouble:maxDistance]];
//}
@end
