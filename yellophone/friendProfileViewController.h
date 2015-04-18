//
//  friendProfileViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/28/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendsViewController.h"
#import "callCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "imageViewController.h"

@interface friendProfileViewController : UIViewController<UITableViewDataSource, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *friendProfPic;
@property (strong, nonatomic) IBOutlet UILabel *pointCounter;
@property (strong, nonatomic) IBOutlet UILabel *pickupCounter;
@property NSString *friendInfo;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
- (IBAction)segValue:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *collectView;
@property (nonatomic, strong) NSArray *results;
@property (strong, nonatomic) PFObject *inCall;
@property (strong, nonatomic) NSMutableArray *collectionViewData;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) PFUser *friendUser;

+ (PFObject *)getCall;
+ (void)resetOpen;
extern PFObject *outsideCaller;
@end
