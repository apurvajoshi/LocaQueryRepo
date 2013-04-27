//
//  KBKeyboardHandler.h
//  locaQuery
//
//  Created by Elli Fragkaki on 4/26/13.
//  Copyright (c) 2013 Apurva Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KBKeyboardHandlerDelegate;

@interface KBKeyboardHandler : NSObject

- (id)init;

// Put 'weak' instead of 'assign' if you use ARC
@property(nonatomic, weak) id<KBKeyboardHandlerDelegate> delegate;
@property(nonatomic) CGRect frame;

@end
