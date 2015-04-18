//
//  loginViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 6/10/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
@interface loginViewController : UIViewController <FBLoginViewDelegate>

- (IBAction)loginWithFacebook:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *theUsernameField;
@property (strong, nonatomic) IBOutlet UILabel *yellophoneTitle;
@property (strong, nonatomic) IBOutlet UILabel *usernameTitle;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)nextButton:(id)sender;
@end
