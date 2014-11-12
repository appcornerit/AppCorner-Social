//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <UIKit/UIKit.h>

@protocol PAPEditAppHeaderViewDelegate;

@interface PAPEditAppHeaderView : UIView

/// The app associated with this view
@property (nonatomic,strong) PAApp *app;

/*! @name Delegate */
@property (nonatomic,weak) id <PAPEditAppHeaderViewDelegate> delegate;

@end

/*!
 The protocol defines methods a delegate of a PAPAppFooterView should implement.
 All methods of the protocol are optional.
 */
@protocol PAPEditAppHeaderViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the icon app button is tapped
 @param app the PAApp associated with this button
 */
- (void)editAppHeaderView:(PAPEditAppHeaderView *)editAppHeaderView didTapAppButton:(UIButton *)button app:(PAApp *)app;

@end