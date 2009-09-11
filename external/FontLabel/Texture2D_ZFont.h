//
//  Texture2D_ZFont.h
//  cocos2d-iphone
//
//  Created by Maarten Billemont on 10/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "cocos2d.h"


@interface Texture2D (ZFont)

- (id) initWithString:(NSString*)string zFontWithName:(NSString*)name pointSize:(CGFloat)size;

@end
