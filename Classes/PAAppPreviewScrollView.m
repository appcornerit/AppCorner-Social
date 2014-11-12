//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAAppPreviewScrollView.h"

@implementation PAAppPreviewScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.appsScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.appImagesView = [[NSMutableArray alloc]init];
        self.badgesViewController = [[PAPBadgesViewController alloc] initWithNibName:nil bundle:nil];
    }
    return self;
}

-(void) setPublishPriceDrop:(BOOL)publishPriceDrop
{
    if(publishPriceDrop){
        self.badgesViewController.wantBadgesViewContainer.hidden = YES;
        self.badgesViewController.labelIWant.hidden = YES;
        [self.badgesViewController priceDropAction: self];
    }
}

-(void) setApp:(PAApp *)app
{
    _app = app;
    
    NSInteger count = 0;
    [self.appsScrollView removeFromSuperview];
    for (UIView *subview in self.appsScrollView.subviews) {
        if([subview isKindOfClass:[PFImageView class]])
            [subview removeFromSuperview];
    }
    
    [self.appImagesView removeAllObjects];
    [self addSubview:self.appsScrollView];
    self.appsScrollView.pagingEnabled = YES;
    [self.appsScrollView setAlwaysBounceVertical:NO];
    
    for (NSString *url in self.app.screenshotUrls) {

        PFImageView* appImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageWidth*count, 0, mainImageWidth, mainImageHeight)];
        appImageView.backgroundColor = [UIColor clearColor];
        appImageView.contentMode = UIViewContentModeScaleAspectFill;
        appImageView.clipsToBounds = YES;

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc]initWithString:url]];
        [request setHTTPShouldHandleCookies:NO];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        [appImageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"common.app.placeholder.preview.png"] success:nil failure:nil];
        
        [self.appImagesView addObject:appImageView];
        [self.appsScrollView addSubview:appImageView];
        
        if(!self.editMode)
        {
            [appImageView setupImageViewerWithDatasource:self initialIndex:count onOpen:^{} onClose:^{}];
        }
        count++;
    }
    
    if(count == 0)
    {
        PFImageView* appImageView = [[PFImageView alloc] initWithFrame:CGRectMake(mainImageWidth*count, 0, mainImageWidth, mainImageHeight)];
        appImageView.image = [UIImage imageNamed:@"common.app.placeholder.preview.png"];
        appImageView.backgroundColor = [UIColor blackColor];
        appImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.appImagesView addObject:appImageView];
        [self.appsScrollView addSubview:appImageView];
    }
    
    self.appsScrollView.contentOffset = CGPointZero;
    self.appsScrollView.contentSize = CGSizeMake(mainImageWidth * self.appImagesView.count,mainImageHeight);
    
    [self.badgesViewController.view removeFromSuperview];
    [self addSubview:self.badgesViewController.view];
    CGRect frame = self.badgesViewController.view.frame;
    frame.origin = CGPointMake(0.0,self.frame.size.height-frame.size.height);
    frame.size.width = self.frame.size.width;
    self.badgesViewController.view.frame = frame;
    self.badgesViewController.editMode = self.editMode;
    [self.badgesViewController setupWithSelectedApp:self.app];
}

#pragma mark - MHFacebookImageViewerDatasource

- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer *)imageViewer {
    if(self.app)
        return self.app.screenshotUrls.count;
    return 0;
}

-  (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer {
    return [NSURL URLWithString:self.app.screenshotUrls[index]];
}

- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer *)imageViewer{
    return [UIImage imageNamed:@"common.app.placeholder.preview.png"];
}

-(UIImage*) getCurrentImage
{
    int page = self.appsScrollView.contentOffset.x / self.appsScrollView.frame.size.width;
    PFImageView* imageView = self.appImagesView[page];
    return imageView.image;
}

@end
