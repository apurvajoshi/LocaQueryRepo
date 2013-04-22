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
    
    NSString *question = self.questionText.text;
    int radiusmiles;
    int nofhops;
    NSScanner *parser1 = [NSScanner scannerWithString:self.radius.text];
    NSScanner *parser2 = [NSScanner scannerWithString:self.hops.text];
    if (![parser1 scanInt:&radiusmiles]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please enter an integer number for radius"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else if (![parser2 scanInt:&nofhops]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please enter an integer number for hops of friends"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else {
        NSLog(@"Should send the question now");
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void) showAlert:(NSString*) alertMessage {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
}
@end
