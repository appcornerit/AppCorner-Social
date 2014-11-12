//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <Foundation/Foundation.h>

@protocol PAPAppFooterViewDelegate;

@interface PAPAppFooterView : UIView

/// The app associated with this view
@property (nonatomic,strong) PAApp *app;

/*! @name Delegate */
@property (nonatomic,weak) id <PAPAppFooterViewDelegate> delegate;

@end

/*!
 The protocol defines methods a delegate of a PAPAppFooterView should implement.
 All methods of the protocol are optional.
 */
@protocol PAPAppFooterViewDelegate <NSObject>
@optional

/*!
 Sent to the delegate when the icon app button is tapped
 @param app the PAApp associated with this button
 */
- (void)appFooterView:(PAPAppFooterView *)appFooterView didTapAppButton:(UIButton *)button app:(PAApp *)app;

- (void)appFooterView:(PAPAppFooterView *)appFooterView didTapShareButton:(UIButton *)button app:(PAApp *)app;

@end