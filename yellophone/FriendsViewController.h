//
//  FriendsViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 6/11/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FriendCell.h"
@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *friends;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
+ (NSString*)retrieveUser;
@property (strong, nonatomic) UIView *disabledView;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
extern NSString *userInfo;

@property (strong, nonatomic) PFUser *storedUser;

@end
