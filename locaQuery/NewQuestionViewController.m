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
    /*[GCTurnBasedMatchHelper sharedInstance].delegate = self;
    [[GCTurnBasedMatchHelper sharedInstance] authenticateLocalUser];
    [[GCTurnBasedMatchHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
    // Do any additional setup after loading the view from its nib.
*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.questionText) {
        
        [theTextField resignFirstResponder];
        
    }
    
    return YES;
    
}


- (IBAction)postQuestion:(id)sender {
}
@end
