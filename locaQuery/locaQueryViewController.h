//
//  locaQueryViewController.h
//  locaQuery
//
//  Created by Apurva Joshi on 4/18/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "NewQuestionViewController.h"
@class DataModel;

@interface locaQueryViewController : UIViewController <UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, NewQuestionDelegate>

@property (weak, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
- (IBAction)newQuestionButton:(id)sender;

@property (nonatomic, assign) DataModel* dataModel;

@end
