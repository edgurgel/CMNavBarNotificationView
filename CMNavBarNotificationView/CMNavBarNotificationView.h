//
//  CMNavBarNotificationView.h
//  Moped
//
//  Modified by Tiago Bastos on 23/05/14.
//  Modified by Eduardo Pinho on 1/12/13.
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Codeminer42 All rights reserved.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kCMNavBarNotificationViewTapReceivedNotification;

typedef void (^CMNotificationSimpleAction)(id);

@protocol CMNavBarNotificationViewDelegate;

@class OBGradientView;

@interface CMNavBarNotificationView : UIView

@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UILabel *detailTextLabel;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, assign) id<CMNavBarNotificationViewDelegate> delegate;
@property(nonatomic, strong) UIView *contentView;

@property(nonatomic) NSTimeInterval duration;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                      detail:(NSString *)detail
                                       image:(UIImage *)image
                                 andDuration:(NSTimeInterval)duration;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                      detail:(NSString *)detail
                                 andDuration:(NSTimeInterval)duration;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                   andDetail:(NSString *)detail;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                      detail:(NSString *)detail
                                       image:(UIImage *)image
                                    duration:(NSTimeInterval)duration
                               andTouchBlock:(CMNotificationSimpleAction)block;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                      detail:(NSString *)detail
                                    duration:(NSTimeInterval)duration
                       supportedOrientations:(UIInterfaceOrientationMask)orientations
                               andTouchBlock:(CMNotificationSimpleAction)block;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                      detail:(NSString *)detail
                                    duration:(NSTimeInterval)duration
                               andTouchBlock:(CMNotificationSimpleAction)block;

+ (CMNavBarNotificationView *)notifyWithText:(NSString *)text
                                      detail:(NSString *)detail
                               andTouchBlock:(CMNotificationSimpleAction)block;

+ (void)setStatusBarStyle:(UIStatusBarStyle)barStyle;
+ (void)setHidesStatusBar:(BOOL)hidesStatusBar;
+ (void)setBackgroundImage:(UIImage *)image;
- (void)setBackgroundColor:(UIColor *)color;
- (void)setTextColor:(UIColor *)color;

@end

@protocol CMNavBarNotificationViewDelegate<NSObject>

@optional
- (void)didTapOnNotificationView:(CMNavBarNotificationView *)notificationView;

@end
