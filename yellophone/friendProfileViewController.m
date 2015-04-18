//
//  friendProfileViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/28/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "friendProfileViewController.h"

@interface friendProfileViewController ()

@end

PFObject* outsideCaller = nil;

@implementation friendProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.results = [[NSArray alloc] init];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *_backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(25.0/255.0) green:(181.0/255.0) blue:(254.0/255.0) alpha:1.0];
    self.navigationItem.backBarButtonItem = _backButton;
    _backButton = nil;
    self.friendInfo = [FriendsViewController retrieveUser];
    NSLog(@"Friend Info Check 2: %@", self.friendInfo);
    self.friendUser = [PFQuery getUserObjectWithId:self.friendInfo];
    self.navigationItem.title = self.friendUser.username;
    NSLog(@"User: %@", self.friendUser);
    
    if (![self.friendUser objectForKey:@"currentProfileImage"]) {
        NSLog(@"Not Executed");
        self.friendProfPic.image = [UIImage imageNamed:@"default_user.jpg"];
        self.friendProfPic.layer.borderWidth = 0.5f;
        self.friendProfPic.layer.borderColor = [UIColor grayColor].CGColor;
        self.friendProfPic.layer.cornerRadius = self.friendProfPic.frame.size.width / 2;
        self.friendProfPic.clipsToBounds = YES;
    }
    else{
        NSLog(@"Executed");
        NSURL *pictureURL = [NSURL URLWithString:[self.friendUser objectForKey:@"currentProfileImage"]];
        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
        self.friendProfPic.image = [UIImage imageWithData:imageData];
        self.friendProfPic.layer.borderWidth = 0.5f;
        self.friendProfPic.layer.borderColor = [UIColor grayColor].CGColor;
        self.friendProfPic.layer.cornerRadius = self.friendProfPic.frame.size.width / 2;
        self.friendProfPic.clipsToBounds = YES;
    }
    
    if ([self isEmpty:[self.friendUser objectForKey:@"playerPoints"]])
    {
        self.pointCounter.text = @"0";
    }
    else
    {
        self.pointCounter.text = [[self.friendUser objectForKey:@"playerPoints"] stringValue];
    }
    
    if ([self isEmpty:[self.friendUser objectForKey:@"pickupPoints"]])
    {
        self.pickupCounter.text = @"0";
    }
    else
    {
        self.pickupCounter.text = [[self.friendUser objectForKey:@"pickupPoints"] stringValue];
    }
    
    [self.segControl setSelectedSegmentIndex:0];
    PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
    [query whereKey:@"senderId" equalTo:self.friendInfo];
    [query whereKey:@"currentRecipient" equalTo:@"Open"];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else{
            NSLog(@"Objects: %@", objects);
            self.collectionViewData = (NSMutableArray *)objects;
            NSLog(@"Calls: %@", self.collectionViewData);
            [self.collectView reloadData];
        }
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.segControl.selectedSegmentIndex == 0){
        return [self.collectionViewData count];
    }
    else if (self.segControl.selectedSegmentIndex == 1){
        return [self.collectionViewData count];
    }
    else
    {
        return [self.collectionViewData count];
    }
    
}

