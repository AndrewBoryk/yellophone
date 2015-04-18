//
//  FriendCell.h
//  yellophone
//
//  Created by Andrew Boryk on 8/8/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *userText;
@property (strong, nonatomic) IBOutlet UILabel *subText;

@end
