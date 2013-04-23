//
//  locaQueryAppDelegate.h
//  locaQuery
//
//  Created by Apurva Joshi on 4/18/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class LoginViewController;
@class locaQueryViewController;
@class DataModel;

@interface locaQueryAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) locaQueryViewController *mainViewController;

@property (strong, nonatomic) LoginViewController* loginViewController;

@property BOOL isNavigating;

@property (nonatomic, retain) DataModel* dataModel;

@end
