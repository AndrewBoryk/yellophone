//
//  profileViewCell.h
//  yellophone
//
//  Created by Andrew Boryk on 10/7/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *primaryText;
@property (strong, nonatomic) IBOutlet UILabel *subText;

@end
