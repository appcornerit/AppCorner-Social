//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPBaseTextCell.h"
@protocol PAPActivityCellDelegate;

@interface PAPActivityCell : PAPBaseTextCell

/*!Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*!Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

- (void)setIsPriceDrop:(BOOL)isPriceDrop;

@end


/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol PAPActivityCellDelegate <PAPBaseTextCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(PAPActivityCell *)cellView didTapActivityButton:(PFObject *)activity;

@end