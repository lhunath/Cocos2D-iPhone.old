//
//  Schedule.h
//  cocos2d-iphone
//
//  Created by Maarten Billemont on 01/07/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "ccTypes.h"


typedef void (*TICK_IMP)(id, SEL, ccTime);

@interface Schedule : NSObject
{
    ccTime  elapsed, interval;
    SEL     selector;
}

+ (Schedule *)scheduleSelector:(SEL)aSelector withInterval:(ccTime)anInterval;

- (id)initWithSelector:(SEL)aSelector interval:(ccTime)anInterval;

@property (readwrite, assign) ccTime elapsed;
@property (readwrite, assign) ccTime interval;
@property (readwrite, assign) SEL selector;

@end
