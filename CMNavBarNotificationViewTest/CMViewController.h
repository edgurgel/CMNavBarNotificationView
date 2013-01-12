//
//  CMViewController.h
//  CMNavBarNotificationViewTest
//
//  Modified by Eduardo Pinho on 1/12/13.
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Codeminer42 All rights reserved.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMNavBarNotificationView.h"

@interface CMViewController : UIViewController<CMNavBarNotificationViewDelegate>

-(IBAction) enqueueNotification1:(id)sender;
-(IBAction) enqueueNotification2:(id)sender;
-(IBAction) enqueueNotification3:(id)sender;

@end
