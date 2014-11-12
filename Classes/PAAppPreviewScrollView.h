//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "MHFacebookImageViewer.h"
#import "PAPBadgesViewController.h"

#define mainImageWidth 300.0f
#define mainImageHeight 212.0f
#define screenWidth 320.0f 

@interface PAAppPreviewScrollView : UIView <MHFacebookImageViewerDatasource>

@property (nonatomic,strong) PAApp* app;
@property (nonatomic,assign) BOOL editMode;
@property (nonatomic,assign) BOOL publishPriceDrop;
@property (nonatomic,strong) NSMutableArray* appImagesView;
@property (nonatomic,strong) PAPBadgesViewController* badgesViewController;
@property (nonatomic,strong) UIScrollView* appsScrollView;

@property (NS_NONATOMIC_IOSONLY, getter=getCurrentImage, readonly, strong) UIImage *currentImage;

@end
