//
//  PFACL.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFACL : NSObject <NSCopying>

    + (PFACL *)ACL;
    + (PFACL *)ACLWithUser:(PFUser *)user;
    - (void)setPublicReadAccess:(BOOL)allowed;
    + (void)setDefaultACL:(PFACL *)acl withAccessForCurrentUser:(BOOL)currentUserAccess;
    - (void)setWriteAccess:(BOOL)allowed forUser:(PFUser *)user;
	- (void)setPublicWriteAccess:(BOOL)allowed;
@end
