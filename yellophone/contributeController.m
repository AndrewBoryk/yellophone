//
//  contributeController.m
//  yellophone
//
//  Created by Andrew Boryk on 10/16/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "contributeController.h"

@interface contributeController ()

@end

@implementation contributeController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrayOfImages = [NSArray arrayWithObjects:@"voicemail_tab", @"friends_tab", @"alternate_tab", @"settingsIcon", @"defaultUser", @"refresh", @"random", @"newGame", @"card", nil];
    arrayOfNames = [NSArray arrayWithObjects: @"Telephone designed by Charles Riccardi", @"Friends designed by Moriah Rich", @"Profile designed by Alex Auda Samora", @"Gear designed by Housin Aziz", @"User designed by Nemanja Ivanovic", @"Refresh designed by Luboš Volkov", @"Dice designed by Chris Dawson", @"Plus designed by Cengiz SARI", @"Red Card designed by Erik Wagner", nil];
    arrayOfLinks = [NSArray arrayWithObjects: @"charles", @"2moriah", @"razerk", @"haplanet", @"NemanjaIvanovic", @"Luboš%20Volkov", @"tallhat", @"cengizsari", @"ew1127", nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayOfImages count];
}

- (completeCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    completeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.picture.image = [UIImage imageNamed:[arrayOfImages objectAtIndex:indexPath.row]];
    cell.firstLine.text = [arrayOfNames objectAtIndex:indexPath.row];
    cell.subLine.text = @"from the Noun Project";
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://www.thenounproject.com/%@", [arrayOfLinks objectAtIndex:indexPath.row]]]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
