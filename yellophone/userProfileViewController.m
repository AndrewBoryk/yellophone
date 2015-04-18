//
//  userProfileViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/17/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "userProfileViewController.h"

@interface userProfileViewController ()

@end

PFObject *completeCall = nil;
@implementation userProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self disableForWaiting];
    self.currentUser = [PFUser currentUser];
    if(!self.currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    else{
        PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
        [query whereKey:@"currentRecipient" equalTo:@"Complete"];
        [query whereKey:@"senderIdList" equalTo:[self.currentUser objectId]];
        [query orderByDescending:@"updatedAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            else{
                NSLog(@"Objects: %@", objects);
                self.calls = objects;
                NSLog(@"Calls: %@", self.calls);
                [self.profileCollection reloadData];
                [self endWaitingAndResume];
            }
        }];
        
        UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.completeTable insertSubview:refreshView atIndex:0]; //the tableView is a IBOutlet
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor colorWithRed:(247.0/255.0) green:(247.0/255.0) blue:(247.0/255.0) alpha:1.0];
        self.refreshControl.tintColor = [UIColor colorWithRed:(16.0/255.0) green:(96.0/255.0) blue:(155.0/255.0) alpha:1.0];
        [self.refreshControl addTarget:self action:@selector(refreshComps) forControlEvents:UIControlEventValueChanged];
        [refreshView addSubview:self.refreshControl];
        self.storedUser = [PFUser currentUser];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.currentUser = [PFUser currentUser];
    if(!self.currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    else{
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        if (!_profilePicData) {
            self.userProfilePic.image = [UIImage imageNamed:@"defaultUser"];
            self.userProfilePic.layer.borderWidth = 0.5f;
            self.userProfilePic.layer.borderColor = [UIColor grayColor].CGColor;
            self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.width / 2;
            self.userProfilePic.clipsToBounds = YES;
        }
        else
        {
            self.userProfilePic.image = [UIImage imageWithData:_profilePicData];
            self.userProfilePic.layer.borderWidth = 0.5f;
            self.userProfilePic.layer.borderColor = [UIColor grayColor].CGColor;
            self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.width / 2;
            self.userProfilePic.clipsToBounds = YES;
        }
        
         [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(254.0/255.0) green:(25.0/255.0) blue:(67.0/255.0) alpha:1.0];
        self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:(44.0/255.0) green:(46.0/255.0) blue:(51.0/255.0) alpha:1.0];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.topItem.title = @"";
        if (![[self.currentUser objectForKey:@"usernameAdded"] isEqualToNumber:[NSNumber numberWithBool:true]] || ![self.currentUser username])
        {
            [self performSegueWithIdentifier:@"toUsernameAdd" sender:self];
        }
        
        if (![self.currentUser objectForKey:@"currentProfileImage"])
        {
            NSString *profileString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [self.currentUser objectForKey:@"fbId"]];
            [self.currentUser setObject:profileString forKey:@"currentProfileImage"];
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error");
                }
                else
                {
                    NSLog(@"ReSaved Picture");
                }
            }];
        }
        self.navigationItem.title = _currentUser.username;
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSLog(@"Player Points: %@", [_currentUser objectForKey:@"playerPoints"]);
        NSLog(@"Pickup Points: %@", [_currentUser objectForKey:@"pickupPoints"]);
        if ([self isEmpty:[_currentUser objectForKey:@"playerPoints"]])
        {
            self.pointCounter.text = @"0";
        }
        else
        {
            self.pointCounter.text = [[_currentUser objectForKey:@"playerPoints"] stringValue];
        }
        if ([self isEmpty:[_currentUser objectForKey:@"pickupPoints"]])
        {
            self.pickupCounter.text = @"0";
        }
        else
        {
            self.pickupCounter.text = [[_currentUser objectForKey:@"pickupPoints"] stringValue];
        }
    }
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_profilePicData || ![self.storedUser isEqual:self.currentUser]) {
        NSString *profileString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [self.currentUser objectForKey:@"fbId"]];
        NSURL *pictureURL = [NSURL URLWithString:profileString];
        _profilePicData = [NSData dataWithContentsOfURL:pictureURL];
        self.userProfilePic.image = [UIImage imageWithData:_profilePicData];
        self.userProfilePic.layer.borderWidth = 0.5f;
        self.userProfilePic.layer.borderColor = [UIColor grayColor].CGColor;
        self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.width / 2;
        self.userProfilePic.clipsToBounds = YES;
        if (![[self.currentUser objectForKey:@"currentProfileImage"] isEqualToString: profileString]) {
            [self.currentUser setObject:profileString forKey:@"currentProfileImage"];
            NSLog(@"Hit");
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error");
                }
            }];
        }
    }
    
