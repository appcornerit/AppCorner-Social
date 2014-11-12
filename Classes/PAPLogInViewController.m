//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPLogInViewController.h"

@implementation PAPLogInViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        // for the iPhone 5
        self.rippleImageName = @"Default-568h.png";
    } else {
        self.rippleImageName = @"Default.png";
    }
    
    [super viewDidLoad];
    
    NSString *text = NSLocalizedString(@"login.message.signup", nil);
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:18]
                       constrainedToSize:CGSizeMake( 255.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - textSize.width)/2.0f,
                                                                     [UIScreen mainScreen].bounds.size.height - (textSize.height+150.0f), textSize.width, textSize.height)];
    [self.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setNumberOfLines:0];
    [self.textLabel setText:text];
    [self.textLabel setTextColor:[UIColor whiteColor]];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];


    NSString *textSite = NSLocalizedString(@"login.message.site", nil);
    textSize = [textSite sizeWithFont:[UIFont italicSystemFontOfSize:14]
                       constrainedToSize:CGSizeMake( 255.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.siteLabel = [[UILabel alloc] initWithFrame:CGRectMake( ([UIScreen mainScreen].bounds.size.width - textSize.width)/2.0f,
                                                                   [UIScreen mainScreen].bounds.size.height - (textSize.height+10.0f), textSize.width, textSize.height)];
    [self.siteLabel setFont:[UIFont fontWithName:@"Cochin-Italic" size:18.0f]];
    [self.siteLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.siteLabel setNumberOfLines:0];
    [self.siteLabel setText:textSite];
    [self.siteLabel setTextColor:[UIColor whiteColor]];
    [self.siteLabel setBackgroundColor:[UIColor clearColor]];
    [self.siteLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:self.textLabel];
    [self.view addSubview:self.siteLabel];
    
    self.fields = PFLogInFieldsUsernameAndPassword;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


@end
