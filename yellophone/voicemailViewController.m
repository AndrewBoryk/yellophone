//
//  voicemailViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/15/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "voicemailViewController.h"

@interface voicemailViewController () 

@end

PFObject* outsideCall = nil;
PFObject* callObj = nil;
@implementation voicemailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    if (!self.currentUser) {
        NSLog(@"Left Voicemail");
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    else{
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        if (self.segControl.selectedSegmentIndex==0) {
            PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
            [query whereKey:@"currentRecipient" equalTo:[[PFUser currentUser] objectId]];
            [query orderByDescending:@"updatedAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
                else{
                    NSLog(@"Objects: %@", objects);
                    self.calls = (NSMutableArray *)objects;
                    NSLog(@"Calls: %@", self.calls);
                    [self.voicemailCollect reloadData];
                    
                }
            }];
            [self endWaitingAndResume];
        }
        
        else if (self.segControl.selectedSegmentIndex==1) {
            NSString *userObj = self.currentUser.objectId;
            PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
            [query whereKey:@"senderIdList" equalTo: userObj];
            [query whereKey:@"currentRecipient" notEqualTo:[NSString stringWithFormat:@"Complete"]];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                    [self endWaitingAndResume];
                }
                else{
                    NSLog(@"Objects: %@", objects);
                    self.calls = (NSMutableArray *)objects;
                    NSLog(@"Calls: %@", self.calls);
                    [self.voicemailCollect reloadData];
                    [self endWaitingAndResume];
                }
            }];
        }
        else
        {
            [self.calls removeAllObjects];
            [self.voicemailCollect reloadData];
            [self endWaitingAndResume];
        }
        self.storedUser = [PFUser currentUser];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setUserInteractionEnabled:YES];
    //[[PFUser currentUser] refresh];
    self.currentUser = [PFUser currentUser];
    if(!self.currentUser) {
        NSLog(@"Left Voicemail");
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    else
    {
        //[[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(25.0/255.0) alpha:1.0]];
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(25.0/255.0) alpha:1.0];
        self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:(44.0/255.0) green:(46.0/255.0) blue:(51.0/255.0) alpha:1.0];
    //    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
    //                                                                           fontWithName:@"Helvetica-Bold" size:18], NSFontAttributeName,
    //                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    //    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.topItem.title = @"";
        [UIApplication sharedApplication].statusBarHidden = NO;
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        if(![[self.currentUser objectForKey:@"instructRead"]isEqualToNumber:[NSNumber numberWithBool:YES]])
        {
            [self performSegueWithIdentifier:@"howTo" sender:self];
        }
        else{
            [self disableForWaiting];
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
            if ([[_currentUser objectForKey:@"strikes"] isEqualToNumber: [NSNumber numberWithInt:3]])
            {
                [self performSegueWithIdentifier:@"showLogin" sender:self];
                UIAlertView* message = [[UIAlertView alloc]
                                        initWithTitle: @"Blocked" message: @"Due to investigation on multiple reports on your account, you have been blocked. You will be denied access to your account until further notice." delegate: self
                                        cancelButtonTitle: @"Okay" otherButtonTitles: nil];
                
                [message show];
            }
        }
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.calls || ![self.storedUser isEqual:self.currentUser]) {
        NSLog(@"Executed Refresh");
        if (self.segControl.selectedSegmentIndex==0) {
            PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
            NSLog(@"Current Recipient: %@", [[PFUser currentUser] objectId]);
            [query whereKey:@"currentRecipient" equalTo:[[PFUser currentUser] objectId]];
            [query orderByDescending:@"updatedAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
                else{
                    NSLog(@"Objects: %@", objects);
                    self.calls = (NSMutableArray *)objects;
                    NSLog(@"Calls: %@", self.calls);
                    [self.voicemailCollect reloadData];
                    
                }
            }];
            [self endWaitingAndResume];
        }
        
        else if (self.segControl.selectedSegmentIndex==1) {
            NSString *userObj = self.currentUser.objectId;
            PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
            [query whereKey:@"senderIdList" equalTo: userObj];
            [query whereKey:@"currentRecipient" notEqualTo:[NSString stringWithFormat:@"Complete"]];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                    [self endWaitingAndResume];
                }
                else{
                    NSLog(@"Objects: %@", objects);
                    self.calls = (NSMutableArray *)objects;
                    NSLog(@"Calls: %@", self.calls);
                    [self.voicemailCollect reloadData];
                    [self endWaitingAndResume];
                }
            }];
        }
        else
        {
            [self.calls removeAllObjects];
            [self.voicemailCollect reloadData];
            [self endWaitingAndResume];
        }
    }
    [self endWaitingAndResume];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self endWaitingAndResume];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return [self.calls count];
}

