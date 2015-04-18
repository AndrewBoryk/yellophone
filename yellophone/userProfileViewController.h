//
//  userProfileViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/17/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "loginViewController.h"
#import "profileViewCell.h"
@interface userProfileViewController : UIViewController <NSURLConnectionDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *pointCounter;
@property (strong, nonatomic) IBOutlet UILabel *pickupCounter;
@property (strong, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (strong, nonatomic) NSString *userUsername;
- (IBAction)reloadPicture:(id)sender;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFUser *storedUser;
@property (strong, nonatomic) IBOutlet UITableView *profileCollection;
@property (strong, nonatomic) NSData *profilePicData;
@property (strong, nonatomic) NSArray *calls;
@property (strong, nonatomic) PFObject *inCall;

@property (strong, nonatomic) UIView *disabledView;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet UITableView *completeTable;
+ (PFObject*)retrieveCall;
+ (void)resetCall;
extern PFObject* completeCall;
@end
