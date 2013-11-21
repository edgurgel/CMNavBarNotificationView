//
//  CMNavBarNotificationView.m
//  Moped
//
//  Modified by Eduardo Pinho on 1/12/13.
//  Created by Engin Kurutepe on 1/4/13.
//  Copyright (c) 2013 Codeminer42 All rights reserved.
//  Copyright (c) 2013 Moped Inc. All rights reserved.
//

#import "CMNavBarNotificationView.h"
#import "OBGradientView.h"

#define kCMNavBarNotificationHeight    44.0f
#define kCMNavBarNotificationIPadWidth 480.0f
#define RADIANS(deg) ((deg) * M_PI / 180.0f)

NSString *kCMNavBarNotificationViewTapReceivedNotification = @"kCMNavBarNotificationViewTapReceivedNotification";

#pragma mark CMNavBarNotificationWindow

@interface CMNavBarNotificationWindow : UIWindow

@property (nonatomic, strong) NSMutableArray *notificationQueue;
@property (nonatomic, strong) UIView *currentNotification;

@end

@implementation CMNavBarNotificationWindow

+ (CGRect) notificationRectWithOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat statusBarHeight = 20.0f;
    if ([UIApplication sharedApplication].statusBarHidden)
        statusBarHeight = 0.0f;
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        
        return CGRectMake(0.0f, statusBarHeight, [UIScreen mainScreen].bounds.size.height, kCMNavBarNotificationHeight);
    }
    
    return CGRectMake(0.0f, statusBarHeight, [UIScreen mainScreen].bounds.size.width, kCMNavBarNotificationHeight);
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor clearColor];
        _notificationQueue = [[NSMutableArray alloc] initWithCapacity:4];
        
        UIView *topHalfBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame),
                                                                            CGRectGetMinY(frame),
                                                                            CGRectGetWidth(frame),
                                                                            0.5 * CGRectGetHeight(frame))];
        
        topHalfBlackView.backgroundColor = [UIColor blackColor];
        topHalfBlackView.layer.zPosition = -100;
        topHalfBlackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:topHalfBlackView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [self rotateStatusBarWithFrame:frame andOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    
    return self;
}

- (void) willRotateScreen:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    CGRect notificationBarFrame = [CMNavBarNotificationWindow notificationRectWithOrientation:orientation];
    
    if (self.hidden)
    {
        [self rotateStatusBarWithFrame:notificationBarFrame andOrientation:orientation];
    }
    else
    {
        [self rotateStatusBarAnimatedWithFrame:notificationBarFrame andOrientation:orientation];
    }
}

- (void) rotateStatusBarAnimatedWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self rotateStatusBarWithFrame:frame andOrientation:orientation];
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              self.alpha = 1;
                                          }];
                     }];
}


- (void) rotateStatusBarWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = UIDeviceOrientationIsPortrait(orientation);
    CGFloat statusBarHeight = 20.0f;
    if ([UIApplication sharedApplication].statusBarHidden)
        statusBarHeight = 0.0f;
    if (isPortrait)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.width = kCMNavBarNotificationIPadWidth;
        }
        
        if (orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            frame.origin.y = [UIScreen mainScreen].bounds.size.height - kCMNavBarNotificationHeight - statusBarHeight;
            self.transform = CGAffineTransformMakeRotation(RADIANS(180.0f));
        }
        else
        {
            self.transform = CGAffineTransformIdentity;
        }
    }
    else
    {
        frame.size.height = frame.size.width;
        frame.size.width  = kCMNavBarNotificationHeight;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            frame.size.height = kCMNavBarNotificationIPadWidth;
        }
        
        if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width - statusBarHeight;
            self.transform = CGAffineTransformMakeRotation(RADIANS(90.0f));
        }
        else
        {
            frame.origin.x = frame.origin.x + statusBarHeight;
            self.transform = CGAffineTransformMakeRotation(RADIANS(-90.0f));
        }
    }
    
    self.frame = frame;
    CGPoint center = self.center;
    if (isPortrait)
    {
        center.x = CGRectGetMidX([UIScreen mainScreen].bounds);
    }
    else
    {
        center.y = CGRectGetMidY([UIScreen mainScreen].bounds);
    }
    self.center = center;
}

@end


static CMNavBarNotificationWindow * __notificationWindow = nil;
static CGFloat const __imagePadding = 8.0f;
static UIImage * __backgroundImage = nil;

#pragma mark -
#pragma mark CMNavBarNotificationView

@interface CMNavBarNotificationView ()

@property (nonatomic, copy) CMNotificationSimpleAction tapBlock;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

