//
//  SearchContactsViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/19/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "SearchContactsViewController.h"

@interface SearchContactsViewController ()

@end

@implementation SearchContactsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contacts = [[NSMutableArray alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.currentUser = [PFUser currentUser];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else{
            //NSLog(@"Objects: %@", objects);
            self.contacts = objects;
//            NSString *temp;
//            for (PFUser *friend in objects) {
//                temp = friend.username;
//                NSLog(@"Contacts: %@", temp);
//                [self.contacts addObject:temp];
           // }
            //NSLog(@"Contacts: %@", self.contacts);
        }
    }];
    PFQuery *query2 = [self.friendsRelation query];
    [query2 orderByAscending:@"username"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else{
            self.friends = (NSMutableArray *)objects;
        }
    }];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [self.searchResults count];
}

- (SearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
    self.friendsRelation = [self.currentUser objectForKey:@"friendsRelation"];
    if (cell == nil)
    {
        cell = [[SearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row][@"username"];
     NSLog(@"Current User: %@", self.currentUser);
    if ([[self.currentUser objectForKey:@"friendsRequested"] containsObject:[user objectId]])
    {
        cell.accessoryView = [[ UIImageView alloc ]
                              initWithImage:[UIImage imageNamed:@"pending"]];
    }
    else{
        if ([self.currentUser.objectId isEqualToString: user.objectId]) {
            cell.accessoryView = [[ UIImageView alloc ]
                                  initWithImage:nil];
        }
        else if ([self isFriend:user]) {
            cell.accessoryView = [[ UIImageView alloc ]
                                    initWithImage:[UIImage imageNamed:@"remove"]];
        }
        else{
            cell.accessoryView = [[ UIImageView alloc ]
                                  initWithImage:[UIImage imageNamed:@"add_icon"]];
        }
        }
//    else{
//        cell.textLabel.text = [self.friends objectAtIndex:indexPath.row];
//    }
    if (![user objectForKey:@"currentProfileImage"]) {
        cell.imageView.image = [UIImage imageNamed:@"default_user.jpg"];
    }
    else{
        NSURL *pictureURL = [NSURL URLWithString:[user objectForKey:@"currentProfileImage"]];
        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
        cell.imageView.image = [UIImage imageWithData:imageData];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SearchTableViewCell *cell = (SearchTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.searchResults objectAtIndex:indexPath.row];
    if ([self.currentUser.objectId isEqualToString: user.objectId]) {
        cell.accessoryView = [[ UIImageView alloc ]
                              initWithImage:nil];
    }
    else if ([self isFriend:user]) {
        cell.accessoryView = [[ UIImageView alloc ]
                              initWithImage:[UIImage imageNamed:@"add_icon"]];
        for (PFUser *friend in self.friends) {
            if ([friend.objectId isEqualToString:user.objectId]) {
                [self.friends removeObject:friend];
                break;
            }
        }
        PFObject *freq = [PFObject objectWithClassName:@"fRequests"];
        [freq setObject:self.currentUser.objectId forKey:@"sender"];
        [freq setObject:user.objectId forKey:@"receiver"];
        [freq setObject:[NSNumber numberWithBool:NO] forKey:@"isOpen"];
        [freq setObject:@"Delete" forKey:@"reqType"];
        [freq setObject:@"Del" forKey:@"didAccept"];
        [freq saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"friend request sent");
        }];
        
        [self.friendsRelation removeObject:user];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Error Occured");
            }
        }];
        
    }
    else if (![[self.currentUser objectForKey:@"friendsRequested"] containsObject:user.objectId])
    {
//        PFQuery *fReqQuery = [PFQuery queryWithClassName:@"fRequests"];
//        [fReqQuery whereKey:@"sender" equalTo:user.objectId];
//        [fReqQuery whereKey:@"receiver" equalTo:[self.currentUser objectId]];
//        [fReqQuery whereKey:@"isOpen" equalTo:[NSNumber numberWithBool:YES]];
//        [fReqQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (error) {
//                NSLog(@"Error where Query");
//            }
//            else
//            {
//                if (objects) {
//                    PFObject *tempObj = [objects objectAtIndex:0];
//                    [tempObj setObject:[NSNumber numberWithBool:NO] forKey:@"isOpen"];
//                    [self.currentUser removeObject:user.objectId forKey:@"friendsRequested"];
//                    cell.accessoryView = [[ UIImageView alloc ]
//                                          initWithImage:[UIImage imageNamed:@"addUser.png"]];
//                    [self.currentUser saveInBackground];
//                    [tempObj saveInBackground];
//                }
//            }
//        }];
//        
//    }
        cell.accessoryView = [[ UIImageView alloc ]
                              initWithImage:[UIImage imageNamed:@"pending"]];
        PFObject *freq = [PFObject objectWithClassName:@"fRequests"];
        [freq setObject:self.currentUser.objectId forKey:@"sender"];
        [freq setObject:user.objectId forKey:@"receiver"];
        [freq setObject:[NSNumber numberWithBool:YES] forKey:@"isOpen"];
        [freq setObject:@"Add" forKey:@"reqType"];
        [self.currentUser addObject:user.objectId forKey:@"friendsRequested"];
        [freq saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"friend request sent");
            
        }];
        PFQuery *pushQuery = [PFInstallation query];
        NSLog(@"User.ObjectId: %@", user.objectId);
        [pushQuery whereKey:@"user" equalTo:user.objectId];
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        NSString *pString = [NSString stringWithFormat:@"%@ has sent you a friend request!", [self.currentUser username]];
        [push setMessage:pString];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
            else
            {
                NSLog(@"Sent Push");
            }
        }];
//        [self.friends addObject:user];
//        [self.friendsRelation addObject:user];
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    [tableView reloadData];
    
    NSLog(@"Friends: %@", self.friends);
}

-(void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username CONTAINS[cd]  %@)", searchText];
    self.searchResults = [self.contacts filteredArrayUsingPredicate:predicate];
    
    
}

- (BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    //[self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark - Helper Methods
- (BOOL)isFriend:(PFUser *)user{
    for (PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}
@end
