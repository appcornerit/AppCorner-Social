//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPBadgesViewController.h"
#import "PAPiTunesCountry.h"

@interface PAPBadgesViewController ()

@end

@implementation PAPBadgesViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedBadges = PAPBagdeNone;
        _editMode = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.labelIOwn.text = NSLocalizedString(@"label.badges.own",nil);
    self.labelIWant.text = NSLocalizedString(@"label.badges.want",nil);
    
    [self.badgesViewBackground setBackgroundColor:[PAPCommonGraphic getBackgroundBlueAlpha]];
    [self.labelsViewBackgorund setBackgroundColor:[PAPCommonGraphic getBackgroundBlueAlpha]];
	// Do any additional setup after loading the view.
}

-(void)dealloc
{
    self.delegate = nil;
}

-(void)setupWithSelectedApp:(PAApp*)app
{
    _app = app;
    if(self.editMode)
    {
        [self.app setObject:@(PAPBagdeNone) forKey:kPAPAppBadges];
        _selectedBadges = PAPBagdeNone;
    }
    else
    {
        NSNumber* badges = [app objectForKey: kPAPAppBadges];
        _selectedBadges = badges?[badges integerValue]:PAPBagdeNone;
    }
    
    BOOL checkBagdePriceDrop = self.selectedBadges & PAPBagdePriceDrop;
    BOOL checkBagdePlayTogether = self.selectedBadges & PAPBagdePlayTogether;
    BOOL checkBagdeQuestion = self.selectedBadges & PAPBagdeQuestion;
    BOOL checkBagdeWant = self.selectedBadges & PAPBagdeWant;
    
    self.priceDropBadgeButton.selected = checkBagdePriceDrop;
    self.playTogetherBadgeButton.selected = checkBagdePlayTogether;
    self.questionBadgeButton.selected = checkBagdeQuestion;
    self.wantBadgeButton.selected = checkBagdeWant;

    self.priceDropBadgeButton.hidden = NO;
    self.playTogetherBadgeButton.hidden = NO;
    self.questionBadgeButton.hidden = NO;
    self.wantBadgeButton.hidden = NO;
    
    self.view.hidden = NO;
    self.labelsViewContainer.hidden = NO;
    self.labelsViewBackgorund.hidden = NO;
    self.view.userInteractionEnabled = self.editMode;
    if(!self.editMode)
    {
        self.labelsViewContainer.hidden = YES;
        self.labelsViewBackgorund.hidden = YES;
        self.priceDropBadgeButton.hidden = !checkBagdePriceDrop;
        self.playTogetherBadgeButton.hidden = !checkBagdePlayTogether;
        self.questionBadgeButton.hidden = !checkBagdeQuestion;
        self.wantBadgeButton.hidden = !checkBagdeWant;
        
        if([self ownSelected])
        {
            //
        }
        else if([self wantSelected])
        {
            //
        }
        else
        {
            self.view.hidden = YES;
        }

    }
    else
    {
        [self.badgesViewBackground setBackgroundColor:[PAPCommonGraphic getBackgroundBlueWithAlpha:0.9f]];
        [self.labelsViewBackgorund setBackgroundColor:[PAPCommonGraphic getBackgroundBlueWithAlpha:0.9f]];
        
        //workaround to show selected button in readonly mode
        [self.priceDropBadgeButton setImage:[UIImage imageNamed:@"home.badge.priceDrop.png"] forState:UIControlStateNormal];
        [self.priceDropBadgeButton setImage:[UIImage imageNamed:@"home.badge.priceDrop.selected.png"] forState:UIControlStateSelected];
        
        [self.playTogetherBadgeButton setImage:[UIImage imageNamed:@"home.badge.playTogether.png"]  forState:UIControlStateNormal];
        [self.playTogetherBadgeButton setImage:[UIImage imageNamed:@"home.badge.playTogether.selected.png"] forState:UIControlStateSelected];
        
        [self.questionBadgeButton setImage:[UIImage imageNamed:@"home.badge.question.png"] forState:UIControlStateNormal];
        [self.questionBadgeButton setImage:[UIImage imageNamed:@"home.badge.question.selected.png"] forState:UIControlStateSelected];
        
        [self.wantBadgeButton setImage:[UIImage imageNamed:@"home.badge.wait.png"] forState:UIControlStateNormal];
        [self.wantBadgeButton setImage:[UIImage imageNamed:@"home.badge.wait.selected.png"] forState:UIControlStateSelected];
        
        self.priceDropBadgeButton.selected = NO;
        self.playTogetherBadgeButton.selected = NO;
        self.questionBadgeButton.selected = NO;
        self.wantBadgeButton.selected = NO;

        self.priceDropBadgeButton.alpha = 0.0;
        self.wantBadgeButton.alpha = 0.0;
            if(self.app.inCountryAppStore)
            {
                CGFloat price = self.app.price.floatValue;
                NSString* userCountry = [PAPiTunesCountry getStoreCountryForCurrenUser];
                NSString* appCountry = [self.app objectForKey:kPAPAppCountryKey];
                if(userCountry && appCountry && ![appCountry isEqualToString:userCountry] && self.app.inCountryAppStore)
                {
                    price = [self.app.inCountryPrice floatValue];
                }
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.priceDropBadgeButton.alpha = 1.0;
                    if(price > 0.0)
                    {
                        self.wantBadgeButton.alpha = 1.0;
                    }
                }];
            }
    }
    [self highlightLabels];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)priceDropAction:(id)sender {
    self.priceDropBadgeButton.selected = !self.priceDropBadgeButton.selected;
    
    if (self.priceDropBadgeButton.selected)
    {
        _selectedBadges = self.selectedBadges | PAPBagdePriceDrop;
        [PAPErrorHandler handleSuccess:@"message.badge.pricedrop"];                
    }
    else
    {
        _selectedBadges = self.selectedBadges & ~PAPBagdePriceDrop;
    }
    
    [self deSelectOwnButtons:YES deSelectWantButtons:NO];
    [self updateBadgesInApp];
    [self highlightLabels];
}

