//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

@interface PAPEditAppViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic,assign) BOOL closeModalViewOnPublish;
@property (nonatomic,assign) BOOL publishPriceDrop;
@property (nonatomic,strong) NSString* priceDropText;

- (instancetype)initWithApp:(PAApp *)aApp NS_DESIGNATED_INITIALIZER;

@end
