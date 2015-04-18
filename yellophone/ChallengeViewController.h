//
//  ChallengeViewController.h
//  yellophone
//
//  Created by Andrew Boryk on 7/24/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CameraViewController.h"
#import "voicemailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <StoreKit/StoreKit.h> 

@interface ChallengeViewController : UIViewController <UIAlertViewDelegate, CLLocationManagerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) IBOutlet UIButton *fifButton;
@property (strong, nonatomic) IBOutlet UIButton *tweButton;
@property (strong, nonatomic) IBOutlet UIButton *regButton;

@property CLLocationManager *manager;
@property CLGeocoder *geocoder;
@property CLPlacemark *placemark;
@property NSString *zip;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UILabel *cents99;
@property (strong, nonatomic) IBOutlet UILabel *cents199;

- (IBAction)continueWithPhrase:(id)sender;
- (IBAction)twentyFiveContinue:(id)sender;
- (IBAction)fifteenContinue:(id)sender;
- (IBAction)differentPhrase:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)submitGuess:(id)sender;
+ (NSString*)thisPhrase;
+ (NSNumber*)thisSize;
- (IBAction)reportButton:(id)sender;


@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView *disabledView;

extern NSString* phrase;
extern NSNumber* chainSize;

@property (strong, nonatomic) NSMutableArray *phraseArray;
@property (strong, nonatomic) IBOutlet UITextField *inputPhrase;
@property (strong, nonatomic) IBOutlet UITextField *inputGuess;

@end
