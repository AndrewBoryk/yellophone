//
//  ChallengeViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/24/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "ChallengeViewController.h"

@interface ChallengeViewController ()
{
    
}

@end
NSString* phrase = nil;
NSNumber* chainSize = nil;

@implementation ChallengeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.phraseArray = [[NSMutableArray alloc] initWithObjects:@"Snap Crackle Pop", @"Too Fast, Too Furious", @"Gnome", @"Can't Touch This", @"Buttscratcher", @"Floppy Disk", @"Spider Web", @"Toilet Paper", @"Shmoney Dance", @"Monster Mash", @"New York", @"Valley Girls", @"Halloween", @"Thanksgiving", @"Cookie Jar", @"Romeo and Juliet", @"Ryan Lewis", @"Smelly Socks", @"Stewie", @"Swimming", @"Basketball", @"Baseball", @"Football", @"Hockey", @"Golf", @"Balls", @"Dog", @"Cat", @"Shake it Off", @"Shoe Game", @"Ball is Life", @"Swag", @"YOLO", @"Water", @"Mandals", @"Makeup", @"Hipster", @"Bacon", @"Autumn", @"Sweater Weather", nil];
    NSLog(@"New Array: %@", self.phraseArray);
    [_fifButton.layer setBorderWidth:0.25f];
    [_fifButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_tweButton.layer setBorderWidth:0.25f];
    [_tweButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_regButton.layer setBorderWidth:0.25f];
    [_regButton.layer setBorderColor:[UIColor blackColor].CGColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.manager = [[CLLocationManager alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    
//    if ([SKPaymentQueue canMakePayments]) {
//        SKProductsRequest *productsReq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"15Chain", @"25chain", nil ]];
//        productsReq.delegate = self;
//        [productsReq start];
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.currentUser = [PFUser currentUser];
    NSLog(@"fifChains: %@", [self.currentUser objectForKey:@"fifChains"]);
    NSLog(@"tweChains: %@", [self.currentUser objectForKey:@"tweChains"]);
    if ([self.currentUser objectForKey:@"fifChains"] && ([[self.currentUser objectForKey:@"fifChains"] intValue] > 0)) {
        self.cents99.hidden = YES;
    }
    else{
        self.cents99.hidden = NO;
    }
    if ([self.currentUser objectForKey:@"tweChains"] && ([[self.currentUser objectForKey:@"tweChains"] intValue] > 0)) {
        self.cents199.hidden = YES;
    }
    else{
        self.cents199.hidden = NO;
    }
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(102.0/255.0) green:(51.0/255.0) blue:(153.0/255.0) alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"New Game";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Location Manager
//    self.manager.delegate = self;
//    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
//    if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self.manager requestWhenInUseAuthorization];
//    }
//    [self.manager startMonitoringSignificantLocationChanges];
//    [self.manager startUpdatingLocation];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
//    [self.manager stopMonitoringSignificantLocationChanges];
//    [self.manager stopUpdatingLocation];
}
- (IBAction)continueWithPhrase:(id)sender
{
    if(![self.inputPhrase.text isEqualToString:nil] && ![self.inputPhrase.text isEqualToString:@" "] && self.inputPhrase.text.length != 0)
    {
        phrase = self.inputPhrase.text;
        chainSize = [NSNumber numberWithInt:7];
        NSLog(@"Phrase: %@", phrase);
        [self performSegueWithIdentifier:@"continueToCapture" sender:self];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure to enter a valid phrase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)differentPhrase:(id)sender
{
    NSUInteger randomIndex = arc4random() % [self.phraseArray count];
    self.inputPhrase.text = [self.phraseArray objectAtIndex:randomIndex];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(void)dismissKeyboard {
    [_inputGuess resignFirstResponder];
    [_inputPhrase resignFirstResponder];
}

- (IBAction)submitGuess:(id)sender
{
    if(![self.inputGuess.text isEqualToString:nil] && ![self.inputGuess.text isEqualToString:@" "] && self.inputGuess.text.length != 0)
    {
        phrase = self.inputGuess.text;
        NSLog(@"Phrase: %@", phrase);
        [self performSegueWithIdentifier:@"goToCamera" sender:self];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure to enter a valid phrase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.inputPhrase isFirstResponder] && [touch view] != self.inputPhrase) {
        [self.inputPhrase resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToCamera"])
    {
        [self endWaitingAndResume];
    }
}

-(void)disableForWaiting
{
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    _disabledView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 560.0)];
    [_disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2]];
    [self.view addSubview:_disabledView];
    _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.color = [UIColor colorWithRed:(102.0/255.0) green:(51.0/255.0) blue:(153.0/255.0) alpha:1.0];
    _activityView.center=self.view.center;
    [_activityView startAnimating];
    [_disabledView addSubview:_activityView];
}

-(void) endWaitingAndResume
{
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
    [_disabledView removeFromSuperview];
    //[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

+ (NSString*)thisPhrase{
    return phrase;
}

+ (NSNumber*)thisSize{
    return chainSize;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Harassment"] || [title isEqualToString:@"Sexual Content"])
    {
        PFObject *reportedCall = [voicemailViewController retrievCall];
        PFObject *callReport = [PFObject objectWithClassName:@"Reports"];
        NSLog(@"Reported Call: %@", reportedCall);
        [callReport setObject:[NSNumber numberWithBool:false] forKey:@"closed"];
        [callReport setObject:[reportedCall objectForKey:@"currentFile"] forKey:@"reportedFile"];
        [callReport setObject:[reportedCall objectForKey:@"senderId"] forKey:@"reportedUserID"];
        [callReport setObject:[reportedCall objectForKey:@"senderName"] forKey:@"reportedUsername"];
        [callReport setObject:[reportedCall objectForKey:@"currentRecipient"] forKey:@"reporteeID"];
        [callReport setObject:[reportedCall objectForKey:@"recName"] forKey:@"reporteeUsername"];
        [callReport setObject:[reportedCall objectId] forKey:@"gameId"];
        if([title isEqualToString:@"Harassment"])
        {
            [callReport setObject:@"Harrassment" forKey:@"reason"];
            NSLog(@"Button Harassment was selected.");
        }
        else if([title isEqualToString:@"Sexual Content"])
        {
            [callReport setObject:@"Sexual Content" forKey:@"reason"];
            NSLog(@"Button Sexual Content was selected.");
        }
        else
        {
            [callReport setObject:@"Error" forKey:@"reason"];
            NSLog(@"An error has occurred");
        }
        [reportedCall setObject:@"Reported" forKey:@"recName"];
        [reportedCall setObject:@"Reported" forKey:@"currentRecipient"];
        [reportedCall saveInBackground];
        [callReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error)
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
    else
    {
        
    }
}

- (IBAction)reportButton:(id)sender {
    UIAlertView* message = [[UIAlertView alloc]
                            initWithTitle: @"Report Call" message: @"Are you sure you want to report this call? If so, what are you reporting it for?" delegate: self
                            cancelButtonTitle: @"Cancel" otherButtonTitles: @"Harassment", @"Sexual Content", nil];
    
    [message show];
}

- (IBAction)twentyFiveContinue:(id)sender
{
    
    if(![self.inputPhrase.text isEqualToString:nil] && ![self.inputPhrase.text isEqualToString:@" "] && self.inputPhrase.text.length != 0)
    {
        if (![self.currentUser objectForKey:@"tweChains"] || [[self.currentUser objectForKey:@"tweChains"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            phrase = self.inputPhrase.text;
            chainSize = [NSNumber numberWithInt:25];
            NSLog(@"User selected to purchase");
            if([SKPaymentQueue canMakePayments]){
                NSLog(@"User can make payments");
                
                SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"25Chain"]];
                productsRequest.delegate = self;
                [productsRequest start];
                
            }
            else{
                NSLog(@"User cannot make payments due to parental controls");
                //this is called the user cannot make payments, most likely due to parental controls
            }
            
        }
        else{
            phrase = self.inputPhrase.text;
             chainSize = [NSNumber numberWithInt:25];
            [self performSegueWithIdentifier:@"continueToCapture" sender:self];
        }
        NSLog(@"Phrase: %@", phrase);
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure to enter a valid phrase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)fifteenContinue:(id)sender
{
    if(![self.inputPhrase.text isEqualToString:nil] && ![self.inputPhrase.text isEqualToString:@" "] && self.inputPhrase.text.length != 0)
    {
        NSLog(@"FifChains: %@", [self.currentUser objectForKey:@"fifChains"]);
        if (![self.currentUser objectForKey:@"fifChains"] || ([[self.currentUser objectForKey:@"fifChains"] intValue] == 0)) {
            phrase = self.inputPhrase.text;
            chainSize = [NSNumber numberWithInt:15];
            NSLog(@"User selected to purchase");
            
            if([SKPaymentQueue canMakePayments]){
                NSLog(@"User can make payments");
                
                SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"15Chain"]];
                productsRequest.delegate = self;
                [productsRequest start];
                
            }
            else{
                NSLog(@"User cannot make payments due to parental controls");
                //this is called the user cannot make payments, most likely due to parental controls
            }
        }
        else{
            phrase = self.inputPhrase.text;
            chainSize = [NSNumber numberWithInt:15];
            [self performSegueWithIdentifier:@"continueToCapture" sender:self];
        }
        NSLog(@"Phrase: %@", phrase);
        //[self disableForWaiting];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure to enter a valid phrase." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self didPurchase:chainSize];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self didPurchase:chainSize]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)didPurchase:(NSNumber*)value{
    
    [self performSegueWithIdentifier:@"continueToCapture" sender:self];
    if (value == [NSNumber numberWithInt:15]) {
        if (![self.currentUser objectForKey:@"fifChains"]) {
            [self.currentUser setObject:[NSNumber numberWithInt:1] forKey:@"fifChains"];
        }
        else
        {
            NSNumber *numberAdd = [NSNumber numberWithInt:([[self.currentUser objectForKey:@"fifChains"] intValue] + 1)];
            [self.currentUser setObject:numberAdd forKey:@"fifChains"];
        }
    }
    else if (value == [NSNumber numberWithInt:25]) {
        if (![self.currentUser objectForKey:@"tweChains"]) {
            [self.currentUser setObject:[NSNumber numberWithInt:1] forKey:@"tweChains"];
        }
        else
        {
            NSNumber *numberAdd = [NSNumber numberWithInt:([[self.currentUser objectForKey:@"tweChains"] intValue] + 1)];
            [self.currentUser setObject:numberAdd forKey:@"tweChains"];
        }
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Did add");
        }
    }];
    
}

#pragma mark CLLocationManagerDelegate methods


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation && !self.zip) {
        [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && placemarks.count > 0) {
                self.placemark = [placemarks lastObject];
                self.zip = self.placemark.postalCode;
                NSLog(@"Zipcode: %@", self.zip);
                PFQuery *zipQuery = [PFQuery queryWithClassName:@"zipAds"];
                [zipQuery whereKey:@"zipcode" equalTo:self.zip];
                [zipQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error && objects > 0) {
                        for (int i = 0; i < objects.count; i++) {
                            [self.phraseArray insertObject:[[objects objectAtIndex:i] objectForKey:@"word"] atIndex:i];
                        }
                        NSLog(@"New Array: %@", self.phraseArray);
                    }
                }];
            }
            else
            {
                NSLog(@"Error: %@", error.debugDescription);
            }
        }];
    }
}
@end
