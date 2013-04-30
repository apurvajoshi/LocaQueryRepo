//
//  locaQueryViewController.m
//  locaQuery
//
//  Created by Apurva Joshi on 4/18/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "locaQueryViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NewQuestionViewController.h"
#import "DataModel.h"
#import "Message.h"
#import "QuestionThreadViewController.h"

@implementation locaQueryViewController

@synthesize userNameLabel = _userNameLabel;
@synthesize userProfileImage = _userProfileImage;
@synthesize dataModel;
@synthesize questionsTableView;
@synthesize questionViewController =_questionViewController;
@synthesize questionThreadViewController = _questionThreadViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.hidesBackButton = YES;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"LocaQuery";
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Logout"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(logoutButtonWasPressed:)];
    //QuestionTitles = [NSArray arrayWithObjects:@"Question1", @"Question2",@"Question3",nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear and reload view");
    [self.questionsTableView reloadData];
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"tableView table data size: %d", [dataModel.getQuestions count]);
    return [dataModel.getQuestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *simpleTableIdentifier = @"SimpleTableItem";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
 
   if (cell == nil) {
   cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
   }
 
   Message *question = [dataModel.getQuestions objectAtIndex:indexPath.row];
   cell.textLabel.text = question.text;
   cell.imageView.image = [UIImage imageNamed:@"icon-72.png"];
   return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (nil ==  self.questionThreadViewController)
        self.questionThreadViewController = [[QuestionThreadViewController alloc] initWithNibName:@"QuestionThreadViewController" bundle:nil];

    //QuestionThreadViewController *questionThreadViewController = [[QuestionThreadViewController alloc] initWithNibName:@"QuestionThreadViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.

    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    self.questionThreadViewController.dataModel = dataModel;
    Message *question = [dataModel.getQuestions objectAtIndex:indexPath.row];
    self.questionThreadViewController.threadId = question.threadId;
    [self.navigationController pushViewController:self.questionThreadViewController animated:YES];

    
}

#pragma mark - UI Behavior

// Displays the user's name and profile picture so they are aware of the Facebook
// identity they are logged in as.
- (void)populateUserDetails {
    static NSString *name;
    static NSString *fbid;
    
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 name = user.name;
                 fbid = user.id;
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = [user objectForKey:@"id"];
             }
         }];
        /*[[FBRequest requestForMyFriends] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error) {
             if (!error) {
                 NSArray* friends = [result objectForKey:@"data"];
                 for(NSDictionary<FBGraphUser>* friend in friends) {
                     NSLog(@"%@", friend);
                 }
             }
         }];*/
        /*FBRequest* request = [FBRequest requestForMyFriends];
        request.parameters[@"fields"] =
        [NSString stringWithFormat:@"%@,installed", request.parameters[@"fields"]];
        
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSMutableString* string = [[NSMutableString alloc]init];
            
            for(id<FBGraphUser> user in result[@"data"]) {
                if (user[@"installed"]) {
                [string appendFormat:@"%@ with id %@ installed the app? %@\n", [user first_name], [user id], user[@"installed"] ? @"Yes" : @"No"];
                    NSLog(string);
                }
                
            }
        }];*/
    }
}

#pragma mark - FBUserSettingsDelegate methods

- (void)loginViewControllerDidLogUserOut:(id)sender {
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBLoginView delegate (SCLoginViewController)
    // will already handle logging out so this method is a no-op.
}

- (void)loginViewController:(id)sender receivedError:(NSError *)error{
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBUserSettingsViewController is only presented
    // as a log out option after the user has been authenticated, so
    // no real errors should occur. If the FBUserSettingsViewController
    // had been the entry point to the app, then this error handler should
    // be as rigorous as the FBLoginView delegate (SCLoginViewController)
    // in order to handle login errors.
    if (error) {
        NSLog(@"Unexpected error sent to the FBUserSettingsViewController delegate: %@", error);
    }
}

-(void)logoutButtonWasPressed:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (IBAction)newQuestionButton:(id)sender {
    
    if (nil ==  self.questionViewController)
    {
        self.questionViewController  = [[NewQuestionViewController alloc] initWithNibName:@"NewQuestionViewController" bundle:nil];
        self.questionViewController.dataModel = dataModel;
        self.questionViewController.delegate = self;
    }
    [self.navigationController pushViewController:self.questionViewController animated:YES];

    //NewQuestionViewController *newQuestionViewController = [[NewQuestionViewController alloc] initWithNibName:@"NewQuestionViewController" bundle:nil];
	//newQuestionViewController.dataModel = dataModel;
	//newQuestionViewController.delegate = self;
    //[self.navigationController pushViewController:newQuestionViewController animated:YES];
}
@end
