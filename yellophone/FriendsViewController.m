//
//  FriendsViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 6/11/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "FriendsViewController.h"
@interface FriendsViewController ()
{
   
}
@end

NSString* userInfo = nil;

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    self.refreshControl = [[UIRefreshControl alloc] init];
    //self.refreshControl.backgroundColor = [UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(25.0/255.0) alpha:1.0];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:(25.0/255.0) green:(181.0/255.0) blue:(254.0/255.0) alpha:0.9];
    //self.refreshControl.tintColor = [UIColor colorWithRed:(16.0/255.0) green:(96.0/255.0) blue:(155.0/255.0) alpha:1.0];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshFriends)
                  forControlEvents:UIControlEventValueChanged];
    self.navigationItem.title = @"Friends with Yellophone";
    self.storedUser = [PFUser currentUser];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    self.currentUser = [PFUser currentUser];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(25.0/255.0) green:(181.0/255.0) blue:(254.0/255.0) alpha:1.0];
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:(44.0/255.0) green:(46.0/255.0) blue:(51.0/255.0) alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self.storedUser isEqual:self.currentUser] || !self.friends) {
        [self disableForWaiting];
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result will contain an array with your user's friends in the "data" key
                NSArray *friendObjects = [result objectForKey:@"data"];
                NSLog(@"Friends: %@", friendObjects);
                NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                // Create a list of friends' Facebook IDs
                for (NSDictionary *friendObject in friendObjects) {
                    NSLog(@"Friend ID: %@", [friendObject objectForKey:@"id"]);
                    [friendIds addObject:[friendObject objectForKey:@"id"]];
                }
                
                // Construct a PFUser query that will find friends whose facebook ids
                // are contained in the current user's friend list.
                PFQuery *friendQuery = [PFUser query];
                friendQuery.limit = 1000;
                [friendQuery orderByAscending:@"username"];
                [friendQuery whereKey:@"fbId" containedIn:friendIds];
                
                // findObjects will return a list of PFUsers that are friends
                // with the current user
                NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                             ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
                self.friends = (NSMutableArray *)[[friendQuery findObjects] sortedArrayUsingDescriptors:sortDescriptors];
                NSLog(@"Friends Now: %@", self.friends);
                [self.tableView reloadData];
                [self endWaitingAndResume];
            }
        }];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self endWaitingAndResume];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

#pragma mark - Table view delegate
- (FriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
    [query whereKey:@"senderId" equalTo:user.objectId];
    [query whereKey:@"currentRecipient" equalTo:@"Open"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else{
            if ([objects count])
            {
                cell.userText.textColor = [UIColor redColor];
            }
            else
            {
                NSLog(@"HIT 3 %@", user.username);
                cell.userText.textColor = [UIColor blackColor];
            }
        }
    }];
    cell.userText.text = user.username;
    if (![user objectForKey:@"currentProfileImage"]) {
        cell.picture.image = [UIImage imageNamed:@"defaultUser"];
        cell.picture.layer.borderWidth = 0.25f;
        cell.picture.layer.borderColor = [UIColor grayColor].CGColor;
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2;
        cell.picture.clipsToBounds = YES;
    }
    else{
        NSURL *pictureURL = [NSURL URLWithString:[user objectForKey:@"currentProfileImage"]];
        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
        cell.picture.image = [UIImage imageWithData:imageData];
        cell.picture.layer.borderWidth = 0.25f;
        cell.picture.layer.borderColor = [UIColor grayColor].CGColor;
        cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2;
        cell.picture.clipsToBounds = YES;
    }
    NSString *points;
    if ([self isEmpty:[user objectForKey:@"playerPoints"]])
    {
        points = @"0";
        NSString *secondaryText = [[NSString alloc] initWithFormat: @"points: %@", points];
        cell.subText.text = secondaryText;
    }
    else
    {
        points = [[user objectForKey:@"playerPoints"] stringValue];
        NSString *secondaryText = [[NSString alloc] initWithFormat: @"points: %@", points];
        cell.subText.text = secondaryText;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    userInfo = user.objectId;
    NSLog(@"Friend Info Check 1: %@", userInfo);
    [self performSegueWithIdentifier:@"toFriendProfile" sender:self];
    NSLog(@"Friends: %@", self.friends);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toFriendProfile"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (BOOL)isFriend:(PFUser *)user{
    for (PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}

-(void) refreshFriends
{
    [[PFUser currentUser] refresh];
    self.currentUser = [PFUser currentUser];
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSLog(@"Friends: %@", friendObjects);
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                NSLog(@"Friend ID: %@", [friendObject objectForKey:@"id"]);
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            friendQuery.limit = 1000;
            [friendQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                         ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            self.friends = (NSMutableArray *)[[friendQuery findObjects] sortedArrayUsingDescriptors:sortDescriptors];
            NSLog(@"Friends Now: %@", self.friends);
            [self.tableView reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

+ (NSString*)retrieveUser
{
    return userInfo;
}

+ (void)resetCall
{
    userInfo = nil;
}

- (BOOL)isEmpty:(NSNumber *)point{
    if (!point) {
        return YES;
    }
    return NO;
}

-(void)disableForWaiting
{
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    _disabledView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 560.0)];
    [_disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.view addSubview:_disabledView];
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.color = [UIColor colorWithRed:(25.0/255.0) green:(181.0/255.0) blue:(254.0/255.0) alpha:1.0];
    _activityView.center=self.view.center;
    [_activityView startAnimating];
    [_disabledView addSubview:_activityView];
}

-(void) endWaitingAndResume
{
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
    [_disabledView removeFromSuperview];
    //[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


@end
