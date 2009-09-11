//
// Font Test
//

// cocos2d import
#import "cocos2d.h"
#import "Texture2D_ZFont.h"

// local import
#import "FontTest.h"

#pragma mark Demo - order

static int fontIdx=0;
static NSString *fontList[] =
{
	@"A Damn Mess",
	@"Abberancy",
	@"Abduction",
	@"Paint Boy",
	@"Schwarzwald Regular",
	@"Scissor Cuts",
};

NSString* nextAction()
{	
	fontIdx++;
	fontIdx = fontIdx % ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* backAction()
{
	fontIdx--;
	if( fontIdx < 0 )
		fontIdx += ( sizeof(fontList) / sizeof(fontList[0]) );
	return fontList[fontIdx];
}

NSString* restartAction()
{
	return fontList[fontIdx];
}

@implementation FontLayer
-(id) init
{
	if(!(self=[super init] ))
        return nil;
    
    // menu
    CGSize size = [Director sharedDirector].winSize;
    MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
    MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
    MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
    Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
    menu.position = CGPointZero;
    item1.position = ccp(size.width/2-100,30);
    item2.position = ccp(size.width/2, 30);
    item3.position = ccp(size.width/2+100,30);
    [self addChild: menu z:1];
    
    [self performSelector:@selector(restartCallback:) withObject:self afterDelay:0.1];
    
	return self;
}

- (void)showFont:(NSString *)aFont {
    
    if (label) {
        [self removeChild:label cleanup:YES];
        [label release];
    }
    
    label = [[Label alloc] initWithString:aFont zFontWithName:aFont pointSize:30];
    label.color = ccc3(0xff, 0xff, 0xff);
    [self addChild:label];
}

-(void) nextCallback:(id) sender
{
    [self showFont:nextAction()];
}	

-(void) backCallback:(id) sender
{
    [self showFont:backAction()];
}	

-(void) restartCallback:(id) sender
{
    [self showFont:restartAction()];
}	
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
    //	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeRight];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	Scene *scene = [Scene node];
	[scene addChild: [FontLayer node]];
	
	[[Director sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window dealloc];
	[super dealloc];
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

@end
