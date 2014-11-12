//
//  PFGeoPoint.m
//  ParseKit
//
//  Created by Denis Berton on 30/09/12.
//
//

#import <Foundation/Foundation.h>
#import "PFGeoPoint.h"


@implementation PFGeoPoint  

+ (PFGeoPoint *)geoPointWithLatitude:(double)latitude longitude:(double)longitude{
    PFGeoPoint* point = [[self alloc] init];
	point.latitude = latitude;
	point.longitude = longitude;
	return point;
}

- (id)copyWithZone:(NSZone *)zone{
	return [PFGeoPoint geoPointWithLatitude:self.latitude longitude:self.longitude];
}

@end
