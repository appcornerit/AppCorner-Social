//
//  PFAdapterUtils.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//
//

#import <Foundation/Foundation.h>


@interface PFAdapterUtils : NSObject

    +(id)convertObjToPF:(id) obj;
    +(id)convertObjToDK:(id) obj;
    +(NSArray*)convertArrayToPF:(NSArray*) array;
    +(NSArray*)convertArrayToDK:(NSArray*) array;

@end
