//
//  SearchContactsViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/19/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SearchTableViewCell.h"
@interface SearchContactsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate>

@property (nonatomic, strong) NSArray *contacts;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) PFUser *currentUser;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *friends;
@property (strong, nonatomic) IBOutlet UILabel *selectedUsername;
@end
