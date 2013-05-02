//
//  Replica.h
//  locaQuery
//
//  Created by Apurva Joshi on 4/27/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Replica : NSObject

@property (nonatomic, copy) NSString* replicaName;
@property (nonatomic, copy) NSString* replicaId;
@property (nonatomic, copy) CLLocation* location;
@property (nonatomic, copy) NSString* replicaURL;
@property (nonatomic, assign) bool status;

- (bool)isAlive;
- (void)initialize:(NSString*)name :(NSString*)rid :(NSString*)URL :(CLLocation*)loc :(bool)s;
//- (void)setStatus:(bool)s;
- (NSString*)getURL;


@end