//
//  imageViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/26/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CameraViewController.h"
#import "completeTableController.h"
@interface imageViewController : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) PFObject *inboxCall;
@property (strong, nonatomic) NSString *isComplete;



+ (PFObject*)retrieveCall;
+ (void)resetCall;

extern PFObject* callObject;
@end