-(voicemailCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    voicemailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (self.segControl.selectedSegmentIndex == 1) {
            cell.picture.image = [UIImage imageNamed:@"card"];
            NSDate *someDate = [[self.calls objectAtIndex:indexPath.row] updatedAt];
            NSDate *now = [NSDate date];
            NSDateComponents *thenComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:someDate];
            NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:now];
            cell.picture.image = [cell.picture.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.picture.layer.borderWidth = 0.0f;
            cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2;
            if ([[[self.calls objectAtIndex:indexPath.row] objectForKey:@"currentRecipient"] isEqualToString:@"Open"])
            {
                [cell.picture setTintColor:[UIColor colorWithRed:(243.0/255.0) green:(156.0/255.0) blue:(18.0/255.0) alpha:1.0]];
                cell.subText.text = [NSString stringWithFormat:@"Open with: %@", [[self.calls objectAtIndex:indexPath.row] objectForKey:@"senderName"]];
            }
            else if(([thenComponents day]-[nowComponents day]) >= 1.0f || ([thenComponents day]-[nowComponents day]) <=-1.0f)
            {
                [cell.picture setTintColor:[UIColor colorWithRed:(239.0/255.0) green:(72.0/255.0) blue:(54.0/255.0) alpha:1.0]];
                cell.subText.text = @"Tap to Nudge Player!";
            }
            else{
                [cell.picture setTintColor:[UIColor colorWithRed:(63.0/255.0) green:(195.0/255.0) blue:(128.0/255.0) alpha:1.0]];
                cell.subText.text = @"Game in Progress...";
            }
            
            //set First Label
            NSString *str = [[self.calls objectAtIndex:indexPath.row] objectForKey:@"recName"];
            NSLog(@"Word: %@", str);
            NSString *primaryText = [[NSString alloc] initWithFormat: @"Current: %@", str];
            cell.mainText.text = primaryText;
            
            //set Date
//            NSDate *tempDate = [[self.calls objectAtIndex:indexPath.row] createdAt];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDoesRelativeDateFormatting:YES];
//            NSString *stringFromDate = [formatter stringFromDate:tempDate];
            
        }
        else{
            //set First Label
            NSString *secString = [[self.calls objectAtIndex:indexPath.row] objectForKey:@"senderName"];
            NSString *primaryText = [[NSString alloc] initWithFormat: @"From: %@", secString];
            cell.mainText.text = primaryText;
            
            //set Date
//            NSDate *tempDate = [[self.calls objectAtIndex:indexPath.row] createdAt];
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDoesRelativeDateFormatting:YES];
//            NSString *stringFromDate = [formatter stringFromDate:tempDate];
            
            //set Second Label
            
            cell.subText.text = @"Tap to View";
            cell.picture.backgroundColor = nil;
            if ([[[self.calls objectAtIndex:indexPath.row] objectForKey:@"profPicCurrent"] isEqualToString:@"no_picture"]) {
                cell.picture.image = [UIImage imageNamed:@"defaultUser"];
                cell.picture.layer.borderWidth = 0.5f;
                cell.picture.layer.borderColor = [UIColor colorWithRed:(44.0/255.0) green:(46.0/255.0) blue:(51.0/255.0) alpha:1.0].CGColor;
                cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2;
                cell.picture.clipsToBounds = YES;
            }
            else{
                NSURL *pictureURL = [NSURL URLWithString:[[self.calls objectAtIndex:indexPath.row] objectForKey:@"profPicCurrent"]];
                NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                cell.picture.image = [UIImage imageWithData:imageData];
                cell.picture.layer.borderWidth = 0.5f;
                cell.picture.layer.borderColor = [UIColor colorWithRed:(44.0/255.0) green:(46.0/255.0) blue:(51.0/255.0) alpha:1.0].CGColor;
                cell.picture.layer.cornerRadius = cell.picture.frame.size.width / 2;
                cell.picture.clipsToBounds = YES;
            }
        }
    
    float chainSoFar = [[[NSNumber alloc] initWithInteger:[[[self.calls objectAtIndex:indexPath.row] objectForKey:@"listOfPhrases"] count]]floatValue];
    float chainSize = [[[self.calls objectAtIndex:indexPath.row] objectForKey:@"sizeOfChain"] floatValue];
    float progControl = (float)(chainSoFar / chainSize);
    NSLog(@"ProgControl: %f", progControl);
    if (progControl <=(float)(1.0/7.0)) {
        NSLog(@"Red");
        cell.chainProgress.progress = (float)(1.0/7.0);
        cell.chainProgress.tintColor = [UIColor colorWithRed:(242.0/255.0) green:(38.0/255.0) blue:(19.0/255.0) alpha:1.0];
    }
    else if (progControl > (float)(1.0/7.0) && progControl <= (float)(2.0/7.0)) {
        NSLog(@"Middle");
        cell.chainProgress.progress = (float)(2.0/7.0);
        cell.chainProgress.tintColor = [UIColor colorWithRed:(246.0/255.0) green:(36.0/255.0) blue:(89.0/255.0) alpha:1.0];
    }
    else if (progControl > (float)(2.0/7.0) && progControl <= (float)(3.0/7.0)) {
        NSLog(@"Orange");
        cell.chainProgress.progress = (float)(3.0/7.0);
        cell.chainProgress.tintColor = [UIColor colorWithRed:(248.0/255.0) green:(148.0/255.0) blue:(6.0/255.0) alpha:1.0];
    }
    else if (progControl > (float)(3.0/7.0) && progControl <= (float)(4.0/7.0)) {
        NSLog(@"Yellow");
        cell.chainProgress.progress = (float)(4.0/7.0);
        cell.chainProgress.tintColor = [UIColor colorWithRed:(247.0/255.0) green:(202.0/255.0) blue:(24.0/255.0) alpha:1.0];
    }
    else if (progControl > (float)(4.0/7.0) && progControl <= (float)(5.0/7.0)) {
        NSLog(@"Purple");
        cell.chainProgress.progress = (float)(5.0/7.0);
        cell.chainProgress.tintColor = [UIColor colorWithRed:(191.0/255.0) green:(85.0/255.0) blue:(236.0/255.0) alpha:1.0];
    }
    else if (progControl > (float)(5.0/7.0) && progControl <= (float)(6.0/7.0)) {
        NSLog(@"Blue");
        cell.chainProgress.progress = (float)(6.0/7.0);
        cell.chainProgress.tintColor = [UIColor colorWithRed:(34.0/255.0) green:(167.0/255.0) blue:(240.0/255.0) alpha:1.0];
    }
    else if (progControl > (float)(6.0/7.0) && progControl <= (float)(7.0/7.0)) {
        NSLog(@"Green");
        cell.chainProgress.progress = 1.0;
        cell.chainProgress.tintColor = [UIColor colorWithRed:(46.0/255.0) green:(204.0/255.0) blue:(113.0/255.0) alpha:1.0];
    }
    else{
        NSLog(@"Mystery");
        cell.chainProgress.progress = 1.0;
        cell.chainProgress.tintColor = [UIColor colorWithRed:(46.0/255.0) green:(204.0/255.0) blue:(113.0/255.0) alpha:1.0];
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self disableForWaiting];
    voicemailCell *cell = (voicemailCell *)[tableView cellForRowAtIndexPath:indexPath];
         self.inCall = [self.calls objectAtIndex:indexPath.row];
         if (self.segControl.selectedSegmentIndex == 0){
             callObject = self.inCall;
             NSLog(@"Call object: %@", self.inCall);
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerDidExitFullscreen:) name:@"MPMoviePlayerDidExitFullscreenNotification" object:nil];
            NSString *fileType = [self.inCall objectForKey:@"fileType"];
            if ([fileType isEqualToString:@"image"]) {
                [self performSegueWithIdentifier:@"showImage" sender:self];
                NSLog(@"Showing image");
            }
            else{
                PFFile *videoFile = [self.inCall objectForKey:@"currentFile"];
                NSLog(@"Showing video");
                NSURL *fileUrl = [[NSURL alloc] initWithString:videoFile.url];
                self.moviePlayer.contentURL = fileUrl;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
                [self endWaitingAndResume];
                [self.moviePlayer prepareToPlay];
                self.moviePlayer.shouldAutoplay = YES;
                self.moviePlayer.controlStyle=MPMovieControlStyleFullscreen;
                [self.view addSubview:self.moviePlayer.view];
                [self.moviePlayer setFullscreen:YES animated:NO];
                
            }
             [tableView deselectRowAtIndexPath:indexPath animated:YES];
         }
        else if (self.segControl.selectedSegmentIndex == 1){
            NSDate *someDate = [[self.calls objectAtIndex:indexPath.row] updatedAt];
            NSDate *now = [NSDate date];
            NSDateComponents *thenComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:someDate];
            NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:now];
            if((([thenComponents day]-[nowComponents day]) >= 1.0f || ([thenComponents day]-[nowComponents day]) <=-1.0f) && !([[[self.calls objectAtIndex:indexPath.row] objectForKey:@"currentRecipient"] isEqualToString:@"Open"]))
            {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo: [self.inCall objectForKey:@"currentRecipient"]];
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                NSString *pString = [NSString stringWithFormat:@"You have been nudged!"];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      pString, @"alert",
                                      @"Increment", @"badge",
                                      nil];
                [push setData:data];
                [push sendPushInBackground];
                cell.picture.image = [cell.picture.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.picture setTintColor:[UIColor colorWithRed:(63.0/255.0) green:(195.0/255.0) blue:(128.0/255.0) alpha:1.0]];
                [self.inCall setObject:[self.inCall objectForKey:@"currentRecipient"] forKey:@"currentRecipient"];
                cell.subText.text = @"Player nudged!";
                [self.inCall saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSString *userObj = self.currentUser.objectId;
                        PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
                        [query whereKey:@"senderIdList" equalTo: userObj];
                        [query whereKey:@"currentRecipient" notEqualTo:[NSString stringWithFormat:@"Complete"]];
                        [query orderByDescending:@"createdAt"];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (error) {
                                NSLog(@"Error %@ %@", error, [error userInfo]);
                            }
                            else{
                                NSLog(@"Objects: %@", objects);
                                self.calls = (NSMutableArray *)objects;
                                NSLog(@"Calls: %@", self.calls);
                                [self.voicemailCollect reloadData];
                                [self endWaitingAndResume];
                            }
                        }];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }
                }];
            }
            else{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            //callObject = self.inCall;
            //[self performSegueWithIdentifier:@"completeChainDisplay" sender:self];
        }
    [self endWaitingAndResume];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showLogin"])
    {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if ([segue.identifier isEqualToString:@"showImage"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        imageViewController *imageView = (imageViewController *)segue.destinationViewController;
        imageView.inboxCall = self.inCall;
        
    }
    else if ([segue.identifier isEqualToString:@"completeChainDisplay"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        outsideCall = self.inCall;
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (IBAction)segChanged:(id)sender {
    [self endWaitingAndResume];
    [self disableForWaiting];
    NSString *userObj = self.currentUser.objectId;
        if (self.segControl.selectedSegmentIndex==0) {
            PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
            [query whereKey:@"currentRecipient" equalTo:[[PFUser currentUser] objectId]];
            [query orderByDescending:@"updatedAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
                else{
                    NSLog(@"Objects: %@", objects);
                    self.calls = (NSMutableArray *)objects;
                    NSLog(@"Calls: %@", self.calls);
                    [self.voicemailCollect reloadData];
                    [self endWaitingAndResume];
                }
            }];
        }
        else if (self.segControl.selectedSegmentIndex==1) {
            PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
            [query whereKey:@"senderIdList" equalTo: userObj];
            [query whereKey:@"currentRecipient" notEqualTo:[NSString stringWithFormat:@"Complete"]];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
                else{
                    NSLog(@"Objects: %@", objects);
                    self.calls = (NSMutableArray *)objects;
                    NSLog(@"Calls: %@", self.calls);
                    [self.voicemailCollect reloadData];
                    [self endWaitingAndResume];
                }
            }];
            
        }
        else
        {
            [self.calls removeAllObjects];
            [self.voicemailCollect reloadData];
            [self endWaitingAndResume];
        }
}

- (BOOL)isEmpty:(NSNumber *)point{
    if (!point) {
        return YES;
    }
    return NO;
}

- (void)MPMoviePlayerDidExitFullscreen:(NSNotification *)notification
{
    [self performSegueWithIdentifier:@"videoFinishedPlaying" sender:self];
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    
    NSLog(@"DID IT EXIT");
    
    //        SavedVideoPlayerScreen *svps = (SavedVideoPlayerScreen *)[segue destinationViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MPMoviePlayerDidExitFullscreenNotification"
                                                  object:nil];
}

