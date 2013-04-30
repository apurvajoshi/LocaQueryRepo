//
//  GPSlocation.m
//  locaQuery
//
//  Created by Apurva Joshi on 4/25/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "GPSlocation.h"
#import "defs.h"
#import "ASIFormDataRequest.h"
#import "DataModel.h"
#import "Replica.h"
#import "ReplicaManager.h"
#import "locaQueryAppDelegate.h"


@implementation GPSlocation {
    CLLocationManager *locationManager;
}

@synthesize dataModel;
NSString* latitude;
NSString* longitude;
CLLocation* userLocation;

- (void)startStandardUpdates {
    NSLog(@"Get current location");
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter =  10;

    [locationManager startUpdatingLocation];
}

- (NSString*)latitude
{
	return latitude;
}

- (NSString*)longitude
{
	return longitude;
}


- (CLLocation*)getUserLocation;
{
    return userLocation;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    //UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[errorAlert show];
}


// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 60.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude,location.coordinate.longitude);
        userLocation = location;
        latitude =  [NSString stringWithFormat:@"%.6f",location.coordinate.latitude];
        longitude =  [NSString stringWithFormat:@"%.6f",location.coordinate.longitude];
        if (dataModel.fbid != nil)
          [self postJoinRequest];
    }
}


- (void)postJoinRequest
{
    
	// Create the HTTP request object for our URL
    locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
    Replica* replica = [appDelegate.replicaManager getNearestReplica];
    NSLog(@"nearest replica is : %@", replica.replicaURL);
	NSURL* url = [NSURL URLWithString:replica.replicaURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    
	// Add the POST fields
	[request setPostValue:@"heartbeat" forKey:@"cmd"];
	[request setPostValue:[dataModel fbid] forKey:@"Fid"];
	[request setPostValue:latitude forKey:@"GPS_lat"];
	[request setPostValue:longitude forKey:@"GPS_long"];
    
	// This code will be executed when the HTTP request is successful
	[request setCompletionBlock:^
     {

        // If the HTTP response code is not "200 OK", then our server API
        // complained about a problem. This shouldn't happen, but you never
        // know. We must be prepared to handle such unexpected situations.
        if ([request responseStatusCode] != 200)
        {
            ShowErrorAlert(NSLocalizedString(@"Heatbeat : There was an error communicating with the server", nil));
        }
        else
        {
            // Request successfull
            
        }
     }];
    
	// This code is executed when the HTTP request fails
    [request setFailedBlock:^ {
        NSLog(@"GPS Request failed");
        //change state of server to down for the specific server we used earlier
        [appDelegate.replicaManager setReplicaDead:replica];
        [self postJoinRequest];
    }];
    
    
	[request startAsynchronous];
}



@end