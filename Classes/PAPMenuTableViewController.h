//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "AMBlurView.h"

typedef NS_ENUM(NSInteger, tPAPMenuPickerType) {
    kPAPMenuPickerTypeRanking = 0,
    kPAPMenuPickerTypeGenre,
    kPAPMenuPickerTypeCountry
} ;

typedef NS_ENUM(NSInteger, kPAPMenuOpenDirection) {
    kPAPMenuOpenDirectionRight= 0,
    kPAPMenuOpenDirectionLeft,
    kPAPMenuOpenDirectionDown
} ;

static CGFloat menuItemHeight = 44.0f;

@protocol PAPMenuTableViewDelegate <NSObject>

-(void)valueSelectedAtIndex:(NSInteger)index forType:(tPAPMenuPickerType) type;

@end

@interface PAPMenuTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    CGRect closeFrame;
}

@property (weak, nonatomic) IBOutlet AMBlurView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@property (assign, nonatomic) CGRect backgroundAreaDismissRect;
@property (assign, nonatomic) CGFloat closeOffset;
@property (assign, nonatomic) tPAPMenuPickerType type;
@property (assign, nonatomic) kPAPMenuOpenDirection openDirection;
@property (strong, nonatomic) NSArray* items;
@property (strong, nonatomic) NSArray* values;
@property (assign, nonatomic) CGRect openFrame;
@property (weak, nonatomic) id<PAPMenuTableViewDelegate> delegate;
@property (readonly) BOOL isOpen;

-(void) togglePanel;
-(void) togglePanelWithCompletionBlock:(void (^)(BOOL isOpen))completion;

@end