//    else
//    {
//        self.userProfilePic.image = [UIImage imageWithData:_profilePicData];
//        self.userProfilePic.layer.borderWidth = 0.5f;
//        self.userProfilePic.layer.borderColor = [UIColor grayColor].CGColor;
//        self.userProfilePic.layer.cornerRadius = self.userProfilePic.frame.size.width / 2;
//        self.userProfilePic.clipsToBounds = YES;
//    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self endWaitingAndResume];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = @"Recently Completed";
//    switch (section)
//    {
//        case 0:
//            sectionName = NSLocalizedString(@"mySectionName", @"mySectionName");
//            break;
//        case 1:
//            sectionName = NSLocalizedString(@"myOtherSectionName", @"myOtherSectionName");
//            break;
//            // ...
//        default:
//            sectionName = @"";
//            break;
//    }
    return sectionName;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.calls count];
}

-(profileViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    profileViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.picture.image = [UIImage imageNamed:@"card"];
    cell.picture.image = [cell.picture.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    NSString *firstPhrase = [[[_calls objectAtIndex:indexPath.row]objectForKey:@"listOfPhrases"]firstObject];
    NSString *primaryText = [[NSString alloc] initWithFormat: @"Start: %@", firstPhrase];
    cell.primaryText.text = primaryText;
    
    NSString *lastPhrase = [[[_calls objectAtIndex:indexPath.row]objectForKey:@"listOfPhrases"]lastObject];
    NSString *secondaryText = [[NSString alloc] initWithFormat: @"Finish: %@", lastPhrase];
    cell.subText.text = secondaryText;
    if ([firstPhrase isEqualToString:lastPhrase]) {
        [cell.picture setTintColor:[UIColor colorWithRed:(63.0/255.0) green:(195.0/255.0) blue:(128.0/255.0) alpha:1.0]];
    }
    else {
        [cell.picture setTintColor:[UIColor colorWithRed:(239.0/255.0) green:(72.0/255.0) blue:(54.0/255.0) alpha:1.0]];
    }
    
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self disableForWaiting];
    self.inCall = [self.calls objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    completeCall = self.inCall;
    [self performSegueWithIdentifier:@"completeChainDisplay" sender:self];
}

- (void)refreshComps {
    //refresh your data here
    [[PFUser currentUser] refresh];
    self.currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
    [query whereKey:@"currentRecipient" equalTo:@"Complete"];
    [query whereKey:@"senderIdList" equalTo:[[PFUser currentUser]objectId]];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else{
            NSLog(@"Objects: %@", objects);
            self.calls = objects;
            NSLog(@"Calls: %@", self.calls);
            [self.profileCollection reloadData];
        }
    }];
    [self.refreshControl endRefreshing];
}

- (BOOL)isEmpty:(NSNumber *)point{
    if (!point) {
            return YES;
        }
    return NO;
}

- (IBAction)reloadPicture:(id)sender {
    NSLog(@"Action");
    NSString *profileString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [self.currentUser objectForKey:@"fbId"]];
    NSURL *pictureURL = [NSURL URLWithString:profileString];
    _profilePicData = [NSData dataWithContentsOfURL:pictureURL];
    self.userProfilePic.image = [UIImage imageWithData:_profilePicData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"completeChainDisplay"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        completeCall = self.inCall;
        
    }
     [self endWaitingAndResume];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}


-(void)disableForWaiting
{
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    _disabledView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 560.0)];
    [_disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.view addSubview:_disabledView];
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.color = [UIColor colorWithRed:(254.0/255.0) green:(25.0/255.0) blue:(67.0/255.0) alpha:1.0];
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

+ (PFObject*)retrieveCall
{
    return completeCall;
}

+ (void)resetCall
{
    completeCall = nil;
}
@end
