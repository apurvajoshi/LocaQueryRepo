//
//  locaQueryAppDelegate.m
//  locaQuery
//
//  Created by Apurva Joshi on 4/18/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "locaQueryAppDelegate.h"
#import "locaQueryViewController.h"
#import "LoginViewController.h"
#import "QuestionThreadViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "defs.h"
#import "ASIFormDataRequest.h"
#import "DataModel.h"
#import "Message.h"
#import "GPSlocation.h"

void ShowErrorAlert(NSString* text)
{
	UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:text
                              message:nil
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
    
	[alertView show];
}

@interface locaQueryAppDelegate ()
- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI;
@end

@implementation locaQueryAppDelegate

@synthesize window = _window,
navigationController = _navigationController,
mainViewController = _mainViewController,
loginViewController = _loginViewController,
questionThreadViewController = _questionThreadViewController,
isNavigating = _isNavigating;

@synthesize dataModel, gpsLocation, theTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Create the main data model object
	dataModel = [[DataModel alloc] init];
	[dataModel loadMessages];

    gpsLocation = [[GPSlocation alloc] init];
    self.gpsLocation.dataModel = dataModel;
    [gpsLocation startStandardUpdates];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mainViewController = [[locaQueryViewController alloc] initWithNibName:@"locaQueryViewController" bundle:nil];
    //self.window.rootViewController = self.viewController;

    self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                                                     bundle:nil];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
    self.navigationController.delegate = self;
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
    
    // Show the login screen if the user hasn't joined a chat yet
	if (![dataModel joinedChat])
	{
		self.loginViewController.dataModel = dataModel;
        self.loginViewController.gpsLocation = gpsLocation;
	}
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    
    return YES;
}

#pragma mark -
#pragma mark Server Communication

- (void)postUpdateRequest
{
	NSURL* url = [NSURL URLWithString:ServerApiURL];
	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:@"update" forKey:@"cmd"];
	[request setPostValue:[dataModel udid] forKey:@"udid"];
	[request setPostValue:[dataModel deviceToken] forKey:@"token"];
	[request setDelegate:self];
	[request startAsynchronous];
}

#pragma mark -
#pragma mark Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{    
    // We have received a new device token. This method is usually called right
	// away after you've registered for push notifications, but there are no
	// guarantees. It could take up to a few seconds and you should take this
	// into consideration when you design your app. In our case, the user could
	// send a "join" request to the server before we have received the device
	// token. In that case, we silently send an "update" request to the server
	// API once we receive the token.
    
	NSString* oldToken = [dataModel deviceToken];
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My token is: %@", newToken);
    
	[dataModel setDeviceToken:newToken];
    
	// If the token changed and we already sent the "join" request, we should
	// let the server know about the new device token.
	if ([dataModel joinedChat] && ![newToken isEqualToString:oldToken])
	{
		[self postUpdateRequest];
	}
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
    NSLog(@"Message Received");
	Message* message = [[Message alloc] init];
	message.date = [NSDate date];
    
	NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
	NSMutableArray* parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
	message.senderName = [parts objectAtIndex:0];
	[parts removeObjectAtIndex:0];
	message.text = [parts componentsJoinedByString:@": "];
    //get threadId from message when server is ready
    NSString* threadId = @"00";
    message.threadId = threadId;
	int index = [dataModel addMessage:message];
    
    if (updateUI)
    {
        self.questionThreadViewController = [[QuestionThreadViewController alloc] initWithNibName:@"QuestionThreadViewController"
                                                                                           bundle:nil];
        self.questionThreadViewController.dataModel = dataModel;
        self.questionThreadViewController.threadId = threadId;
        [self.questionThreadViewController didSaveMessage:message atIndex:index];
        [self.navigationController pushViewController:self.questionThreadViewController animated:YES];
    }

}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
      NSLog(@"Going into background mode");
//    
//    //As we are going into the background, I want to start a background task to clean up the disk caches
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { //Check if our iOS version supports multitasking I.E iOS 4
//        NSLog(@"Going into 1");
//        if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
//            UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
//            NSLog(@"Going into 2");
//            __block UIBackgroundTaskIdentifier background_task; //Create a task object
//            
//            background_task = [application beginBackgroundTaskWithExpirationHandler: ^{
//                NSLog(@"Going into 3");
//                [application endBackgroundTask:background_task]; //Tell the system that we are done with the tasks
//                background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
//                //System will be shutting down the app at any point in time now
//            }];
//            
//            //Background tasks require you to use asyncrous tasks
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                //Perform your tasks that your application requires
//                
//                //I do what i need to do here.... synchronously...
//                
//                theTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(runTimer:) userInfo:nil repeats:YES];
//
//                NSLog(@"Going into 4");
//                //[application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
//                //background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
//            });
//        }
//    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                  [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Facebook SDK * login flow *
    // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
    if ([[FBSession activeSession] handleOpenURL:url]) {
        return YES;
    } else {
        // Facebook SDK * App Linking *
        // For simplicity, this sample will ignore the link if the session is already
        // open but a more advanced app could support features like user switching.
        // Otherwise extract the app link data from the url and open a new active session from it.
        NSString *appID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
        FBAccessTokenData *appLinkToken = [FBAccessTokenData createTokenFromFacebookURL:url
                                                                                  appID:appID
                                                                        urlSchemeSuffix:nil];
        if (appLinkToken) {
            if ([FBSession activeSession].isOpen) {
                NSLog(@"INFO: Ignoring app link because current session is open.");
            } else {
                [self handleAppLink:appLinkToken];
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    self.isNavigating = NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isNavigating = YES;
}

@end
