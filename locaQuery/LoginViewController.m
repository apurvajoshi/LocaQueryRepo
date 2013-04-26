//
//  LoginViewController.m
//  LocaQuery
//
//  Created by Elli Fragkaki on 3/29/13.
//  Copyright (c) 2013 Elli Fragkaki. All rights reserved.
//

#import "LoginViewController.h"
#import "locaQueryAppDelegate.h"
#import "locaQueryViewController.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"
#import "DataModel.h"
#import "defs.h"

@implementation LoginViewController
@synthesize dataModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Facebook SDK * pro-tip *
        // We wire up the FBLoginView using the interface builder
        // but we could have also explicitly wired its delegate here.
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidUnload {
    [self setFBLoginView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)postJoinRequest
{
	MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.labelText = NSLocalizedString(@"Connecting", nil);
    
	NSURL* url = [NSURL URLWithString:ServerApiURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
	[request setPostValue:@"join" forKey:@"cmd"];
    static NSString *fbid;
    static NSString *name;
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    if (FBSession.activeSession.isOpen) {
        NSLog(@"FBSession open, will now retrieve info");
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 fbid = user.id;
                 name = user.name;
                 NSLog(@"got fb name %@ and id %@", name, fbid);
                 
                 //[request setPostValue:[dataModel udid] forKey:@"udid"];

                 //  SET THE FACEBOOK ID
                 [dataModel setFbid:fbid];
                 [request setPostValue:[dataModel fbid] forKey:@"Fid"];
                 NSLog(@"fbid = : %@", [dataModel fbid]);
                 // GET THE NAME FROM FACEBOOK
                 [dataModel setNickname:name];
                 [request setPostValue:[dataModel nickname] forKey:@"name"];
                 NSLog(@"nickname = : %@", [dataModel nickname]);
                 
                 [request setPostValue:[dataModel deviceToken] forKey:@"token"];
                 NSLog(@"device token = : %@", [dataModel deviceToken]);
                 
                 [request setPostValue:@"10.01" forKey:@"GPS_lat"];
                 [request setPostValue:@"10.01" forKey:@"GPS_long"];
                 
                 // SET SOME RANDOM CODE
                 //[request setPostValue:[dataModel secretCode] forKey:@"code"];
                 //[request setPostValue:@"locaquerychat" forKey:@"code"];
                 
                 [request setCompletionBlock:^
                  {
                      if ([self isViewLoaded])
                      {
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          
                          NSLog(@"headers response: %@", [request responseHeaders]);
                          
                          if ([request responseStatusCode] != 200)
                          {
                              ShowErrorAlert(NSLocalizedString(@"There was an error communicating with the server", nil));
                          }
                          else
                          {
                              NSLog(@"Got response from server");
                              [self.dataModel setJoinedChat:YES];
                              FBRequest* fbrequest = [FBRequest requestForMyFriends];
                              fbrequest.parameters[@"fields"] =
                              [NSString stringWithFormat:@"%@,installed", fbrequest.parameters[@"fields"]];
                              request = [ASIFormDataRequest requestWithURL:url];
                              //[request setDelegate:self];
                              [request setPostValue:@"friends" forKey:@"cmd"];
                              [fbrequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  
                                  for(id<FBGraphUser> user in result[@"data"]) {
                                      if (user[@"installed"]) {
                                          //NSLog(@"%@ with id %@ installed the app? %@\n", [user first_name], [user id], user[@"installed"] ? @"Yes" : @"No");
                                          if (![friends containsObject:[user id]]) {
                                              [friends addObject:[user id]];
                                              NSLog(@"adding user id %@", [user id]);
                                          }
                                      }
                                  }
                                          [request setPostValue:[dataModel fbid] forKey:@"Fid"];
                                          NSLog(@"sending friedns fbid = : %@", [dataModel fbid]);
                                          for(NSString* s in friends)
                                              NSLog(@"friend:%@", s);
                                          [request setPostValue:friends forKey:@"frnds"];
                                          //send another request with user's friends
                                          [request setCompletionBlock:^
                                           {
                                               if ([self isViewLoaded])
                                               {
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                   
                                                   NSLog(@"headers response: %@", [request responseHeaders]);
                                                   
                                                   if ([request responseStatusCode] != 200)
                                                   {
                                                       ShowErrorAlert(NSLocalizedString(@"There was an error communicating with the server", nil));
                                                   }
                                                   else
                                                   {
                                                       NSLog(@"Got response for friends from server");
                                                       [self.dataModel setJoinedChat:YES];
                                                       
                                                       // Upon login, transition to the main UI by pushing it onto the navigation stack.
                                                       locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
                                                       appDelegate.mainViewController.dataModel = dataModel;
                                                       [self.navigationController pushViewController:((UIViewController *)appDelegate.mainViewController) animated:YES];
                                                       
                                                   }
                                               }
                                           }];
                                          
                                          [request setFailedBlock:^
                                           {
                                               if ([self isViewLoaded])
                                               {
                                                   [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                   //ShowErrorAlert([[request error] localizedDescription]);
                                               }
                                           }];
                                          
                                          [request startAsynchronous];
                                          
                                          
                                      
                                      
                                  
                              }];

                              
                          }
                      }
                  }];
                 
                 [request setFailedBlock:^
                  {
                      if ([self isViewLoaded])
                      {
                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                          //ShowErrorAlert([[request error] localizedDescription]);
                      }
                  }];
                 
                 [request startAsynchronous];

             }
         }];
        
         
	
    }
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"login successful should navigate to main screen");
    [self postJoinRequest];
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage = nil, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
        NSLog(@"Unexpected error:%@", error);
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isNavigating) {
        // The delay is for the edge case where a session is immediately closed after
        // logging in and our navigation controller is still animating a push.
        [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
    } else {
        [self logOut];
    }
}

- (void)logOut {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
