//
//  voicemailViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/15/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "voicemailCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "imageViewController.h"
#import "completeTableController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "loginViewController.h"
@interface voicemailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *voicemailCollect;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *calls;
@property (strong, nonatomic) PFObject *inCall;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
- (IBAction)segChanged:(id)sender;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet UILabel *pointCounter;
@property (strong, nonatomic) IBOutlet UILabel *pickupCounter;
@property (strong, nonatomic) IBOutlet UIImageView *reqImage;
@property (strong, nonatomic) PFRelation *friendsRelation;
@property (strong, nonatomic) PFUser *tempUser;
@property (strong, nonatomic) PFUser *storedUser;
@property (strong, nonatomic) UIView *disabledView;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
+ (PFObject *)getCall;
extern PFObject *outsideCall;

- (IBAction)refreshMail:(id)sender;
+ (PFObject*)retrievCall;
+ (void)reseCall;

extern PFObject* callObj;
@end
