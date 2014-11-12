//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import "PAPEditAppViewController.h"
#import "PAPAppDetailsFooterView.h"
#import "UIImage+ResizeAdditions.h"
#import <DeploydKit/UIImageView+AFNetworking.h>
#import "PAPEditAppHeaderView.h"
#import "PAAppPreviewScrollView.h"
#import "PAPBackButtonItem.h"
#import "PAPEditAppContainerView.h"
#import "PAPiTunesCountry.h"

@interface PAPEditAppViewController () <PAPBadgesViewControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) PAApp *app;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) PAPEditAppHeaderView* headerView;
@property (nonatomic, strong) PAAppPreviewScrollView* appImageScrollView;
@property (nonatomic, strong) PAPEditAppContainerView* containerView;
@property (nonatomic, strong) PAPAppDetailsFooterView *footerView;

@end

@implementation PAPEditAppViewController

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithApp:(PAApp *)aApp {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!aApp) {
            return nil;
        }
        
        self.app = aApp;
        self.closeModalViewOnPublish = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Memory warning on Edit");
}


#pragma mark - UIViewController

- (void)loadView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common.background.png"]];
    self.view = self.scrollView;
    
    self.headerView = [[PAPEditAppHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 5.0f, self.view.bounds.size.width, 44.0f)];
    self.headerView.app = self.app;
    [self.scrollView addSubview:self.headerView];
    
    self.containerView = [[PAPEditAppContainerView alloc]initWithFrame:CGRectMake(0, 49.0f, screenWidth, mainImageHeight)];
    self.containerView.backgroundColor = [UIColor clearColor];
    
    self.appImageScrollView = [[PAAppPreviewScrollView alloc] initWithFrame:CGRectMake((screenWidth-mainImageWidth)/2.0, 0.0f, mainImageWidth, mainImageHeight)];
    self.appImageScrollView.editMode = YES;    
    self.appImageScrollView.app = self.app;
    
    [self.containerView addSubview:self.appImageScrollView];
    [self.scrollView addSubview:self.containerView];
    
    self.appImageScrollView.publishPriceDrop = self.publishPriceDrop;    
    
    
    CGRect footerRect = [PAPAppDetailsFooterView rectForView];
    footerRect.origin.y = self.containerView.frame.origin.y + self.containerView.frame.size.height;

    self.footerView = [[PAPAppDetailsFooterView alloc] initWithFrame:footerRect];
    self.commentTextField = self.footerView.commentField;
    self.commentTextField.delegate = self;
    
    if(self.publishPriceDrop && self.priceDropText.length > 0)
    {
        self.commentTextField.text = self.priceDropText;
    }
    
    [self.scrollView addSubview:self.footerView];

    [self.appImageScrollView bringSubviewToFront:self.scrollView]; //hide header shadow
    self.appImageScrollView.badgesViewController.delegate = self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[PAPBackButtonItem alloc] initWithTarget:self action:@selector(backButtonAction:)];
    
    //ios7 swipe back
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    //ios7 enable swipe back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toolbar.logo.png"]];
    self.navigationItem.titleView.alpha = 0.9;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"publish.button.publish",nil) style:UIBarButtonItemStyleDone target:self action:@selector(pubblishAction:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 140) ? NO : YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateTextFieldColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self pubblishAction:textField];
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.commentTextField resignFirstResponder];  
}