-(callCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    callCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (self.segControl.selectedSegmentIndex == 1){
        cell.picture.image = [UIImage imageNamed:@"card"];
        cell.picture.image = [cell.picture.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        NSString *firstPhrase = [[[_collectionViewData objectAtIndex:indexPath.row]objectForKey:@"listOfPhrases"]firstObject];
        NSString *primaryText = [[NSString alloc] initWithFormat: @"Start: %@", firstPhrase];
        cell.firstLine.text = primaryText;
        
        NSString *lastPhrase = [[[_collectionViewData objectAtIndex:indexPath.row]objectForKey:@"listOfPhrases"]lastObject];
        NSString *secondaryText = [[NSString alloc] initWithFormat: @"Finish: %@", lastPhrase];
        cell.secLine.text = secondaryText;
        if ([firstPhrase isEqualToString:lastPhrase]) {
            [cell.picture setTintColor:[UIColor colorWithRed:(63.0/255.0) green:(195.0/255.0) blue:(128.0/255.0) alpha:1.0]];
        }
        else {
            [cell.picture setTintColor:[UIColor colorWithRed:(239.0/255.0) green:(72.0/255.0) blue:(54.0/255.0) alpha:1.0]];
        }
        cell.progBar.hidden = YES;
        return cell;
    }
    
    else if (self.segControl.selectedSegmentIndex == 0)
    {
        cell.picture.image = [UIImage imageNamed:@"card"];
        cell.picture.image = [cell.picture.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [cell.picture setTintColor:[UIColor colorWithRed:(243.0/255.0) green:(156.0/255.0) blue:(18.0/255.0) alpha:1.0]];
        cell.firstLine.text = @"Current: Open";
        cell.secLine.text = @"Tap to Play!";
        cell.progBar.hidden = NO;
        float chainSoFar = [[[NSNumber alloc] initWithInteger:[[[_collectionViewData objectAtIndex:indexPath.row] objectForKey:@"listOfPhrases"] count]]floatValue];
        float chainSize = [[[_collectionViewData objectAtIndex:indexPath.row] objectForKey:@"sizeOfChain"] floatValue];
        float progControl = (float)(chainSoFar / chainSize);
        NSLog(@"ProgControl: %f", progControl);
        if (progControl <=(float)(1.0/7.0)) {
            NSLog(@"Red");
            cell.progBar.progress = (float)(1.0/7.0);
            cell.progBar.tintColor = [UIColor colorWithRed:(242.0/255.0) green:(38.0/255.0) blue:(19.0/255.0) alpha:1.0];
        }
        else if (progControl > (float)(1.0/7.0) && progControl <= (float)(2.0/7.0)) {
            NSLog(@"Middle");
            cell.progBar.progress = (float)(2.0/7.0);
            cell.progBar.tintColor = [UIColor colorWithRed:(246.0/255.0) green:(36.0/255.0) blue:(89.0/255.0) alpha:1.0];
        }
        else if (progControl > (float)(2.0/7.0) && progControl <= (float)(3.0/7.0)) {
            NSLog(@"Orange");
            cell.progBar.progress = (float)(3.0/7.0);
            cell.progBar.tintColor = [UIColor colorWithRed:(248.0/255.0) green:(148.0/255.0) blue:(6.0/255.0) alpha:1.0];
        }
        else if (progControl > (float)(3.0/7.0) && progControl <= (float)(4.0/7.0)) {
            NSLog(@"Yellow");
            cell.progBar.progress = (float)(4.0/7.0);
            cell.progBar.tintColor = [UIColor colorWithRed:(247.0/255.0) green:(202.0/255.0) blue:(24.0/255.0) alpha:1.0];
        }
        else if (progControl > (float)(4.0/7.0) && progControl <= (float)(5.0/7.0)) {
            NSLog(@"Purple");
            cell.progBar.progress = (float)(5.0/7.0);
            cell.progBar.tintColor = [UIColor colorWithRed:(191.0/255.0) green:(85.0/255.0) blue:(236.0/255.0) alpha:1.0];
        }
        else if (progControl > (float)(5.0/7.0) && progControl <= (float)(6.0/7.0)) {
            NSLog(@"Blue");
            cell.progBar.progress = (float)(6.0/7.0);
            cell.progBar.tintColor = [UIColor colorWithRed:(34.0/255.0) green:(167.0/255.0) blue:(240.0/255.0) alpha:1.0];
        }
        else if (progControl > (float)(6.0/7.0) && progControl <= (float)(7.0/7.0)) {
            NSLog(@"Green");
            cell.progBar.progress = 1.0;
            cell.progBar.tintColor = [UIColor colorWithRed:(46.0/255.0) green:(204.0/255.0) blue:(113.0/255.0) alpha:1.0];
        }
        else{
            NSLog(@"Mystery");
            cell.progBar.progress = 1.0;
            cell.progBar.tintColor = [UIColor colorWithRed:(46.0/255.0) green:(204.0/255.0) blue:(113.0/255.0) alpha:1.0];
        }
        return cell;
    }
    else{
        return cell;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.inCall = [self.collectionViewData objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerDidExitFullscreen:) name:@"MPMoviePlayerDidExitFullscreenNotification" object:nil];
    NSString *fileType = [self.inCall objectForKey:@"fileType"];
    if (self.segControl.selectedSegmentIndex==0) {
        PFQuery *openQuery = [PFQuery queryWithClassName:@"Calls"];
        [openQuery whereKey:@"currentRecipient" equalTo:@"Open"];
        [openQuery whereKey:@"objectId" equalTo: self.inCall.objectId];
        [openQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            else{
                if ([[[objects objectAtIndex:0] objectForKey:@"currentRecipient"]isEqualToString:@"Open"]) {
                    if ([fileType isEqualToString:@"image"]) {
                        [self performSegueWithIdentifier:@"showImage" sender:self];
                    }
                    else{
                        outsideCaller = self.inCall;
                        PFFile *videoFile = [self.inCall objectForKey:@"currentFile"];
                        NSURL *fileUrl = [[NSURL alloc] initWithString:videoFile.url];
                        self.moviePlayer.contentURL = fileUrl;
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
                        [self.moviePlayer prepareToPlay];
                        [self.view addSubview:self.moviePlayer.view];
                        [self.moviePlayer setFullscreen:YES animated:NO];
                    }
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This open call has been answered." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                    [alertView show];
                    PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
                    PFUser *user = [PFQuery getUserObjectWithId:self.friendInfo];
                    [query whereKey:@"currentRecipient" equalTo:@"Complete"];
                    [query whereKey:@"senderIdList" equalTo:user.objectId];
                    [query orderByDescending:@"createdAt"];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error) {
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                        }
                        else{
                            NSLog(@"Objects: %@", objects);
                            self.collectionViewData = (NSMutableArray *)objects;
                            NSLog(@"Calls: %@", self.collectionViewData);
                            [self.collectView reloadData];
                        }
                    }];
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }];
    }
    else if (self.segControl.selectedSegmentIndex==1) {
        [self performSegueWithIdentifier:@"completeChainDisplay" sender:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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

#pragma mark - Segment Control
- (IBAction)segValue:(id)sender {
    if (self.segControl.selectedSegmentIndex==0) {
        PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
        [query whereKey:@"senderId" equalTo:self.friendInfo];
        [query whereKey:@"currentRecipient" equalTo:@"Open"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            else{
                NSLog(@"Objects: %@", objects);
                self.collectionViewData = (NSMutableArray *)objects;
                NSLog(@"Calls: %@", self.collectionViewData);
                [self.collectView reloadData];
            }
        }];
    }
    else if (self.segControl.selectedSegmentIndex==1) {
        PFQuery *query = [PFQuery queryWithClassName:@"Calls"];
        PFUser *user = [PFQuery getUserObjectWithId:self.friendInfo];
        [query whereKey:@"currentRecipient" equalTo:@"Complete"];
        [query whereKey:@"senderIdList" equalTo:user.objectId];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            else{
                NSLog(@"Objects: %@", objects);
                self.collectionViewData = (NSMutableArray *)objects;
                NSLog(@"Calls: %@", self.collectionViewData);
                [self.collectView reloadData];
            }
        }];
    }
    else
    {
        [self.collectionViewData removeAllObjects];
        [self.collectView reloadData];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showImage"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        imageViewController *imageView = (imageViewController *)segue.destinationViewController;
        imageView.inboxCall = self.inCall;
    }
    else if ([segue.identifier isEqualToString:@"completeChainDisplay"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        outsideCaller = self.inCall;
    }
}

#pragma mark - Helper Methods
- (BOOL)isEmpty:(NSNumber *)point{
    if (!point) {
        return YES;
    }
    return NO;
}

+ (PFObject *)getCall
{
    return outsideCaller;
}

+(void) resetOpen
{
    outsideCaller = nil;
}

@end
