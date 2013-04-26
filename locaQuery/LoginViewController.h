//
//  LoginViewController.h
//  LocaQuery
//
//  Created by Elli Fragkaki on 3/29/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@class DataModel;
@class GPSlocation;

@interface LoginViewController : UIViewController<FBLoginViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;
@property (nonatomic, assign) DataModel* dataModel;
@property (nonatomic, assign) GPSlocation* gpsLocation;

@end
