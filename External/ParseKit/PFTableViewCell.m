//
//  PFTableViewCell.m
//  ParseKit
//
//  Created by Denis Berton on 22/09/12.
//  Copyright (c) 2012 Denis Berton. All rights reserved.
//

#import "PFTableViewCell.h"

@implementation PFTableViewCell

@synthesize imageView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imageView = [[PFImageView alloc] init];
        [self.contentView addSubview:[self imageView]];
    }
    
    return self;
}


@end
