//
//  PFLogInViewController.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLIRViewController.h"

@protocol PFLogInViewControllerDelegate;

@interface PFLogInViewController : GLIRViewController <UITextFieldDelegate>

    @property (nonatomic) PFLogInFields fields;
    @property (nonatomic, strong) PFLogInView *logInView;
    @property (nonatomic, assign) id<PFLogInViewControllerDelegate> delegate;
    @property (nonatomic, strong) NSArray *facebookPermissions;

    @property (nonatomic, strong) UILabel *textLabel;
    @property (nonatomic, strong) UILabel *siteLabel;

@end


@protocol PFLogInViewControllerDelegate <FBRequestDelegate>
    @optional
    - (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;
    - (void)request:(PF_FBRequest *)request didLoad:(id)result;
    - (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error;
@end
