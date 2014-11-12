//
//  PFACL.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFACL.h"

@implementation PFACL

+ (PFACL *)ACL{return [[self alloc] init];}
+ (PFACL *)ACLWithUser:(PFUser *)user{return [[self alloc] init];}
- (void)setPublicReadAccess:(BOOL)allowed{}
+ (void)setDefaultACL:(PFACL *)acl withAccessForCurrentUser:(BOOL)currentUserAccess{}
- (id)copyWithZone:(NSZone *)zone{return [PFACL ACL];}
- (void)setWriteAccess:(BOOL)allowed forUser:(PFUser *)user{}
- (void)setPublicWriteAccess:(BOOL)allowed{}

@end
