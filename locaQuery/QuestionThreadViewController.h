//
//  QuestionThreadViewController.h
//  locaQuery
//
//  Created by Elli Fragkaki on 4/23/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModel;

@interface QuestionThreadViewController : UIViewController<UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) DataModel* dataModel;


@end