+ (void) showNextNotification;
+ (UIImage*) screenImageWithRect:(CGRect)rect;

@end

@implementation CMNavBarNotificationView

+ (void)setBackgroundImage:(UIImage *)image
{
    __backgroundImage = image;
}

- (void) setBackgroundColor:(UIColor *)color
{
    UIView *contentView = _contentView;
    if ([contentView isKindOfClass:[OBGradientView class]]) {
        OBGradientView *gradientView = (OBGradientView *) _contentView;
        gradientView.colors = @[(id)[color CGColor],
                                (id)[color CGColor]];
    } else {
        [contentView setBackgroundColor:color];
    }
}

- (void) dealloc
{
    _delegate = nil;
    [self removeGestureRecognizer:_tapGestureRecognizer];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat notificationWidth = [CMNavBarNotificationWindow notificationRectWithOrientation:orientation].size.width;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        if (__backgroundImage) {
            
            _contentView = [[UIView alloc] initWithFrame:self.bounds];
            [_contentView setBackgroundColor:[UIColor colorWithPatternImage:__backgroundImage]];
            
        } else {
            
            OBGradientView *gradientView = [[OBGradientView alloc] initWithFrame:self.bounds];
            gradientView.colors = @[(id)[[UIColor colorWithWhite:0.99f alpha:1.0f] CGColor],
                                    (id)[[UIColor colorWithWhite:0.9f  alpha:1.0f] CGColor]];
            _contentView = gradientView;
            
        }
        
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _contentView.layer.cornerRadius = 0.0f;
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 4.0f;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
        UIFont *textFont = [UIFont boldSystemFontOfSize:14.0f];
        CGRect textFrame = CGRectMake(__imagePadding + CGRectGetMaxX(_imageView.frame),
                                      2,
                                      notificationWidth - __imagePadding * 2 - CGRectGetMaxX(_imageView.frame),
                                      textFont.lineHeight);
        _textLabel = [[UILabel alloc] initWithFrame:textFrame];
        _textLabel.font = textFont;
        _textLabel.numberOfLines = 1;
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _textLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_textLabel];
        
        UIFont *detailFont = [UIFont systemFontOfSize:13.0f];
        CGRect detailFrame = CGRectMake(CGRectGetMinX(textFrame),
                                        CGRectGetMaxY(textFrame),
                                        notificationWidth - __imagePadding * 2 - CGRectGetMaxX(_imageView.frame),
                                        detailFont.lineHeight);
        
        _detailTextLabel = [[UILabel alloc] initWithFrame:detailFrame];
        _detailTextLabel.font = detailFont;
        _detailTextLabel.numberOfLines = 1;
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:_detailTextLabel];
    }
    
    return self;
}

+ (CMNavBarNotificationView *) notifyWithText:(NSString*)text
                              andDetail:(NSString*)detail
{
    return [self notifyWithText:text
                         detail:detail
                    andDuration:2.0f];
}

+ (CMNavBarNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                            andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text
                         detail:detail
                          image:nil
                    andDuration:duration];
}

+ (CMNavBarNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                            andDuration:(NSTimeInterval)duration
{
    return [self notifyWithText:text
                         detail:detail
                          image:image
                       duration:duration
                  andTouchBlock:nil];
}

+ (CMNavBarNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                               duration:(NSTimeInterval)duration
                          andTouchBlock:(CMNotificationSimpleAction)block
{
    return [self notifyWithText:text
                         detail:detail
                          image:nil
                       duration:duration
                  andTouchBlock:block];
}

+ (CMNavBarNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                          andTouchBlock:(CMNotificationSimpleAction)block
{
    return [self notifyWithText:text
                         detail:detail
                          image:nil
                       duration:2.0
                  andTouchBlock:block];
}

+ (CMNavBarNotificationView *) notifyWithText:(NSString*)text
                                 detail:(NSString*)detail
                                  image:(UIImage*)image
                               duration:(NSTimeInterval)duration
                          andTouchBlock:(CMNotificationSimpleAction)block
{
    if (__notificationWindow == nil)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect frame = [CMNavBarNotificationWindow notificationRectWithOrientation:orientation];
        __notificationWindow = [[CMNavBarNotificationWindow alloc] initWithFrame:frame];
        __notificationWindow.hidden = NO;
    }
    CGRect bounds = __notificationWindow.bounds;
    CMNavBarNotificationView * notification = [[CMNavBarNotificationView alloc] initWithFrame:bounds];
    
    notification.textLabel.text = text;
    notification.detailTextLabel.text = detail;
    notification.imageView.image = image;
    notification.duration = duration;
    notification.tapBlock = block;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:notification
                                                                         action:@selector(handleTap:)];
    notification.tapGestureRecognizer = gr;
    [notification addGestureRecognizer:gr];
    
    [__notificationWindow.notificationQueue addObject:notification];
    
    if (__notificationWindow.currentNotification == nil)
    {
        [self showNextNotification];
    }
    
    return notification;
}

- (void) handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_tapBlock != nil)
    {
        _tapBlock(self);
    }
    
    if ([_delegate respondsToSelector:@selector(didTapOnNotificationView:)])
    {
        [_delegate didTapOnNotificationView:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCMNavBarNotificationViewTapReceivedNotification
                                                        object:self];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[self class]
                                             selector:@selector(showNextNotification)
                                               object:nil];
    
    [CMNavBarNotificationView showNextNotification];
}

