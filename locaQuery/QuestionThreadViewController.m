//
//  QuestionThreadViewController.m
//  locaQuery
//
//  Created by Elli Fragkaki on 4/23/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "QuestionThreadViewController.h"
#import "DataModel.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "defs.h"

@implementation QuestionThreadViewController

@synthesize dataModel, tableView, threadId;

- (void)scrollToNewestMessage
{
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
    
	self.title = threadId;
    
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
    
	NSURL* url = [NSURL URLWithString:ServerApiURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    
	[request setPostValue:@"message" forKey:@"cmd"];
	[request setPostValue:[dataModel udid] forKey:@"udid"];
    NSLog(@"udid = : %@", [dataModel udid]);
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
             }
         }
     }];
    
	[request setFailedBlock:^
     {
         if ([self isViewLoaded])
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             ShowErrorAlert([[request error] localizedDescription]);
         }
     }];
    
	[request startAsynchronous];
}

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
    // Do any additional setup after loading the view from its nib.
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
