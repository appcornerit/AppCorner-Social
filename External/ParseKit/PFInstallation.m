//
//  PFInstallation.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFInstallation.h"

@implementation PFInstallation

static PFInstallation* currentInstallation = nil;

+(PFInstallation *)currentInstallation{
    if(!currentInstallation){
        currentInstallation = [[self alloc]init];
        currentInstallation.dkEntity = [DKChannel currentChannel];
        if(!currentInstallation.dkEntity)
        {
            currentInstallation = nil;
            return currentInstallation;
        }
    }
    [((DKChannel*)currentInstallation.dkEntity) updateChannel];    
    return currentInstallation;
}

@end
