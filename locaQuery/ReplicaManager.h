//
//  ReplicaManager.h
//  locaQuery
//
//  Created by Apurva Joshi on 4/27/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Replica.h"

@interface ReplicaManager : NSObject

- (void)initialize;
- (Replica*) getNearestReplica;
- (void) setReplicaDead :(Replica*) rep;
- (void) setReplicaAlive :(NSString*) rid;

@end
