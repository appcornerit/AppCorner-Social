//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <Foundation/Foundation.h>

@interface PAPSettingsActionSheetDelegate : NSObject <UIActionSheetDelegate>

// Navigation controller of calling view controller
@property (nonatomic, strong) UINavigationController *navController;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController NS_DESIGNATED_INITIALIZER;

@end
