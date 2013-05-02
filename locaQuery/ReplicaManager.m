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
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:+40.443983 longitude:-79.946512]; //CIC
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:+40.443390 longitude:-79.942332]; //UC
    CLLocation *locC = [[CLLocation alloc] initWithLatitude:+40.710992 longitude:-74.005615]; //New York
    CLLocation *locD = [[CLLocation alloc] initWithLatitude:+37.774930 longitude:-122.419415]; //San Francisco

    replicas = [[NSMutableArray alloc] init];
    
    Replica *rep1 = [[Replica alloc] init];
    //[rep1 initialize:@"Replica1" :@"1" :@"http://128.237.113.173:44447/api.php" :locA :true];
    [rep1 initialize:@"Replica1" :@"1" :@"http://128.237.204.59:44447/api.php" :locA :true];

    
    Replica *rep2 = [[Replica alloc] init];
    [rep2 initialize:@"Replica2" :@"2" :@"http://128.237.204.59:44447/api.php" :locB :true];
    //[rep2 initialize:@"Replica2" :@"2" :@"http://128.237.113.173:44447/api.php" :locB :true];
    
    Replica *rep3 = [[Replica alloc] init];
    [rep3 initialize:@"Replica3" :@"3" :@"http://scalepriv-idp.ece.cmu.edu:44447/api.php" :locC :true];
    
    Replica *rep4 = [[Replica alloc] init];
    [rep4 initialize:@"Replica4" :@"4" :@"http://scalepriv-idp.ece.cmu.edu:44447/api.php" :locD :true];
    
//    [replicas addObject:rep1];
    [replicas addObject:rep2];
    [replicas addObject:rep3];
    [replicas addObject:rep4];
    //NSLog(@"Coming here- initialzie2");
    //NSLog (@"Number of elements in array = %lu", (unsigned long)[replicas count]);

}

- (Replica*) getNearestReplica
{
    //NSLog(@"Coming here- getNearestReplica1");

    locaQueryAppDelegate *appDelegate = (locaQueryAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocation* location = [appDelegate.gpsLocation getUserLocation];
    //NSLog(@"latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude,location.coordinate.longitude);
    CLLocation *userLoc = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    
    //NSLog (@" getNearestReplica Number of elements in array = %lu", (unsigned long)[replicas count]);
    int count  = 0;
    Replica *nearestReplica;
    Replica *replica;
    CLLocationDistance minDistance, distance;
    for (replica in replicas)
    {
        //NSLog(@"Alive status is : %d", replica.isAlive);
        if (replica.isAlive)
        {
            //NSLog(@"Coming here- getNearestReplica2");
            //NSLog(@"latitude %+.6f, longitude %+.6f\n",replica.location.coordinate.latitude,replica.location.coordinate.longitude);

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
            
            //NSLog(@"Distance = %f",distance );
            if(distance < minDistance )
            {
                minDistance = distance;
                nearestReplica = replica;
            }
            
            count++;
        }
    }
    
    //NSLog(@" Min Distance : %f", minDistance);
    return nearestReplica;
}

- (void) setReplicaDead :(Replica*) rep
{
    //NSLog(@"replica is : %@", rep.replicaURL);
    //[rep setStatus:false];
    rep.status = false;
}

- (void) setReplicaAlive :(NSString*) rid
{
    for (Replica* r in replicas) {
        if ([r.replicaId isEqualToString:rid])
            r.status = true;
    }
}

@end
