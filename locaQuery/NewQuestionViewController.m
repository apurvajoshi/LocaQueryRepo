//
//  NewQuestionViewController.m
//  LocaQuery
//
//  Created by Elli Fragkaki on 4/11/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import "NewQuestionViewController.h"
#import "ASIFormDataRequest.h"
#import "DataModel.h"
#import "Message.h"
#import "MBProgressHUD.h"
#import "defs.h"
#import "locaQueryAppDelegate.h"
#import "GPSlocation.h"
#import "KBKeyboardHandler.h"
#import "ReplicaManager.h"
#import "Replica.h"

@interface NewQuestionViewController ()
- (void)updateBytesRemaining:(NSString*)text;
@end

@implementation NewQuestionViewController

@synthesize delegate, questionText, dataModel;
KBKeyboardHandler *keyboard;

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
    [self updateBytesRemaining:@""];
    keyboard = [[KBKeyboardHandler alloc] init];
    keyboard.delegate = self;
    
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


#pragma mark -
#pragma mark UITextViewDelegate

- (void)updateBytesRemaining:(NSString*)text
{
	// Calculate how many bytes long the text is. We will send the text as
	// UTF-8 characters to the server. Most common UTF-8 characters can be
	// encoded as a single byte, but multiple bytes as possible as well.
	const char* s = [text UTF8String];
	size_t numberOfBytes = strlen(s);
    
	// Calculate how many bytes are left
	int remaining = MaxMessageLength - numberOfBytes;
    
	NSLog(@"remaining bytes = %d", remaining);
}

#pragma mark -
#pragma mark Server Communication

- (void)userDidCompose:(NSString*)text :(NSString*) threadId
{
	// Create a new Message object
	Message* message = [[Message alloc] init];
	message.senderName = nil;
	message.date = [NSDate date];
	message.text = text;
    message.threadId = threadId;
    message.senderFbid = dataModel.fbid;
	// Add the Message to the data model's list of messages
	int index = [dataModel addMessage:message];
    NSLog(@"Added message and got back index %d", index);
	// Add a row for the Message to ChatViewController's table view.
	// Of course, ComposeViewController doesn't really know that the
	// delegate is the ChatViewController.
	//[self.delegate didSaveMessage:message atIndex:index];
    
	// Close the Compose screen
	//[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)postMessageRequest
{
	// Hide the keyboard
	[questionText resignFirstResponder];
	// Show an activity spinner that blocks the whole screen
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Sending", @"");
    
	NSString* text = self.questionText.text;
    locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
    
    Replica* replica = [appDelegate.replicaManager getNearestReplica];
    NSLog(@"nearest replica is : %@", replica.replicaURL);
	NSURL* url = [NSURL URLWithString:replica.replicaURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:1];
    
    
	// Add the POST fields
    if (ourserver) {
        [request setPostValue:@"query" forKey:@"cmd"];
        [request setPostValue:[dataModel fbid] forKey:@"Fid"];
        [request setPostValue:[dataModel udid] forKey:@"udid"];
    }
    else {
        [request setPostValue:[dataModel udid] forKey:@"udid"];
        [request setPostValue:@"message" forKey:@"cmd"];
    }
    //[request setPostValue:@"Hi, this is the msg from the new code" forKey:@"text"];
	[request setPostValue:text forKey:@"text"];
    //NSMutableString* radiusstr = self.radius.text;
    //[radiusstr appendString:@".0"];
    //NSLog(@"sending radius %@", radiusstr);
    [request setPostValue:self.radius.text forKey:@"Radius"];
    [request setPostValue:self.hops.text forKey:@"Hops"];
    
    
    
    NSLog(@"longitude = : %@",[appDelegate.gpsLocation longitude]);
    NSLog(@"latitude = : %@", [appDelegate.gpsLocation latitude]);
    [request setPostValue:[appDelegate.gpsLocation latitude] forKey:@"GPS_lat"];
	[request setPostValue:[appDelegate.gpsLocation longitude] forKey:@"GPS_long"];
    
    
	// This code will be executed when the HTTP request is successful
	[request setCompletionBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"headers response: %@", [request responseHeaders]);
             // If the HTTP response code is not "200 OK", then our server API
             // complained about a problem. This shouldn't happen, but you never
             // know. We must be prepared to handle such unexpected situations.
             if ([request responseStatusCode] != 200)
             {
                 ShowErrorAlert(NSLocalizedString(@"Could not send the message to the server", nil));
             }
             else
             {
                 NSString* threadId = [[request responseHeaders] objectForKey:@"ThreadId"];
                 if (ourserver) {
                     if ([threadId length] != 0) {
                         NSLog(@"ThreadId message %@", threadId);
                         self.questionText.text = @"";
                         self.radius.text = @"";
                         self.hops.text = @"";
                         [self userDidCompose:text :threadId];
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                     else {
                         NSLog(@"ThreadId message %@", threadId);
                         [self showAlert:@"No friend found nearby. Please increase the radius or the hops of friends and resend your question."];
                     }
                 }
                 else {
                     threadId = @"0000";
                     [self userDidCompose:text :threadId];
                     [self.navigationController popViewControllerAnimated:YES];
                     
                 }
             }
         }
     }];
    
	// This code is executed when the HTTP request fails
	[request setFailedBlock:^ {
        //change state of server to down for the specific server we used earlier
        [appDelegate.replicaManager setReplicaDead:replica];
        [self postMessageRequest];
    }];
    
	[request startAsynchronous];
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
        /* Sending question to the server */
        [self postMessageRequest];
        
    }
}

- (void)keyboardSizeChanged:(CGSize)delta
{
    // Resize / reposition your views here. All actions performed here
    // will appear animated.
    // delta is the difference between the previous size of the keyboard
    // and the new one.
    // For instance when the keyboard is shown,
    // delta may has width=768, height=264,
    // when the keyboard is hidden: width=-768, height=-264.
    // Use keyboard.frame.size to get the real keyboard size.
    
    // Sample:
    CGRect frame = self.view.frame;
    frame.size.height -= delta.height;
    self.view.frame = frame;
}


- (void) showAlert:(NSString*) alertMessage {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
}

@end
