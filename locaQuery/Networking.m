//
//  Networking.m
//  locaQuery
//
//  Created by Elli Fragkaki on 4/27/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import "Networking.h"
#import "ASIFormDataRequest.h"
#import "defs.h"

@implementation Networking

+(void) sendRequest:(NSDictionary*)params withCompletionBlock:(BasicBlock)block withErrorBlock:(BasicBlock)errorBlock
{
    NSURL* url = [NSURL URLWithString:ServerApiURL];
	__block ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
	[request setDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:1];
    NSArray* keys = params.allKeys;
    for(NSString* key in keys) {
        [request setPostValue:[params objectForKey:key] forKey:key];
    }
    [request responseHeaders];
    NSDictionary* dict; //= [[NSDictionary]]
	[request setCompletionBlock:block];
    [request setFailedBlock:^ {
       //change state of server to down for the specific server we used earlier
       [self sendRequest:params withCompletionBlock:block];
    }];
    [request startSynchronous];
    return;
}

@end
