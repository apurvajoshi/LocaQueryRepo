//
//  NewQuestionViewController.h
//  LocaQuery
//
//  Created by Elli Fragkaki on 4/11/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewQuestionViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *questionText;
@property (retain, nonatomic) IBOutlet UILabel *postedQuestion;
- (IBAction)postQuestion:(id)sender;

@property (copy, nonatomic) NSString *question;

@end
