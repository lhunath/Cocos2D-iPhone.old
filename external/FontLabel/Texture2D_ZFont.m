//
//  Texture2D_ZFont.m
//  cocos2d-iphone
//
//  Created by Maarten Billemont on 10/09/09.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "Texture2D_ZFont.h"
#import "FontManager.h"
#import "FontLabelStringDrawing.h"

@implementation Label (ZFont)

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment zFontWithName:(NSString*)name pointSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string dimensions:dimensions alignment:alignment fontName:name fontSize:size]autorelease];
}

+ (id) labelWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size
{
	return [[[self alloc] initWithString: string fontName:name fontSize:size]autorelease];
}


- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
{
	if( (self=[super init]) ) {
        
		_dimensions = dimensions;
		_alignment = alignment;
		_fontName = [name retain];
		_fontSize = size;
		
		[self setString:string];
	}
	return self;
}

- (id) initWithString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size;
{
	if( (self=[super init]) ) {
		
		_dimensions = CGSizeZero;
		_fontName = [name retain];
		_fontSize = size;
		
		[self setString:string];
	}
	return self;
}

@end


@implementation Texture2D (ZFont)

- (id) initWithString:(NSString*)string zFontWithName:(NSString*)name pointSize:(CGFloat)size
{
	CGSize dim = [string sizeWithZFont:[[FontManager sharedManager] zFontWithName:name pointSize:size]];
	return [self initWithString:string dimensions:dim alignment:UITextAlignmentCenter fontName:name fontSize:size];
}

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger				width,
    height,
    i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	ZFont*                  font;
	
	font = [[FontManager sharedManager] zFontWithName:name pointSize:size];
    
	width = dimensions.width;
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while(i < width)
			i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while(i < height)
			i *= 2;
		height = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	
	CGContextSetGrayFillColor(context, 1.0f, 1.0f);
	CGContextTranslateCTM(context, 0.0f, height);
	CGContextScaleCTM(context, 1.0f, -1.0f); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
	[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withZFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end
