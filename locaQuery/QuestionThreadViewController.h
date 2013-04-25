//
//  QuestionThreadViewController.h
//  locaQuery
//
//  Created by Elli Fragkaki on 4/23/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewQuestionViewController.h"

@class DataModel;

@interface QuestionThreadViewController : UIViewController<UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NewQuestionDelegate>

@property (nonatomic, assign) DataModel* dataModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *replyText;
- (IBAction)replyBtn:(id)sender;

@property (nonatomic, assign) NSString* threadId;

@end
