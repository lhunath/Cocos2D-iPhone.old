/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "Scene.h"
#import "Director.h"
#import "Support/CGPointExtension.h"

@implementation Scene
-(id) init
{
	if( ! (self=[super init]) )
		return nil;
	
	CGSize s = [[Director sharedDirector] winSize];
	self.relativeTransformAnchor = NO;
	self.transformAnchor = ccp(s.width / 2, s.height / 2);
	
	return self;
}
@end
