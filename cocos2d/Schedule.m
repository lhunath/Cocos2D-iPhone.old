//
//  Schedule.m
//  cocos2d-iphone
//
//  Created by Maarten Billemont on 01/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Schedule.h"


@implementation Schedule

@synthesize elapsed, interval, selector;

+ (Schedule *)scheduleSelector:(SEL)aSelector withInterval:(ccTime)anInterval {
    
    return [[[Schedule alloc] initWithSelector:aSelector interval:anInterval] autorelease];
}

- (id)initWithSelector:(SEL)aSelector interval:(ccTime)anInterval {
    
    if (!(self = [super init]))
        return nil;
    
    self.elapsed = 0;
    self.interval = anInterval;
    self.selector = aSelector;
    
    return self;
}

@end