- (IBAction)playTogetherAction:(id)sender {
    self.playTogetherBadgeButton.selected = !self.playTogetherBadgeButton.selected;
    
    if (self.playTogetherBadgeButton.selected)
    {
        _selectedBadges = self.selectedBadges | PAPBagdePlayTogether;
        [PAPErrorHandler handleSuccess:@"message.badge.playtogether"];
    }
    else
    {
        _selectedBadges = self.selectedBadges & ~PAPBagdePlayTogether;
    }
    [self deSelectOwnButtons:YES deSelectWantButtons:NO];
    [self updateBadgesInApp];
    [self highlightLabels];
}

- (IBAction)questionAction:(id)sender {
    self.questionBadgeButton.selected = !self.questionBadgeButton.selected;
    
    if (self.questionBadgeButton.selected)
    {
        _selectedBadges = self.selectedBadges | PAPBagdeQuestion;
        [PAPErrorHandler handleSuccess:@"message.badge.question"];
    }
    else
    {
        _selectedBadges = self.selectedBadges & ~PAPBagdeQuestion;
    }
    [self deSelectOwnButtons:NO deSelectWantButtons:YES];
    [self updateBadgesInApp];
    [self highlightLabels];
}

- (IBAction)wantAction:(id)sender {
    self.wantBadgeButton.selected = !self.wantBadgeButton.selected;
    
    if (self.wantBadgeButton.selected)
    {
        _selectedBadges = self.selectedBadges | PAPBagdeWant;
        [PAPErrorHandler handleSuccess:@"message.badge.want"];
    }
    else
    {
        _selectedBadges = self.selectedBadges & ~PAPBagdeWant;
    }
    [self deSelectOwnButtons:NO deSelectWantButtons:YES];
    [self updateBadgesInApp];    
    [self highlightLabels];
}

-(void) highlightLabels
{
   if([self ownSelected])
   {
       self.labelIOwn.textColor = [UIColor whiteColor];
   }
   else
   {
       self.labelIOwn.textColor = [UIColor grayColor];
   }
    
   if([self wantSelected])
   {
       self.labelIWant.textColor = [UIColor whiteColor];
   }
   else
   {
       self.labelIWant.textColor = [UIColor grayColor];
   }
}

-(void)deSelectOwnButtons:(BOOL)ownEnable deSelectWantButtons:(BOOL)wantEnable
{
    if(ownEnable)
    {
        self.questionBadgeButton.selected = NO;
        self.wantBadgeButton.selected = NO;
        _selectedBadges = self.selectedBadges & ~PAPBagdeQuestion;
        _selectedBadges = self.selectedBadges & ~PAPBagdeWant;
    }
    else if(wantEnable)
    {
        self.priceDropBadgeButton.selected = NO;
        self.playTogetherBadgeButton.selected = NO;
        _selectedBadges = self.selectedBadges & ~PAPBagdePriceDrop;
        _selectedBadges = self.selectedBadges & ~PAPBagdePlayTogether;
    }
  
}

-(BOOL) ownSelected
{
    return (self.selectedBadges & PAPBagdePriceDrop || self.selectedBadges & PAPBagdePlayTogether);
}

-(BOOL) wantSelected
{
    return (self.selectedBadges & PAPBagdeQuestion || self.selectedBadges & PAPBagdeWant);
}

-(void) updateBadgesInApp
{
    [self.app setObject:@(self.selectedBadges) forKey:kPAPAppBadges];
    if(self.delegate)
    {
        [self.delegate badgesUpdated];
    }
}

@end
