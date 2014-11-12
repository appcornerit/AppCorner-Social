//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAAppIconInfoView.h"

@interface PAAppIconInfoView ()
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;
@end

@implementation PAAppIconInfoView

- (instancetype)initWithFrame:(CGRect)frame app:(PAApp*)app myApps:(BOOL)myApps
{
    self = [super initWithFrame:frame];
    if (self) {
        self.app = app;
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-18.0f, frame.size.width, 18.0f)];
        [self addSubview:self.timestampLabel];
        if(myApps)
        {
            [self.timestampLabel setTextColor: [UIColor colorWithRed:124.0f/255.0f green:124.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
        }
        else
        {
            [self.timestampLabel setTextColor: [PAPCommonGraphic getAquaColor]];
        }

        [self.timestampLabel setFont:[UIFont fontWithName:@"Cochin-BoldItalic" size:10.0f]];
        [self.timestampLabel setBackgroundColor:[UIColor clearColor]];
        self.timestampLabel.textAlignment = NSTextAlignmentCenter;
        
        NSTimeInterval timeInterval = [[self.app createdAt] timeIntervalSinceNow];
        NSString *timestamp = [self.timeIntervalFormatter stringForTimeInterval:timeInterval];
        [self.timestampLabel setText:timestamp];
        
        CGRect iconFrame = CGRectMake(9.0f, 0.0f, frame.size.width - 18.0f,frame.size.width - 18.0f);
        self.iconImageView = [[PAAppIconImageView alloc]initWithFrame:iconFrame app:app];
        [self addSubview:self.iconImageView];
    }
    return self;
}

@end
