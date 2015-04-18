//
//  callCell.h
//  yellophone
//
//  Created by Andrew Boryk on 10/8/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface callCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *firstLine;
@property (strong, nonatomic) IBOutlet UILabel *secLine;
@property (strong, nonatomic) IBOutlet UIProgressView *progBar;

@end
