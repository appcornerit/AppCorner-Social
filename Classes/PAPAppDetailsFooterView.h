//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

@interface PAPAppDetailsFooterView : UIView

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic) BOOL hideDropShadow;

+ (CGRect)rectForView;

@end
