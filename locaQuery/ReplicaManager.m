//
//  ReplicaManager.m
//  locaQuery
//
//  Created by Apurva Joshi on 4/27/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "ReplicaManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Replica.h"
#import "locaQueryAppDelegate.h"
#import "GPSlocation.h"
#import "defs.h"

@implementation ReplicaManager

NSMutableArray* replicas;

- (void)initialize
{
    NSLog(@"Coming here- initialzie1");
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:+41.444731 longitude:-79.948062];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:+42.444731 longitude:-79.948062];
    CLLocation *locC = [[CLLocation alloc] initWithLatitude:+43.444731 longitude:-79.948062];
    CLLocation *locD = [[CLLocation alloc] initWithLatitude:+44.444731 longitude:-79.948062];

    replicas = [[NSMutableArray alloc] init];
    
    Replica *rep1 = [[Replica alloc] init];
    [rep1 initialize:@"Replica1" :ServerApiURL :locA :true];
    
    Replica *rep2 = [[Replica alloc] init];
    [rep2 initialize:@"Replica2" :ServerApiURL :locB :true];
    
    Replica *rep3 = [[Replica alloc] init];
    [rep3 initialize:@"Replica3" :ServerApiURL :locC :true];
    
    Replica *rep4 = [[Replica alloc] init];
    [rep4 initialize:@"Replica4" :ServerApiURL :locD :true];
    
    [replicas addObject:rep1];
    [replicas addObject:rep2];
    [replicas addObject:rep3];
    [replicas addObject:rep4];
    NSLog(@"Coming here- initialzie2");
    NSLog (@"Number of elements in array = %lu", (unsigned long)[replicas count]);

}

- (Replica*) getNearestReplica
{
    NSLog(@"Coming here- getNearestReplica1");

    locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation* location = [appDelegate.gpsLocation getUserLocation];
    NSLog(@"latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude,location.coordinate.longitude);
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    NSLog (@" getNearestReplica Number of elements in array = %lu", (unsigned long)[replicas count]);
    int count  = 0;
    Replica *nearestReplica;
    Replica *replica;
    CLLocationDistance minDistance, distance;
    for (replica in replicas)
    {
        NSLog(@"Alive status is : %d", replica.isAlive);
        if (replica.isAlive)
        {
            NSLog(@"Coming here- getNearestReplica2");
            NSLog(@"latitude %+.6f, longitude %+.6f\n",replica.location.coordinate.latitude,replica.location.coordinate.longitude);

            if( count == 0)
            {
                minDistance = [userLoc distanceFromLocation:replica.location];
                distance = [userLoc distanceFromLocation:replica.location];
                nearestReplica = replica;
            }
            else
            {
                distance = [userLoc distanceFromLocation:replica.location];
            }
            
            NSLog(@"Distance = %f",distance );
            if(distance < minDistance )
            {
                minDistance = distance;
                nearestReplica = replica;
            }
            
            count++;
        }
    }
    
    NSLog(@" Min Distance : %f", minDistance);
    return nearestReplica;
}

- (void) setReplicaDead :(Replica*) rep
{
    NSLog(@"replica is : %@", rep.replicaURL);
    //[rep setStatus:false];
    rep.status = false;
}

@end
