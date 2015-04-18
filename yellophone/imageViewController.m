//
//  imageViewController.m
//  yellophone
//
//  Created by Andrew Boryk on 7/26/14.
//  Copyright (c) 2014 Andrew Boryk. All rights reserved.
//

#import "imageViewController.h"

@interface imageViewController ()

@end

PFObject* callObject = nil;

@implementation imageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    callObject = self.inboxCall;
    
    self.isComplete = [self.inboxCall objectForKey:@"currentRecipient"];
    if ([self.isComplete isEqualToString:@"Complete"]) {
        NSLog(@"File 4: %@", [completeTableController getFile]);
        PFFile *imageFile = [completeTableController getFile];
        NSLog(@"File 5: %@", imageFile);
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
        self.imageView.image = [UIImage imageWithData:imageData];
        }
    else{
        PFFile *imageFile = [self.inboxCall objectForKey:@"currentFile"];
        NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
        NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
        self.imageView.image = [UIImage imageWithData:imageData];

//        NSString *senderName = [self.inboxCall objectForKey:@"senderName"];
//        NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
//        self.navigationItem.title = title;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.isComplete isEqualToString:@"Complete"]) {
        [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(backOut) userInfo:nil repeats:NO];
    }
    
    
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    }
    
}

#pragma mark - Helper Methods
- (void)timeOut{
    [self performSegueWithIdentifier:@"endViewing" sender:self];
}

- (void)backOut{
    [self.navigationController popViewControllerAnimated:YES];
}



+ (PFObject*)retrieveCall
{
    return callObject;
}

+ (void)resetCall
{
    callObject = nil;
}

@end