-(void)disableForWaiting
{
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    _disabledView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 560.0)];
    [_disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.view addSubview:_disabledView];
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.color = [UIColor colorWithRed:(254.0/255.0) green:(213.0/255.0) blue:(25.0/255.0) alpha:1.0];
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
+ (PFObject *)getCall
{
    return outsideCall;
}

- (IBAction)refreshMail:(id)sender
{
    [self endWaitingAndResume];
    [self disableForWaiting];
    [[PFUser currentUser] refresh];
    self.currentUser = [PFUser currentUser];
    NSString *userObj = self.currentUser.objectId;
    if (self.segControl.selectedSegmentIndex==0) {
        PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
        [query whereKey:@"currentRecipient" equalTo:[[PFUser currentUser] objectId]];
        [query orderByDescending:@"updatedAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            else{
                NSLog(@"Objects: %@", objects);
                self.calls = (NSMutableArray *)objects;
                NSLog(@"Calls: %@", self.calls);
                [self.voicemailCollect reloadData];
                [self endWaitingAndResume];
            }
        }];
    }
    else if (self.segControl.selectedSegmentIndex==1) {
        PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
        [query whereKey:@"senderIdList" equalTo: userObj];
        [query whereKey:@"currentRecipient" notEqualTo:[NSString stringWithFormat:@"Complete"]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            else{
                NSLog(@"Objects: %@", objects);
                self.calls = (NSMutableArray *)objects;
                NSLog(@"Calls: %@", self.calls);
                [self.voicemailCollect reloadData];
                [self endWaitingAndResume];
            }
        }];
        
    }
    else
    {
        [self.calls removeAllObjects];
        [self.voicemailCollect reloadData];
        [self endWaitingAndResume];
    }
}

-(float) progressChanger:(float)progVal
{
    if (progVal <= (float)(1.0/7.0)) {
        return (float)(1.0/7.0);
    }
    else if (progVal > (float)(1.0/7.0) && progVal <= (float)(2.0/7.0)) {
        return (float)(2.0/7.0);
    }
    else if (progVal > (float)(2.0/7.0) && progVal <= (float)(3.0/7.0)) {
        return (float)(3.0/7.0);
    }
    else if (progVal > (float)(3.0/7.0) && progVal <= (float)(4.0/7.0)) {
        return (4.0/7.0);
    }
    else if (progVal > (float)(4.0/7.0) && progVal <= (float)(5.0/7.0)) {
        return (5.0/7.0);
    }
    else if (progVal > (float)(5.0/7.0) && progVal <= (float)(6.0/7.0)) {
        return (float)(6.0/7.0);
    }
    else if (progVal > (float)(6.0/7.0) && progVal <= (float)(7.0/7.0)) {
        return 1.0;
    }
    else{
        return 1.0;
    }
}

+ (PFObject*)retrievCall
{
    return callObject;
}

+ (void)reseCall
{
    callObject = nil;
}



@end