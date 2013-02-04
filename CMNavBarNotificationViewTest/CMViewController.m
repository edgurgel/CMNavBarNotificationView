//
//  CMViewController.m
//  CMNavBarNotificationViewTest
//
//  Modified by Eduardo Pinho on 1/12/13.
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Codeminer42 All rights reserved.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "CMViewController.h"

@interface CMViewController ()

@end

@implementation CMViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tapReceivedNotificationHandler:)
                                                 name:kCMNavBarNotificationViewTapReceivedNotification
                                               object:nil];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction) enqueueNotification1:(id)sender
{
    CMNavBarNotificationView *notification = [CMNavBarNotificationView notifyWithText:@"Hello World!" andDetail:@"This is a test"];
    notification.delegate = self;
    [notification setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]];
}

-(IBAction) enqueueNotification2:(id)sender
{

    [CMNavBarNotificationView setBackgroundImage:[UIImage imageNamed:@"bg_navbar"]];
    CMNavBarNotificationView *notification = [CMNavBarNotificationView notifyWithText:@"Moped Dog:"
                                                                               detail:@"I have no idea what I'm doing..."
                                                                                image:[UIImage imageNamed:@"mopedDog.jpeg"]
                                                                          andDuration:5.0];
    notification.textLabel.textColor = [UIColor redColor];
    notification.textLabel.backgroundColor = [UIColor clearColor];
    notification.detailTextLabel.textColor = [UIColor whiteColor];
    notification.detailTextLabel.backgroundColor = [UIColor clearColor];
}

-(IBAction) enqueueNotification3:(id)sender
{
    [CMNavBarNotificationView notifyWithText:@"Grumpy wizards"
                                detail:@"make a toxic brew for the jovial queen"
                         andTouchBlock:^(CMNavBarNotificationView *notificationView) {
                             NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
    }];

}

- (void)didTapOnNotificationView:(CMNavBarNotificationView *)notificationView
{
    NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
}

- (void)tapReceivedNotificationHandler:(NSNotification *)notice
{
    CMNavBarNotificationView *notificationView = (CMNavBarNotificationView *)notice.object;
    if ([notificationView isKindOfClass:[CMNavBarNotificationView class]])
    {
        NSLog( @"Received touch for notification with text: %@", ((CMNavBarNotificationView *)notice.object).textLabel.text );
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
