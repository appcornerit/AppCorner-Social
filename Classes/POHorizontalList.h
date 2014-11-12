//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PAAppIconInfoView.h"
#import "AMBlurView.h"

#define DISTANCE_BETWEEN_ITEMS  15.0
#define LEFT_PADDING            15.0
#define ITEM_WIDTH              72.0

@protocol POHorizontalListDelegate <NSObject>
- (void) didSelectApp:(PAApp *)app;
@end

@interface POHorizontalList : UIView <UIScrollViewDelegate> {
    CGFloat scale;
    CGRect openFrame;
    CGRect closeFrame;
}

@property (nonatomic, strong) NSMutableArray *pAAppItems;
@property (nonatomic, assign) id<POHorizontalListDelegate> delegate;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic, assign) BOOL excludeCurrentUserApps;
@property (weak, nonatomic) IBOutlet AMBlurView *blurView;


-(void)setupViewWithParentView:(UIView*)parentView;
-(void)togglePanel:(id)sender withCompletionBlock:(void (^)(BOOL isOpen))completion;


- (IBAction)handleSwipeUpGesture:(id)sender;
- (IBAction)togglePanel:(id)sender;



@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noAppsLabel;
@end
