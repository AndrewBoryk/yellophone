//
//  settingsController.h
//  yellophone
//
//  Created by Andrew Boryk on 10/8/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

@interface settingsController : UIViewController
- (IBAction)logOutUserHere:(id)sender;
- (IBAction)advertiseRequest:(id)sender;
- (IBAction)contactUs:(id)sender;
- (IBAction)workRequest:(id)sender;


@end
