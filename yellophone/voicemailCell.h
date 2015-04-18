//
//  voicemailCell.h
//  yellophone
//
//  Created by Andrew Boryk on 10/7/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface voicemailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *mainText;
@property (strong, nonatomic) IBOutlet UILabel *subText;
@property (strong, nonatomic) IBOutlet UIProgressView *chainProgress;

@end
