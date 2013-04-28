//
//  Networking.h
//  locaQuery
//
//  Created by Elli Fragkaki on 4/27/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"


typedef void (^BasicBlock)(void);

@interface Networking : NSObject

+(void) sendRequest:(NSDictionary*) params withCompletionBlock:(BasicBlock) block;

@end
