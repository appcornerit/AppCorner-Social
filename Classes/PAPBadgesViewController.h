//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <UIKit/UIKit.h>

@protocol PAPBadgesViewControllerDelegate <NSObject>

-(void) badgesUpdated;

@end

typedef NS_OPTIONS(NSUInteger, PAPBagde) {
    PAPBagdeNone          = 1 <<  0,
    PAPBagdePriceDrop     = 1 <<  1,
    PAPBagdePlayTogether  = 1 <<  2,
    PAPBagdeQuestion      = 1 <<  4,
    PAPBagdeWant          = 1 <<  6
};

@interface PAPBadgesViewController : UIViewController

@property (readonly) PAApp* app;
@property (readonly) PAPBagde selectedBadges;
@property (assign,nonatomic) BOOL editMode;
@property (assign,nonatomic) id<PAPBadgesViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *priceDropBadgeButton;
@property (weak, nonatomic) IBOutlet UIButton *playTogetherBadgeButton;
@property (weak, nonatomic) IBOutlet UIButton *questionBadgeButton;
@property (weak, nonatomic) IBOutlet UIButton *wantBadgeButton;
@property (weak, nonatomic) IBOutlet UILabel *labelIOwn;
@property (weak, nonatomic) IBOutlet UILabel *labelIWant;
@property (weak, nonatomic) IBOutlet UIView *ownBadgesViewContainer;
@property (weak, nonatomic) IBOutlet UIView *wantBadgesViewContainer;
@property (weak, nonatomic) IBOutlet UIView *labelsViewContainer;
@property (weak, nonatomic) IBOutlet UIView *labelsViewBackgorund;
@property (weak, nonatomic) IBOutlet UIView *badgesViewBackground;

- (IBAction)priceDropAction:(id)sender;
- (IBAction)playTogetherAction:(id)sender;
- (IBAction)questionAction:(id)sender;
- (IBAction)wantAction:(id)sender;

-(void)setupWithSelectedApp:(PAApp*)app;

@end
