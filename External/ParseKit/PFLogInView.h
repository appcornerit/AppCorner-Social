//
//  PFLogInView.h
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFLogInView : UIView

    @property (nonatomic, strong) UIView *logo;

    /// The username text field. It is nil if the element is not enabled.
    @property (nonatomic, readonly, retain) UITextField *usernameField;
@end
