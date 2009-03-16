//
// Accelerometer + physics example
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//


#import "OpenGL_Internal.h"

#import "Chipmunk_Accel.h"

enum {
	kTagAtlasSpriteManager = 1,
};

static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	Sprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		[sprite setPosition: cpv( body->p.x, body->p.y)];
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

@implementation Layer1
-(void) addNewSpriteX: (float)x y:(float)y
{
	int posx, posy;

	AtlasSpriteManager *mgr = (AtlasSpriteManager*) [self getChildByTag:kTagAtlasSpriteManager];
	
	posx = (CCRANDOM_0_1() * 200);
	posy = (CCRANDOM_0_1() * 200);
	
	posx = (posx % 5) * 85;
	posy = (posy % 2) * 121;
	
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:CGRectMake(posx, posy, 85, 121) spriteManager:mgr];
	[mgr addChild: sprite];
	
	sprite.position = cpv(x,y);
	
	int num = 4;
	cpVect verts[] = {
		cpv(-24,-54),
		cpv(-24, 54),
		cpv( 24, 54),
		cpv( 24,-54),
	};
	
	cpBody *body = cpBodyNew(1.0f, cpMomentForPoly(1.0f, num, verts, cpvzero));
	body->p = cpv(x, y);
	cpSpaceAddBody(space, body);
	
	cpShape* shape = cpPolyShapeNew(body, num, verts, cpvzero);
	shape->e = 0.5f; shape->u = 0.5f;
	shape->data = sprite;
	cpSpaceAddShape(space, shape);
	
}
-(id) init
{
	[super init];
	
	isTouchEnabled = YES;
	isAccelerometerEnabled = YES;
	
	CGSize wins = [[Director sharedDirector] winSize];
	cpInitChipmunk();
	
	cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
	space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, 400.0f, 40);
	cpSpaceResizeActiveHash(space, 100, 600);

	space->gravity = cpv(0, 0);
	space->elasticIterations = space->iterations;

	cpShape *shape;
	
	// bottom
	shape = cpSegmentShapeNew(staticBody, cpv(0,0), cpv(wins.width,0), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);

	// top
	shape = cpSegmentShapeNew(staticBody, cpv(0,wins.height), cpv(wins.width,wins.height), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);

	// left
	shape = cpSegmentShapeNew(staticBody, cpv(0,0), cpv(0,wins.height), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);

	// right
	shape = cpSegmentShapeNew(staticBody, cpv(wins.width,0), cpv(wins.width,wins.height), 0.0f);
	shape->e = 1.0f; shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"grossini_dance_atlas.png" capacity:100];
	[self addChild:mgr z:0 tag:kTagAtlasSpriteManager];
	
	[self addNewSpriteX: 200 y:200];

	[self schedule: @selector(step:)];

	return self;
}

-(void) onEnter
{
	[super onEnter];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

-(void) step: (ccTime) delta
{
	int steps = 2;
	cpFloat dt = delta/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}


- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[Director sharedDirector] convertCoordinate: location];
		
		[self addNewSpriteX: location.x y:location.y];
	}
	return kEventHandled;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;

	cpVect v = cpv( accelX, accelY);

	space->gravity = cpvmult(v, 200);
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
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];
	
	// AnimationInterval doesn't work with FastDirector, yet
//	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];

	// And you can later, once the openGLView was created
	// you can change it's properties
	[[[Director sharedDirector] openGLView] setMultipleTouchEnabled:YES];
	
	
	// add layer
	Scene *scene = [Scene node];
	[scene addChild: [Layer1 node] z:0];
	
	// add the label
	CGSize s = [[Director sharedDirector] winSize];
	Label* label = [Label labelWithString:@"Multi touch the screen" fontName:@"Marker Felt" fontSize:36];
	label.position = cpv( s.width / 2, s.height - 30);
	[scene addChild:label z:-1];

	[window makeKeyAndVisible];

	[[Director sharedDirector] runWithScene: scene];
}

- (void) dealloc
{
	[window release];
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
