//
//  GPSlocation.m
//  locaQuery
//
//  Created by Apurva Joshi on 4/25/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "GPSlocation.h"

@implementation GPSlocation {
    CLLocationManager *locationManager;
}

NSString* latitude;
NSString* longitude;

- (void)initialize
{
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Are you coming here");
    locationManager = [[CLLocationManager alloc] init];
}

- (void)getCurrentLocation {
    NSLog(@"Get current location");
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"longitude  :%@",[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        NSLog(@"latitude : %@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
}

@end