//
//  completeTableController.h
//  yellophone
//
//  Created by Andrew Boryk on 10/8/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "completeCell.h"
#import "voicemailViewController.h"
#import "imageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "friendProfileViewController.h"
#import "userProfileViewController.h"

@interface completeTableController : UITableViewController

@property (strong, nonatomic) PFObject *completeCall;
@property (strong, nonatomic) PFObject *inCall;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) PFFile *transFile;
@property (strong, nonatomic) PFUser *currentUser;
@property BOOL check;


+ (PFFile *) getFile;

extern PFFile* transfer;
@end
