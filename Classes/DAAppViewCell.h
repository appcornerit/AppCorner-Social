//
//
//  AppCorner
//
//  Created by Denis Berton 2013.
//
//

#import <UIKit/UIKit.h>

@interface DAAppViewCell : UITableViewCell

@property (nonatomic, copy) PAApp *appObject;

@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@end
