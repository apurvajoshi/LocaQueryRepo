//
//  GPSlocation.h
//  locaQuery
//
//  Created by Apurva Joshi on 4/25/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class DataModel;

@interface GPSlocation : NSObject<CLLocationManagerDelegate>
@property (nonatomic, assign) DataModel* dataModel;

- (void)startStandardUpdates;
- (NSString*)latitude;
- (NSString*)longitude;


@end