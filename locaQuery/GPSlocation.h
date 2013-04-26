//
//  GPSlocation.h
//  locaQuery
//
//  Created by Apurva Joshi on 4/25/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GPSlocation : NSObject<CLLocationManagerDelegate>

- (void)getCurrentLocation;
- (void)initialize;
- (NSString*)latitude;
- (NSString*)longitude;

@end