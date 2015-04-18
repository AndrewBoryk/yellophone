//
//  CameraViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/24/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ChallengeViewController.h"
#import "imageViewController.h"
#import "voicemailViewController.h"
#import "friendProfileViewController.h"

@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;

- (IBAction)cancelButton:(id)sender;
- (IBAction)sendButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *openButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *canButton;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSString *nextRecipient;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *recipients;
@property (nonatomic, strong) NSString *myPicUrl;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView *disabledView;
@property (nonatomic, strong) NSString *nextRecName;
-(void)uploadMessage;
-(void)reset;
-(UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;
@end
