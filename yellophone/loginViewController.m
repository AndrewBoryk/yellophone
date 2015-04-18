//
//  loginViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 6/10/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "loginViewController.h"
#import <Parse/Parse.h>

@interface loginViewController ()

@end

@implementation loginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
//
- (IBAction)nextButton:(id)sender
{
    NSString *username = [self.theUsernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([username length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you fill out all fields!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    else if ([username length] > 16) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your username is too long!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    else if ([[username lowercaseString] containsString:@"pussy"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"That is an invalid username. Please choose another." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    else{
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:username];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"A user with that username already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            else
            {
                [PFUser currentUser].username = username;
                [[PFUser currentUser] setObject:[NSNumber numberWithBool:true] forKey:@"usernameAdded"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"Signup Done");
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            }
        }];
    }
}


//
//- (IBAction)login:(id)sender {
//    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    
//    if ([username length] == 0 || [password length] == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you fill out all fields!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//    }
//    
//    else{
//        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
//            if (!error) {
//                
//                PFInstallation *installation = [PFInstallation currentInstallation];
//                installation[@"user"] = user.objectId;
//                [installation saveInBackground];
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            } else {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alertView show];
//            }
//        }];
//    }
//}

- (IBAction)loginWithFacebook:(id)sender {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"public_profile", @"email", @"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = user.objectId;
            [installation saveInBackground];
            [self userIdSave];
            [self performSegueWithIdentifier:@"userAddedName" sender:self];
        }
        else {
            if ([[user objectForKey:@"strikes"] isEqualToNumber: [NSNumber numberWithInt:3]])
            {
                UIAlertView* message = [[UIAlertView alloc]
                                        initWithTitle: @"Blocked" message: @"Due to investigation on multiple reports on your account, you have been blocked. You will be denied access to your account until further notice." delegate: self
                                        cancelButtonTitle: @"Okay" otherButtonTitles: nil];
                
                [message show];
            }
            else{
                NSLog(@"User with facebook logged in!");
                PFInstallation *installation = [PFInstallation currentInstallation];
                installation[@"user"] = user.objectId;
                [installation saveInBackground];
                [self userIdSave];
                //[[PFUser currentUser] refresh];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }];
}

-(void)userIdSave
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Store the current user's Facebook ID on the user
            [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                     forKey:@"fbId"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(void)dismissKeyboard {
    [_theUsernameField resignFirstResponder];
}

@end