+ (void) showNextNotification
{
    UIView *viewToRotateOut = nil;
    CGRect frame = __notificationWindow.frame;
    UIImage *screenshot = [self screenImageWithRect:frame];
    
    if (__notificationWindow.currentNotification)
    {
        viewToRotateOut = __notificationWindow.currentNotification;
    }
    else
    {
        viewToRotateOut = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateOut).image = screenshot;
        [__notificationWindow addSubview:viewToRotateOut];
        __notificationWindow.hidden = NO;
    }
    
    UIView *viewToRotateIn = nil;
    
    if ([__notificationWindow.notificationQueue count] > 0)
    {
        viewToRotateIn = __notificationWindow.notificationQueue[0];
    }
    else
    {
        viewToRotateIn = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        ((UIImageView *)viewToRotateIn).image = screenshot;
    }
    
    viewToRotateIn.layer.anchorPointZ = 11.547f;
    viewToRotateIn.layer.doubleSided = NO;
    viewToRotateIn.layer.zPosition = 2;
    
    CATransform3D viewInStartTransform = CATransform3DMakeRotation(RADIANS(-120), 1.0, 0.0, 0.0);
    viewInStartTransform.m34 = -1.0 / 200.0;
    
    viewToRotateOut.layer.anchorPointZ = 11.547f;
    viewToRotateOut.layer.doubleSided = NO;
    viewToRotateOut.layer.zPosition = 2;
    
    CATransform3D viewOutEndTransform = CATransform3DMakeRotation(RADIANS(120), 1.0, 0.0, 0.0);
    viewOutEndTransform.m34 = -1.0 / 200.0;
    
    [__notificationWindow addSubview:viewToRotateIn];    
    __notificationWindow.backgroundColor = [UIColor blackColor];
    
    viewToRotateIn.layer.transform = viewInStartTransform;
    
    if ([viewToRotateIn isKindOfClass:[CMNavBarNotificationView class]] )
    {
        UIImageView *bgImage = [[UIImageView alloc] initWithFrame:__notificationWindow.bounds];
        bgImage.image = screenshot;
        [viewToRotateIn addSubview:bgImage];
        [viewToRotateIn sendSubviewToBack:bgImage];
        __notificationWindow.currentNotification = viewToRotateIn;
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         viewToRotateIn.layer.transform = CATransform3DIdentity;
                         viewToRotateOut.layer.transform = viewOutEndTransform;
                     }
                     completion:^(BOOL finished) {
                         [viewToRotateOut removeFromSuperview];
                         [__notificationWindow.notificationQueue removeObject:viewToRotateOut];
                         if ([viewToRotateIn isKindOfClass:[CMNavBarNotificationView class]])
                         {
                             CMNavBarNotificationView *notification = (CMNavBarNotificationView*)viewToRotateIn;
                             [self performSelector:@selector(showNextNotification)
                                        withObject:nil
                                        afterDelay:notification.duration];
                             
                             __notificationWindow.currentNotification = notification;
                             [__notificationWindow.notificationQueue removeObject:notification];
                         }
                         else
                         {
                             [viewToRotateIn removeFromSuperview];
                             __notificationWindow.hidden = YES;
                             __notificationWindow.currentNotification = nil;
                         }
                         
                          __notificationWindow.backgroundColor = [UIColor clearColor];
                     }];
}

+ (UIImage *) screenImageWithRect:(CGRect)rect
{
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale
                      , rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef
                                                     scale:screenshot.scale
                                               orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    
    return [[UIImage alloc] initWithCGImage:croppedScreenshot.CGImage
                                      scale:croppedScreenshot.scale
                                orientation:imageOrientation];
}

@end
