//
//  PFAdapterUtils.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//
//

#import "PFAdapterUtils.h"

@implementation PFAdapterUtils

+(id)convertObjToDK:(id) obj{
    if([obj isKindOfClass:[PFFile class]])
        return nil; //((PFFile*)obj).dkFile.name;  //NO FILE MUST BE SAVED ON BACKEND
    if([obj isKindOfClass:[PFUser class]] || [obj isKindOfClass:[PFObject class]])
        return [((PFObject*)obj).dkEntity entityId];
    if([obj isKindOfClass:[PFGeoPoint class]]){
		return @[@(((PFGeoPoint*)obj).longitude),
                          				  @(((PFGeoPoint*)obj).latitude)];		
	}
    return obj;
}

+(id)convertObjToPF:(id) obj{
	if([obj isKindOfClass:[DKEntity class]]){
		DKEntity* entity = (DKEntity*)obj;
		PFObject * pfObj = nil;
		if([entity.entityName isEqualToString: kUserClassName])
			pfObj = [PFUser objectWithClassName:entity.entityName];
		else if([entity.entityName isEqualToString: kAppClassName])
            pfObj = [PAApp objectWithClassName:entity.entityName];
		else
			pfObj = [PFObject objectWithClassName:entity.entityName];
		pfObj.dkEntity = entity;
		pfObj.hasBeenFetched = YES;
		return pfObj;
	}
	else if([obj isKindOfClass:[NSArray class]]){
	    NSArray* arr = (NSArray*)obj;
	    return [PFGeoPoint geoPointWithLatitude:[(NSNumber*)arr[1] doubleValue] longitude:[(NSNumber*)arr[0] doubleValue]];
	}
    return obj;
}

+(NSArray*)convertArrayToDK:(NSArray*) array{
    NSMutableArray* newArray = [[NSMutableArray alloc] init];
    for (id el in array) {
		[newArray addObject: [self convertObjToDK:el]];
    }
    return newArray;
}

+(NSArray*)convertArrayToPF:(NSArray*) array{
    NSMutableArray* newArray = [[NSMutableArray alloc] init];
    for (id el in array) {
		[newArray addObject: [self convertObjToPF:el]];
    }
    return newArray;
}

@end
