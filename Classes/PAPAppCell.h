//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#include "PAAppPreviewScrollView.h"

@class PFImageView;
@interface PAPAppCell : PFTableViewCell
{
    UIView* headerPlaceholder;
    UIView* footerPlaceholder;
}

@property (nonatomic, strong) UIButton *appButton;
@property (nonatomic, strong) PAApp* app;
@property (nonatomic, strong) PAAppPreviewScrollView* appImageScrollView;

@property (nonatomic, strong) UIView* headView;
@property (nonatomic, strong) UIView* footView;

@end
