//
//  QuestionThreadViewController.m
//  locaQuery
//
//  Created by Elli Fragkaki on 4/23/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "QuestionThreadViewController.h"
#import "locaQueryAppDelegate.h"
#import "DataModel.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "defs.h"
#import "KBKeyboardHandler.h"
#import "Replica.h"
#import "ReplicaManager.h"
#import "locaQueryAppDelegate.h"

@implementation QuestionThreadViewController

@synthesize dataModel, tableView, threadId;
KBKeyboardHandler *keyboard;

- (void)scrollToNewestMessage
{
    NSLog(@"ScrollToNewestMessage");
    NSLog(@"dataModel messages count: %d", [self.dataModel getMessagesforId:threadId].count);
    NSLog(@"tableview count %d", [tableView numberOfRowsInSection:0]);
	// The newest message is at the bottom of the table
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:([self.dataModel getMessagesforId:threadId].count - 1) inSection:0];
    
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -
#pragma mark NewQuestionDelegate 
- (void)didSaveMessage:(Message*)message atIndex:(int)index
{
	// This method is called when the user presses Save in the Compose screen,
	// but also when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
	if ([self isViewLoaded])
	{
		self.tableView.tableFooterView = nil;
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		[self scrollToNewestMessage];
	}
}



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    Message* message = [[self.dataModel getMessagesforId:threadId] objectAtIndex:0];
	self.title = message.text;
    
	// Show a label in the table's footer if there are no messages
	if ([self.dataModel getMessagesforId:threadId].count == 0)
	{
		UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
		label.text = NSLocalizedString(@"You have no messages", nil);
		label.font = [UIFont boldSystemFontOfSize:16.0f];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		self.tableView.tableFooterView = label;
	}
	else
	{
		[self scrollToNewestMessage];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

- (int)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataModel getMessagesforId:threadId].count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"cellForRowAtIndexPath getting called");
	static NSString* CellIdentifier = @"MessageCellIdentifier";
    
	MessageTableViewCell* cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	Message* message = [[self.dataModel getMessagesforId:threadId] objectAtIndex:indexPath.row];
	[cell setMessage:message];
	return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	// This function is called before cellForRowAtIndexPath, once for each cell.
	// We calculate the size of the speech bubble here and then cache it in the
	// Message object, so we don't have to repeat those calculations every time
	// we draw the cell. We add 16px for the label that sits under the bubble.
	Message* message = [[self.dataModel getMessagesforId:threadId] objectAtIndex:indexPath.row];
	message.bubbleSize = [SpeechBubbleView sizeForText:message.text];
	return message.bubbleSize.height + 16;
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.replyText) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

- (void)userDidCompose:(NSString*)text
{
	// Create a new Message object
	Message* message = [[Message alloc] init];
	message.senderName = nil;
	message.date = [NSDate date];
	message.text = text;
    message.threadId = threadId;
    
	// Add the Message to the data model's list of messages
	int index = [dataModel addMessage:message];
    NSLog(@"put message at index %d", index);
    
	// Add a row for the Message to ChatViewController's table view.
	// Of course, ComposeViewController doesn't really know that the
	// delegate is the ChatViewController.
	[self didSaveMessage:message atIndex:index];
}

- (void)postMessageRequest
{
	[self.replyText resignFirstResponder];
    
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Sending", nil);
    
	NSString* text = self.replyText.text;
    locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
	Replica* replica = [appDelegate.replicaManager getNearestReplica];
    NSLog(@"nearest replica is : %@", replica.replicaURL);
	NSURL* url = [NSURL URLWithString:replica.replicaURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:1];
	[request setPostValue:@"reply" forKey:@"cmd"];
	[request setPostValue:[dataModel fbid] forKey:@"Fid"];
    [request setPostValue:threadId forKey:@"Tid"];
	[request setPostValue:text forKey:@"text"];
    
	[request setCompletionBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"headers response: %@", [request responseHeaders]);
             if ([request responseStatusCode] != 200)
             {
                 ShowErrorAlert(NSLocalizedString(@"Could not send the message to the server", nil));
             }
             else
             {
                 [self userDidCompose:text];
                 self.replyText.text = nil;
             }
         }
     }];
    
    [request setFailedBlock:^ {
        NSLog(@"Request failed");
        //change state of server to down for the specific server we used earlier
        [appDelegate.replicaManager setReplicaDead:replica];
        [self postMessageRequest];
    }];
    
	[request startAsynchronous];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight ;
        self.tableView.frame = [[UIScreen mainScreen] bounds];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    keyboard = [[KBKeyboardHandler alloc] init];
    keyboard.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)replyBtn:(id)sender {
    [self postMessageRequest];
}
@end
