//
//  Schedule.m
//  cocos2d-iphone
//
//  Created by Maarten Billemont on 01/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Schedule.h"


@implementation Schedule

@synthesize elapsed, interval, scaleTime, selector;

+ (Schedule *)scheduleSelector:(SEL)aSelector withInterval:(ccTime)anInterval scaleTime:(BOOL)st {
    
    return [[[Schedule alloc] initWithSelector:aSelector interval:anInterval scaleTime:st] autorelease];
}

- (id)initWithSelector:(SEL)aSelector interval:(ccTime)anInterval scaleTime:(BOOL)st {
    
    if (!(self = [super init]))
        return nil;
    
    self.elapsed = 0;
    self.interval = anInterval;
    self.scaleTime = st;
    self.selector = aSelector;
    
    return self;
}

@end
