//
//  Replica.m
//  locaQuery
//
//  Created by Apurva Joshi on 4/27/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "Replica.h"
#import <CoreLocation/CoreLocation.h>

@implementation Replica

@synthesize replicaName, replicaURL, location, status;

- (void)initialize:(NSString*)name :(NSString*)URL :(CLLocation*)loc :(bool)s
{
    self.replicaName = name;
    self.location = loc;
    self.replicaURL = URL;
    self.status = s;
}

- (bool)isAlive
{
	return self.status;
}

- (NSString*)getURL;
{
    return replicaURL;
}

- (void)dealloc
{
	
}

@end