//
//  PFGeoPoint.h
//  ParseKit
//
//  Created by Denis Berton on 30/09/12.
//
//

#import <Foundation/Foundation.h>


@interface PFGeoPoint : NSObject<NSCopying>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

+ (PFGeoPoint *)geoPointWithLatitude:(double)latitude longitude:(double)longitude;

@end
