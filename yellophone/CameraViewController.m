//
//  CameraViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/24/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"thisSize: %@", [ChallengeViewController thisSize]);
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.recipients = [[NSMutableArray alloc] init];
    self.currentUser = [PFUser currentUser];
    _myPicUrl = [self.currentUser objectForKey:@"currentProfileImage"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:(102.0/255.0) green:(51.0/255.0) blue:(153.0/255.0) alpha:0.9];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshFriends)
                  forControlEvents:UIControlEventValueChanged];
}
- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
    [super viewWillAppear:animated];
    self.currentUser = [PFUser currentUser];
    if (self.image == nil && [self.videoFilePath length] == 0)
    {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 7;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else{
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        ;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [self presentViewController: self.imagePicker animated:NO completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
            [friendQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"username"
                                                                         ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
            self.friends = (NSMutableArray *)[[friendQuery findObjects] sortedArrayUsingDescriptors:sortDescriptors];
            NSLog(@"Friends Now: %@", self.friends);
            [self endWaitingAndResume];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self endWaitingAndResume];
    self.tabBarController.tabBar.hidden = NO;
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

-(FriendCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.userText.text = user.username;
    if (![user objectForKey:@"currentProfileImage"]) {
        cell.picture.image = [UIImage imageNamed:@"default_user.jpg"];
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
    if ([self isEmpty:[user objectForKey:@"pickupPoints"]])
    {
        points = @"0";
        NSString *secondaryText = [[NSString alloc] initWithFormat: @"pickups: %@", points];
        cell.subText.text = secondaryText;
    }
    else
    {
        points = [[user objectForKey:@"pickupPoints"] stringValue];
        NSString *secondaryText = [[NSString alloc] initWithFormat: @"pickups: %@", points];
        cell.subText.text = secondaryText;
    }
//    if ([self.recipients containsObject:user.objectId]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.canButton.enabled = NO;
    self.openButton.enabled = NO;
    [self.view setUserInteractionEnabled:NO];
    PFObject *oCall = [friendProfileViewController getCall];
    if (oCall) {
        PFQuery *openQuery = [PFQuery queryWithClassName:@"Calls"];
        [openQuery whereKey:@"currentRecipient" equalTo:@"Open"];
        [openQuery whereKey:@"objectId" equalTo:oCall.objectId];
        [openQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!objects) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This open call has been answered." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alertView show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                if (self.image == nil && [self.videoFilePath length] == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Sorry, no image or video was selected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                    [self presentViewController:self.imagePicker animated:NO completion:nil];
                }
                else{
                    PFUser *user = [self.friends objectAtIndex:indexPath.row];
                    self.nextRecipient = user.objectId;
                    self.nextRecName = user.username;
                    [self sendVideo];
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
        }];
    }
    else{
        if (self.image == nil && [self.videoFilePath length] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Sorry, no image or video was selected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            [self presentViewController:self.imagePicker animated:NO completion:nil];
        }
        else{
            PFUser *user = [self.friends objectAtIndex:indexPath.row];
            self.nextRecipient = user.objectId;
            self.nextRecName = user.username;
            [self sendVideo];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Image Picker Controller Delegate
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:NO completion:nil];
     self.tabBarController.tabBar.hidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //image
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
    }
    else{
        //video
        self.videoFilePath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
            
        }
    }
    [self disableForWaiting];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions
- (IBAction)cancelButton:(id)sender
{
    [self reset];
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)sendVideo
{
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
//    _disabledView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 560.0)];
//    [_disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
//    [self.view addSubview:_disabledView];
//    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    _activityView.color = [UIColor colorWithRed:(16.0/255.0) green:(96.0/255.0) blue:(155.0/255.0) alpha:1.0];
//    _activityView.center=self.view.center;
//    [_activityView startAnimating];
//    [_disabledView addSubview:_activityView];
    if (self.image == nil && [self.videoFilePath length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Sorry, no image or video was selected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    else{
        [self disableForWaiting];
        [self uploadMessage];
    }
}
- (IBAction)sendButton:(id)sender
{
    if (self.image == nil && [self.videoFilePath length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again" message:@"Sorry, no image or video was selected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    }
    else{
        self.nextRecipient = @"Open";
        self.nextRecName = @"Open";
        [self sendVideo];
        
        
    }
}


#pragma mark - Helper Methods
-(void)uploadMessage{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    NSLog(@"Reached");
    if (self.image != nil)
    {
        NSLog(@"Reached Next");
        UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    }
    
    else{
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    NSLog(@"Reached Here");
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
        else{
            NSLog(@"Reached Saving");
            PFObject *thisCall = [imageViewController retrieveCall];
            PFObject *thatCall = [voicemailViewController retrievCall];
            PFObject *oCall = [friendProfileViewController getCall];
            _currentUser = [PFUser currentUser];
            if (!thisCall && !thatCall && !oCall) {
                NSLog(@"Saving New");
                PFObject *call = [PFObject objectWithClassName:@"Calls"];
                [call setObject:file forKey:@"currentFile"];
                [call addObject:file forKey:@"listOfFiles"];
                [call setObject:fileType forKey:@"fileType"];
                [call addObject:fileType forKey:@"listOfFileTypes"];
                [call setObject:_myPicUrl forKey:@"profPicCurrent"];
                [call addObject:_myPicUrl forKey:@"profPicArray"];
                [call setObject:self.nextRecipient forKey:@"currentRecipient"];
                [call addObject:self.nextRecipient forKey:@"listOfRecipients"];
                [call setObject:self.nextRecName forKey:@"recName"];
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" equalTo:self.nextRecipient];
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery]; // Set our Installation query
                NSString *pString = [NSString stringWithFormat:@"%@ sent you a call!", [_currentUser username]];
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      pString, @"alert",
                                      @"Increment", @"badge",
                                      nil];
                
                [push setData:data];
                [push sendPushInBackground];
                [call setObject:[_currentUser objectId] forKey:@"senderId"];
                [call setObject:[_currentUser username] forKey:@"senderName"];
                [call addObject:[_currentUser username] forKey:@"listOfSenders"];
                [call addObject:[_currentUser objectId] forKey:@"senderIdList"];
                NSLog(@"Phrase: %@", [ChallengeViewController thisPhrase]);
                [call setObject:[ChallengeViewController thisPhrase] forKey:@"phrase"];
                [call addObject:[ChallengeViewController thisPhrase] forKey:@"listOfPhrases"];
                [call setObject:[ChallengeViewController thisSize] forKey:@"sizeOfChain"];
                
                //playerPoints addition
                NSNumber *ppointTracker = [NSNumber numberWithInt:[[[PFUser currentUser] objectForKey:@"playerPoints"] intValue]];
                NSLog(@"PPOINTTRACKER: %@", ppointTracker);
                if ([ppointTracker isEqual:nil]) {
                    [self addNewPlayerPoints];
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPlayerPoints];
                    [self saveOurCurrentUser];
                }
                NSLog(@"thisSize: %@", [ChallengeViewController thisSize]);
                if ([[ChallengeViewController thisSize] intValue] == 15) {
                    NSNumber *inc = [NSNumber numberWithInt:([[self.currentUser objectForKey:@"fifChains"] intValue] - 1)];
                    [self.currentUser setObject:inc forKey:@"fifChains"];
                    [self.currentUser saveInBackground];
                }
                else if ([[ChallengeViewController thisSize] intValue] == 25) {
                    NSNumber *inc = [NSNumber numberWithInt:([[self.currentUser objectForKey:@"tweChains"] intValue] - 1)];
                    [self.currentUser setObject:inc forKey:@"tweChains"];
                    [self.currentUser saveInBackground];
                }
                [call saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                    }
                    else {
                        
                        [self reset];
                        NSLog(@"Saved New");
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
                
            }
            else if (thisCall){
                NSLog(@"Saving Old");
                [thisCall setObject:file forKey:@"currentFile"];
                [thisCall addObject:file forKey:@"listOfFiles"];
                [thisCall setObject:fileType forKey:@"fileType"];
                [thisCall addObject:fileType forKey:@"listOfFileTypes"];
                [thisCall setObject:_myPicUrl forKey:@"profPicCurrent"];
                [thisCall addObject:_myPicUrl forKey:@"profPicArray"];
                int counter = (int)[[thisCall objectForKey:@"listOfFiles"] count];
                NSLog(@"Counter: %i", counter);
                int compare = ([[thisCall objectForKey: @"sizeOfChain"] intValue]);
                NSLog(@"Compare: %i", compare);
                if (counter >= compare) {
                    NSLog(@"Did do this.");
                    self.nextRecipient = @"Complete";
                    self.nextRecName = @"Complete";
                    NSLog(@"Complete Recipient: %@", self.nextRecipient);
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" containedIn:[thisCall objectForKey:@"listOfRecipients"]];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    NSString *pString = [NSString stringWithFormat:@"Your chain has completed!"];
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          pString, @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    [push setData:data];
                    [push sendPushInBackground];
                }
                else
                {
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:self.nextRecipient];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    NSString *pString = [NSString stringWithFormat:@"%@ sent you a call!", [_currentUser username]];
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          pString, @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    [push setData:data];
                    [push sendPushInBackground];
                }
                [thisCall setObject:self.nextRecipient forKey:@"currentRecipient"];
                [thisCall addObject:self.nextRecipient forKey:@"listOfRecipients"];
                [thisCall setObject:self.nextRecName forKey:@"recName"];
                [thisCall setObject:[_currentUser objectId] forKey:@"senderId"];
                [thisCall addObject:[_currentUser username] forKey:@"listOfSenders"];
                [thisCall addObject:[_currentUser objectId] forKey:@"senderIdList"];
                if ([self.nextRecipient isEqualToString:@"Complete"]) {
                    [thisCall setObject:@"Complete" forKey:@"senderName"];
                }
                else{
                    [thisCall setObject:[_currentUser username] forKey:@"senderName"];
                }
                NSLog(@"Phrase: %@", [ChallengeViewController thisPhrase]);
                [thisCall setObject:[ChallengeViewController thisPhrase] forKey:@"phrase"];
                [thisCall addObject:[ChallengeViewController thisPhrase] forKey:@"listOfPhrases"];
                
                //playerPoints addition
                NSNumber *ppointTracker = [NSNumber numberWithInt:[[_currentUser objectForKey:@"playerPoints"] intValue]];
                NSLog(@"PPOINTTRACKER: %@", ppointTracker);
                if ([ppointTracker isEqual:nil]) {
                    [self addNewPlayerPoints];
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPlayerPoints];
                    [self saveOurCurrentUser];
                }
                
                //pickupPoints addition
                NSNumber *pickuppointTracker = [NSNumber numberWithInt:[[_currentUser objectForKey:@"pickupPoints"] intValue]];
                NSLog(@"PickupPOINTTRACKER: %@", pickuppointTracker);
                if ([pickuppointTracker isEqual:nil]) {
                    
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPickupPoints];
                    [self saveOurCurrentUser];
                }
                
                [thisCall saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                    }
                    else {
                        [self reset];
                        NSLog(@"Saved Old");
                        [imageViewController resetCall];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            }
            else if (thatCall){
                NSLog(@"Saving Old");
                [thatCall setObject:file forKey:@"currentFile"];
                [thatCall addObject:file forKey:@"listOfFiles"];
                [thatCall setObject:fileType forKey:@"fileType"];
                [thatCall addObject:fileType forKey:@"listOfFileTypes"];
                [thatCall setObject:_myPicUrl forKey:@"profPicCurrent"];
                [thatCall addObject:_myPicUrl forKey:@"profPicArray"];
                int counter = (int)[[thatCall objectForKey:@"listOfFiles"] count];
                NSLog(@"Counter: %i", counter);
                int compare = ([[thatCall objectForKey: @"sizeOfChain"] intValue]);
                NSLog(@"Compare: %i", compare);
                if (counter >= compare) {
                    NSLog(@"Did do this.");
                    self.nextRecipient = @"Complete";
                    self.nextRecName = @"Complete";
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" containedIn:[thatCall objectForKey:@"listOfRecipients"]];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    NSString *pString = [NSString stringWithFormat:@"Your chain has completed!"];
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          pString, @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    [push setData:data];
                    [push sendPushInBackground];
                    NSLog(@"Complete Recipient: %@", self.nextRecipient);
                }
                else {
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:self.nextRecipient];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    NSString *pString = [NSString stringWithFormat:@"%@ sent you a call!", [_currentUser username]];
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          pString, @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    [push setData:data];
                    [push sendPushInBackground];
                }
                [thatCall setObject:self.nextRecipient forKey:@"currentRecipient"];
                [thatCall addObject:self.nextRecipient forKey:@"listOfRecipients"];
                [thatCall setObject:self.nextRecName forKey:@"recName"];
                [thatCall setObject:[_currentUser objectId] forKey:@"senderId"];
                [thatCall addObject:[_currentUser username] forKey:@"listOfSenders"];
                [thatCall addObject:[_currentUser objectId] forKey:@"senderIdList"];
                if ([self.nextRecipient isEqualToString:@"Complete"]) {
                    [thatCall setObject:@"Complete" forKey:@"senderName"];
                }
                else{
                    [thatCall setObject:[_currentUser username] forKey:@"senderName"];
                }
                NSLog(@"Phrase: %@", [ChallengeViewController thisPhrase]);
                [thatCall setObject:[ChallengeViewController thisPhrase] forKey:@"phrase"];
                [thatCall addObject:[ChallengeViewController thisPhrase] forKey:@"listOfPhrases"];
                
                //playerPoints addition
                NSNumber *ppointTracker = [NSNumber numberWithInt:[[_currentUser objectForKey:@"playerPoints"] intValue]];
                NSLog(@"PPOINTTRACKER: %@", ppointTracker);
                if ([ppointTracker isEqual:nil]) {
                    [self addNewPlayerPoints];
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPlayerPoints];
                    [self saveOurCurrentUser];
                }
                
                //pickupPoints addition
                NSNumber *pickuppointTracker = [NSNumber numberWithInt:[[_currentUser objectForKey:@"pickupPoints"] intValue]];
                NSLog(@"PickupPOINTTRACKER: %@", pickuppointTracker);
                if ([pickuppointTracker isEqual:nil]) {
                    
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPickupPoints];
                    [self saveOurCurrentUser];
                }
                [thatCall saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                    }
                    else {
                        [self reset];
                        NSLog(@"Saved Old");
                        [voicemailViewController reseCall];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            }
            else if (oCall){
                NSLog(@"Saving Open");
                [oCall setObject:file forKey:@"currentFile"];
                [oCall addObject:file forKey:@"listOfFiles"];
                [oCall setObject:fileType forKey:@"fileType"];
                [oCall addObject:fileType forKey:@"listOfFileTypes"];
                [oCall setObject:_myPicUrl forKey:@"profPicCurrent"];
                [oCall addObject:_myPicUrl forKey:@"profPicArray"];
                int counter = (int)[[oCall objectForKey:@"listOfFiles"] count];
                NSLog(@"Counter: %i", counter);
                int compare = ([[oCall objectForKey: @"sizeOfChain"] intValue]);
                NSLog(@"Compare: %i", compare);
                if (counter >= compare) {
                    NSLog(@"Did do this.");
                    self.nextRecipient = @"Complete";
                    self.nextRecName = @"Complete";
                    NSLog(@"Complete Recipient: %@", self.nextRecipient);
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" containedIn:[oCall objectForKey:@"listOfRecipients"]];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    NSString *pString = [NSString stringWithFormat:@"Your chain has completed!"];
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          pString, @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    [push setData:data];
                    [push sendPushInBackground];
                }
                else
                {
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"user" equalTo:self.nextRecipient];
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    NSString *pString = [NSString stringWithFormat:@"%@ sent you a call!", [_currentUser username]];
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          pString, @"alert",
                                          @"Increment", @"badge",
                                          nil];
                    
                    [push setData:data];
                    [push sendPushInBackground];
                }
                [oCall setObject:self.nextRecipient forKey:@"currentRecipient"];
                [oCall addObject:self.nextRecipient forKey:@"listOfRecipients"];
                [oCall setObject:self.nextRecName forKey:@"recName"];
                [oCall setObject:[_currentUser objectId] forKey:@"senderId"];
                [oCall addObject:[_currentUser username] forKey:@"listOfSenders"];
                [oCall addObject:[_currentUser objectId] forKey:@"senderIdList"];
                if ([self.nextRecipient isEqualToString:@"Complete"]) {
                    [oCall setObject:@"Complete" forKey:@"senderName"];
                }
                else{
                    [oCall setObject:[_currentUser username] forKey:@"senderName"];
                }
                NSLog(@"Phrase: %@", [ChallengeViewController thisPhrase]);
                [oCall setObject:[ChallengeViewController thisPhrase] forKey:@"phrase"];
                [oCall addObject:[ChallengeViewController thisPhrase] forKey:@"listOfPhrases"];
                
                //playerPoints addition
                NSNumber *ppointTracker = [NSNumber numberWithInt:[[_currentUser objectForKey:@"playerPoints"] intValue]];
                NSLog(@"PPOINTTRACKER: %@", ppointTracker);
                if ([ppointTracker isEqual:nil]) {
                    [self addNewPlayerPoints];
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPlayerPoints];
                    [self saveOurCurrentUser];
                }
                
                //pickupPoints addition
                NSNumber *pickuppointTracker = [NSNumber numberWithInt:[[_currentUser objectForKey:@"pickupPoints"] intValue]];
                NSLog(@"PickupPOINTTRACKER: %@", pickuppointTracker);
                if ([pickuppointTracker isEqual:nil]) {
                    
                    [self saveOurCurrentUser];
                }
                else
                {
                    [self addPickupPoints];
                    [self saveOurCurrentUser];
                }
                [oCall saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                    }
                    else {
                        [self reset];
                        NSLog(@"Saved Old");
                        [friendProfileViewController resetOpen];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            }
        }
    }];
}