#pragma mark - ()

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [(note.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the app with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [(note.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

- (void)pubblishAction:(id)sender
{
    [self doneButtonAction:sender];
}

- (void)doneButtonAction:(id)sender {
    NSDictionary *userInfo = @{};
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSNumber* badges = [self.app objectForKey: kPAPAppBadges];
    NSUInteger selectedBadges = badges?[badges integerValue]:PAPBagdeNone;

    BOOL checkBagdeQuestion = selectedBadges & PAPBagdeQuestion;

    if(checkBagdeQuestion && trimmedComment.length == 0)
    {
        [PAPErrorHandler handleErrorMessage:@"badges.question.error.commentMissing" titleKey:NSLocalizedString(@"publish.error.generic.title",nil)];
        return;
    }
    
    if (trimmedComment.length != 0) {
        userInfo = @{kPAPEditAppViewControllerUserInfoCommentKey: trimmedComment};
    }
    [self.app setObject:[PFUser currentUser] forKey:kPAPAppUserKey];

    // save
    [self.app saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"app uploaded");
            
            [[PAPCache sharedCache] setAttributesForApp:self.app likers:@[] commenters:@[] likedByCurrentUser:NO];
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = userInfo[kPAPEditAppViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save app caption
                    PFObject *comment = [PFObject objectWithClassName:kPAPActivityClassKey];
                    [comment setObject:kPAPActivityTypeComment forKey:kPAPActivityTypeKey];
                    [comment setObject:self.app forKey:kPAPActivityAppIDKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kPAPActivityToUserKey];
                    [comment setObject:commentText forKey:kPAPActivityContentKey];
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    comment.ACL = ACL;
                    
                    [comment saveEventually];
                    [[PAPCache sharedCache] incrementCommentCountForApp:self.app];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingAppNotification object:self.app];
        } else {
            NSLog(@"app failed to save: %@", error);
            [PAPErrorHandler handleError:error titleKey:NSLocalizedString(@"publish.error.generic.title",nil)];
        }
    }];
    
    if (self.closeModalViewOnPublish) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil]; //modal
    } else {
        [self.navigationController popViewControllerAnimated:YES]; //push
    }
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (buttonIndex == 0) {
        [self doneButtonAction:self];
    }
}

#pragma mark - PAPBadgesViewControllerDelegate

-(void)badgesUpdated
{
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    
    
    NSNumber* badges = [self.app objectForKey: kPAPAppBadges];
    NSUInteger selectedBadges = badges?[badges integerValue]:PAPBagdeNone;
    
    BOOL checkBagdePriceDrop = selectedBadges & PAPBagdePriceDrop;

    NSString* priceMessage = @"";
    if([self.app.price doubleValue] > 0)
    {
        priceMessage = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"activity.message.priceDrop",nil),NSLocalizedString(@"activity.priceDrop.to",nil),self.app.formattedPrice];
    }
    else
    {
        priceMessage = [NSString stringWithFormat:@"app %@",self.app.formattedPrice];
    }
    
    NSString* userCountry = [PAPiTunesCountry getStoreCountryForCurrenUser];
    NSString* appCountry = [self.app objectForKey:kPAPAppCountryKey];
    if(userCountry && appCountry && ![appCountry isEqualToString:userCountry] && self.app.inCountryAppStore)
    {
        if([self.app.inCountryPrice doubleValue] > 0)
        {
            priceMessage = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"activity.message.priceDrop",nil),NSLocalizedString(@"activity.priceDrop.to",nil),self.app.inCountryFormattedPrice];
        }
        else
        {
            priceMessage = [NSString stringWithFormat:@"app %@",self.app.inCountryFormattedPrice];
        }
    }
    
    if(checkBagdePriceDrop && trimmedComment.length == 0)
    {
        if(self.publishPriceDrop)
        {
            self.commentTextField.text = self.priceDropText;
        }
        else
        {
            self.commentTextField.text = priceMessage;
        }
    }
    else if(!checkBagdePriceDrop)
    {
        if(self.publishPriceDrop && [self.commentTextField.text isEqualToString:self.priceDropText])
        {
            self.commentTextField.text = @"";
        }
        else if(!self.publishPriceDrop && [self.commentTextField.text isEqualToString:priceMessage])
        {
            self.commentTextField.text = @"";
        }
    }
    
    [self updateTextFieldColor];    
}

-(void)updateTextFieldColor
{
    NSString *trimmedComment = [self.commentTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSNumber* badges = [self.app objectForKey: kPAPAppBadges];
    NSUInteger selectedBadges = badges?[badges integerValue]:PAPBagdeNone;
    BOOL checkBagdeQuestion = selectedBadges & PAPBagdeQuestion;
    
    if(checkBagdeQuestion && trimmedComment.length == 0)
    {
        self.footerView.mainView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1];
    }
    else if(!checkBagdeQuestion || trimmedComment.length > 0)
    {
        self.footerView.mainView.backgroundColor = [UIColor whiteColor];
    }
}

@end
