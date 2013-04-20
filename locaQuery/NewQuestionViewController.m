//
//  NewQuestionViewController.m
//  LocaQuery
//
//  Created by Elli Fragkaki on 4/11/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import "NewQuestionViewController.h"

@implementation NewQuestionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.questionText || theTextField == self.radius || theTextField == self.hops) {
        [theTextField resignFirstResponder];
    }
    return YES;
}


- (IBAction)postQuestion:(id)sender {
}
@end