-(void)reset{
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

-(UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

-(void) saveOurCurrentUser
{
    [_currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) addPickupPoints
{
    NSNumber *ppointHolder = [[PFUser currentUser] objectForKey:@"pickupPoints"];
    NSNumber *pickupPointAdd = [[NSNumber alloc]initWithInt:1];
    NSNumber *newPointTotal = [NSNumber numberWithInt: [ppointHolder intValue] + [pickupPointAdd intValue]];
    [[PFUser currentUser] setObject:newPointTotal forKey:@"pickupPoints"];
}

-(void) addPlayerPoints
{
    NSNumber *pointHolder = [[PFUser currentUser] objectForKey:@"playerPoints"];
    NSNumber *pPointAdd = [[NSNumber alloc]initWithInt:1];
    NSNumber *newPointTotal = [NSNumber numberWithInt: [pointHolder intValue] + [pPointAdd intValue]];
    [[PFUser currentUser] setObject:newPointTotal forKey:@"playerPoints"];
}

-(void) addNewPlayerPoints
{
    NSNumber *pPointNew = [[NSNumber alloc]initWithInt:1];
    [[PFUser currentUser] setObject:pPointNew forKey:@"playerPoints"];
}

-(void) addNewPickupPoints
{
    NSNumber *pickupPointNew = [[NSNumber alloc]initWithInt:1];
    [[PFUser currentUser] setObject:pickupPointNew forKey:@"pickupPoints"];
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
    _activityView.color = [UIColor colorWithRed:(102.0/255.0) green:(51.0/255.0) blue:(153.0/255.0) alpha:1.0];
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
