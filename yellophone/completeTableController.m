//
//  completeTableController.m
//  yellophone
//
//  Created by Andrew Boryk on 10/8/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "completeTableController.h"

@interface completeTableController ()

@end

PFFile *transfer = nil;
@implementation completeTableController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    _currentUser = [PFUser currentUser];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([userProfileViewController retrieveCall]) {
        self.completeCall = [userProfileViewController retrieveCall];
        if (![[self.completeCall objectForKey:@"didRecievePoints"]containsObject:[[PFUser currentUser] objectId]]) {
            if ([[[[self.completeCall objectForKey:@"listOfPhrases"] objectAtIndex:0] lowercaseString] isEqualToString:[[[self.completeCall objectForKey:@"listOfPhrases"] lastObject] lowercaseString]]) {
                NSNumber *pointHolder = [_currentUser objectForKey:@"playerPoints"];
                NSNumber *pPointAdd = [[NSNumber alloc]initWithInt:10];
                NSNumber *newPointTotal = [NSNumber numberWithInt: [pointHolder intValue] + [pPointAdd intValue]];
                [_currentUser setObject:newPointTotal forKey:@"playerPoints"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congrats!" message:@"Your chain completed successfully, and you have received 10 points for it!" delegate:nil cancelButtonTitle:@"View Complete Chain" otherButtonTitles:nil];
                [alertView show];
                
            }
            else
            {
                NSNumber *pointHolder = [_currentUser objectForKey:@"playerPoints"];
                NSNumber *pPointAdd = [[NSNumber alloc]initWithInt:5];
                NSNumber *newPointTotal = [NSNumber numberWithInt: [pointHolder intValue] + [pPointAdd intValue]];
                [_currentUser setObject:newPointTotal forKey:@"playerPoints"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your chain did not complete successfully, however you received 5 points for completing it." delegate:nil cancelButtonTitle:@"View Complete Chain" otherButtonTitles:nil];
                [alertView show];
            }
            [self.completeCall addObject:[_currentUser objectId] forKey:@"didRecievePoints"];
            [self.completeCall saveInBackground];
            [_currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
            }];
        }
    }
    else{
        if ([friendProfileViewController getCall]) {
            self.completeCall = [friendProfileViewController getCall];
        }
        else{
            NSLog(@"Error no Complete Received");
        }
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showImage"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        imageViewController *imageView = (imageViewController *)segue.destinationViewController;
        NSLog(@"File 2: %@", self.transFile);
        transfer = self.transFile;
        NSLog(@"File 3: %@", transfer);
        imageView.inboxCall = self.completeCall;
    }
}

+ (PFFile *) getFile
{
    return transfer;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.completeCall objectForKey:@"listOfFiles"] count];
}


- (completeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    completeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *firstString = [[self.completeCall objectForKey:@"listOfSenders"] objectAtIndex:indexPath.row];
    cell.firstLine.text = [NSString stringWithFormat: @"Yeller: %@", firstString];
    int num = ((int)indexPath.row +1);
    cell.chainNum.text = [NSString stringWithFormat:@"%i", num];
    NSString *secString = [[self.completeCall objectForKey:@"listOfPhrases"] objectAtIndex:indexPath.row];
    cell.subLine.text = [NSString stringWithFormat: @"Guess: %@", secString];
    NSString *fileType = [[self.completeCall objectForKey:@"listOfFileTypes" ] objectAtIndex:indexPath.row];
    cell.picture.image = [UIImage imageNamed:@"card"];
    cell.picture.image = [cell.picture.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([fileType isEqualToString:@"image"]) {
        [cell.picture setTintColor:[UIColor colorWithRed:(34.0/255.0) green:(167.0/255.0) blue:(240.0/255.0) alpha:1.0]];
    }
    else{
        [cell.picture setTintColor:[UIColor colorWithRed:(155.0/255.0) green:(89.0/255.0) blue:(182.0/255.0) alpha:1.0]];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *fileType = [[self.completeCall objectForKey:@"listOfFileTypes" ] objectAtIndex:indexPath.row];
    if ([fileType isEqualToString:@"image"]) {
        self.transFile = [[self.completeCall objectForKey:@"listOfFiles"] objectAtIndex:indexPath.row];
        NSLog(@"File 1: %@", self.transFile);
        [self performSegueWithIdentifier:@"showImage" sender:self];
        
    }
    else{
        PFFile *videoFile = [[self.completeCall objectForKey:@"listOfFiles"] objectAtIndex:indexPath.row];
        NSURL *fileUrl = [[NSURL alloc] initWithString:videoFile.url];
        self.moviePlayer.contentURL = fileUrl;
        [self.moviePlayer prepareToPlay];
        //[self.moviePlayer thumbnailImageAtTime:0.f timeOption:MPMovieTimeOptionNearestKeyFrame];
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:NO];
        
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
