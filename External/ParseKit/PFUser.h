//
//  PFUser.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PFUser : PFObject

@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *username;

    + (PFUser *)currentUser;
    + (void)logOut;
    + (PFQuery *)query;
    + (void)setCurrentUser:(PFUser *)user;
	+ (PFUser *)user;

@end
