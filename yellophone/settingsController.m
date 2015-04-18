//
//  settingsController.m
//  yellophone
//
//  Created by Andrew Boryk on 10/8/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "settingsController.h"

@interface settingsController ()

@end

@implementation settingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

- (IBAction)logOutUserHere:(id)sender
{
    [PFUser logOut];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    [self performSegueWithIdentifier:@"backToLogin" sender:self];
}

- (IBAction)advertiseRequest:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObject:@"contactyellophone@gmail.com"];
        [controller setSubject:@"Advertising Inquiry"];
        [controller setToRecipients:toRecipients];
        [controller setMessageBody:@"Leave information here about the organization you represent, and why you might be looking to advertise through our application." isHTML:NO];
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            NSLog(@"Error");
        }
    }
    else
    {
        UIAlertView* message = [[UIAlertView alloc]
                                initWithTitle: @"Sorry" message: @"This device does not support sending emails. Please contact us at: contactyellophone@gmail.com" delegate: self
                                cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [message show];
    }
}

- (IBAction)contactUs:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObject:@"contactyellophone@gmail.com"];
        [controller setSubject:@"Message Subject"];
        [controller setToRecipients:toRecipients];
        [controller setMessageBody:@"Tell us what you think about the app! All constructive criticism is appreciated." isHTML:NO];
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            NSLog(@"Error");
        }
    }
    else
    {
        UIAlertView* message = [[UIAlertView alloc]
                                initWithTitle: @"Sorry" message: @"This device does not support sending emails. Please contact us at: contactyellophone@gmail.com" delegate: self
                                cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [message show];
    }
}

- (IBAction)workRequest:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObject:@"contactyellophone@gmail.com"];
        [controller setSubject:@"Message Subject"];
        [controller setToRecipients:toRecipients];
        [controller setMessageBody:@"Looking to join the Yellophone team? We are looking for motivated business individuals, graphic designers, web developers, android developers, iOS developers, and much more! Let us know a little about yourself here, and we'll get back to your with a little about us. Thank you!" isHTML:NO];
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            NSLog(@"Error");
        }
    }
    else
    {
        UIAlertView* message = [[UIAlertView alloc]
                                initWithTitle: @"Sorry" message: @"This device does not support sending emails. Please contact us at: contactyellophone@gmail.com" delegate: self
                                cancelButtonTitle: @"Okay" otherButtonTitles: nil];
        [message show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
