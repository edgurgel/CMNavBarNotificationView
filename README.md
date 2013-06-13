CMNavBarNotificationView
==================

An in-app notification view above the navigation bar "TOTALLY" based on [MPNotificationView](https://github.com/Moped/MPNotificationView). Compatible with iOS 4.3 and above.

###Features:

- Animation and layout similar to iOS 6 notifications
- Provides two `UILabels` and an `UIImageView`
- Simple API
- Enqueues multiple notifications and shows them with a default duration of 2 seconds.

###Live:

![Example](http://dl.dropboxusercontent.com/u/1128017/cmnavbar.gif)

###Usage:

Simply use the following call to show a message and related detail text:

```objective-c
[CMNavBarNotificationView notifyWithText:@"Grumpy wizards" andDetail:@"make a toxic brew"];`
````

Or use the following call to add a thumbnail image and customize duration:

```objective-c
[CMNavBarNotificationView notifyWithText:@"Moped Dog:"
                        detail:@"I have no idea what I'm doing..."
                         image:[UIImage imageNamed:@"mopedDog.jpeg"]
                   andDuration:5.0];
````

Or if you need to load the image async using `AFNetworking`:

```objective-c
CMNavBarNotificationView* notification =
[CMNavBarNotificationView notifyWithText:@"Moped Dog:"
                        detail:@"I have no idea what I'm doing..."
                         image:nil
                   andDuration:5.0];

//From UIImage+AFNetworking.h:
[notification.imageView setImageWithURL:[NSURL URLWithString:@"https://dl.dropbox.com/u/361895/mopeddog.png"]];

````

If you would like to set a background image:

```objective-c
[CMNavBarNotificationView setBackgroundImage:[UIImage imageNamed:@"aImage"]];
[CMNavBarNotificationView notifyWithText:@"Moped Dog:"
                        detail:@"I have no idea what I'm doing..."
                         image:nil
                   andDuration:5.0];

````

Touch handling can be implemented using blocks:

```objective-c
[CMNavBarNotificationView notifyWithText:@"Grumpy wizards"
                        detail:@"make a toxic brew for the jovial queen"
                 andTouchBlock:^(CMNavBarNotificationView *notificationView) {
                     NSLog( @"Received touch for notification with text: %@", notificationView.textLabel.text );
}];
````

Also by specifying a delegate which implements the `CMNavBarNotificationViewDelegate` and finally by handling the `kCMNavBarNotificationViewTapReceivedNotification` notification.

###Thanks:

Thanks to [ekurutepe](https://github.com/ekurutepe) for the MPNotificationView project. This is totally based on it.

###License:

Copyright (c) 2013 Eduardo Pinho - Codeminer42

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
