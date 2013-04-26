//
//  NewQuestionViewController.h
//  LocaQuery
//
//  Created by Elli Fragkaki on 4/11/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBKeyboardHandlerDelegate.h"
@class NewQuestionViewController;
@class DataModel;
@class Message;

// The delegate protocol for the Compose screen
@protocol NewQuestionDelegate <NSObject>
- (void)didSaveMessage:(Message*)message atIndex:(int)index;
@end

@interface NewQuestionViewController : UIViewController <UITextFieldDelegate, KBKeyboardHandlerDelegate>

@property (nonatomic, retain) IBOutlet UITextField *questionText;
@property (nonatomic, retain) IBOutlet UITextField *radius;
@property (nonatomic, retain) IBOutlet UITextField *hops;

- (IBAction)postQuestion:(id)sender;

@property (copy, nonatomic) NSString *question;
@property (nonatomic, assign) id<NewQuestionDelegate> delegate;
@property (nonatomic, assign) DataModel* dataModel;

- (void) showAlert:(NSString*) alertMessage;

@end
