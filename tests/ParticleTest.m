//
// Particle Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// local import
#import "ParticleTest.h"

enum {
	kTagLabelAtlas = 1,
};

static int sceneIdx=-1;
static NSString *transitions[] = {
	
		@"DemoFlower",
		@"DemoGalaxy",
		@"DemoFirework",
		@"DemoSpiral",
		@"DemoSun",
		@"DemoMeteor",
		@"DemoFire",
		@"DemoSmoke",
		@"DemoExplosion",
		@"DemoSnow",
		@"DemoRain",
		@"DemoBigFlower",
		@"DemoRotFlower",
		@"DemoModernArt",
		@"DemoRing",

		@"ParallaxParticle",

		@"ParticleDesigner1",
		@"ParticleDesigner2",
		@"ParticleDesigner3",
		@"ParticleDesigner4",
		@"ParticleDesigner5",
		@"ParticleDesigner6",
		@"ParticleDesigner7",
		@"ParticleDesigner8",
		@"ParticleDesigner9",
		@"ParticleDesigner10",
		@"ParticleDesigner11",

		@"RadiusMode1",
		@"RadiusMode2",
		@"Issue704",
		@"Issue872",
		@"Issue870",
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	

	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

@implementation ParticleDemo

@synthesize emitter;
-(id) init
{
	if( (self=[super initWithColor:ccc4(127,127,127,255)] )) {

		self.isTouchEnabled = YES;
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		CCLabelTTF *label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild:label z:100];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF *l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:100];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}			
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(toggleCallback:) items:
								   [CCMenuItemFont itemFromString: @"Free Movement"],
								   [CCMenuItemFont itemFromString: @"Relative Movement"],
								   [CCMenuItemFont itemFromString: @"Grouped Movement"],

								 nil];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
			
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		item4.position = ccp( 0, 100);
		item4.anchorPoint = ccp(0,0);

		[self addChild: menu z:100];	
		
		CCLabelAtlas *labelAtlas = [CCLabelAtlas labelWithString:@"0000" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
		[self addChild:labelAtlas z:100 tag:kTagLabelAtlas];
		labelAtlas.position = ccp(s.width-66,50);
		
		// moving background
		background = [CCSprite spriteWithFile:@"background3.png"];
		[self addChild:background z:5];
		[background setPosition:ccp(s.width/2, s.height-180)];

		id move = [CCMoveBy actionWithDuration:4 position:ccp(300,0)];
		id move_back = [move reverse];
		id seq = [CCSequence actions: move, move_back, nil];
		[background runAction:[CCRepeatForever actionWithAction:seq]];
		
		
		[self scheduleUpdate];
	}

	return self;
}

- (void) dealloc
{
	[emitter release];
	[super dealloc];
}


-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	[self ccTouchEnded:touch withEvent:event];
	
	// claim the touch
	return YES;
}
- (void)ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self ccTouchEnded:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];

	CGPoint pos = CGPointZero;
	
	if( background )
		pos = [background convertToWorldSpace:CGPointZero];
	emitter.position = ccpSub(convertedLocation, pos);	
}

-(void) update:(ccTime) dt
{
	CCLabelAtlas *atlas = (CCLabelAtlas*) [self getChildByTag:kTagLabelAtlas];

	NSString *str = [NSString stringWithFormat:@"%4d", emitter.particleCount];
	[atlas setString:str];
}

-(NSString*) title
{
	return @"No title";
}
-(NSString*) subtitle
{
	return @"Tap the screen";
}

-(void) toggleCallback: (id) sender
{
	if( emitter.positionType == kCCPositionTypeGrouped )
		emitter.positionType = kCCPositionTypeFree;
	else if( emitter.positionType == kCCPositionTypeFree )
		emitter.positionType = kCCPositionTypeRelative;
	else if( emitter.positionType == kCCPositionTypeRelative )
		emitter.positionType = kCCPositionTypeGrouped;
}

-(void) restartCallback: (id) sender
{
//	Scene *s = [Scene node];
//	[s addChild: [restartAction() node]];
//	[[Director sharedDirector] replaceScene: s];
	
	[emitter resetSystem];
//	[emitter stopSystem];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) setEmitterPosition
{
	if( CGPointEqualToPoint( emitter.sourcePosition, CGPointZero ) ) 
		emitter.position = ccp(200, 70);
}

@end

#pragma mark -

@implementation DemoFirework
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleFireworks node];
	[background addChild: emitter z:10];

	// testing "alpha" blending in premultiplied images
//	emitter.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA};
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars.png"];
	emitter.blendAdditive = YES;
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFireworks";
}
@end

#pragma mark -

@implementation DemoFire
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleFire node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
	CGPoint p = emitter.position;
	emitter.position = ccp(p.x, 100);
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFire";
}
@end

#pragma mark -

@implementation DemoSun
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSun node];
	[background addChild: emitter z:10];

	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleSun";
}
@end

#pragma mark -

@implementation DemoGalaxy
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleGalaxy node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleGalaxy";
}
@end

#pragma mark -

@implementation DemoFlower
-(void) onEnter
{
	[super onEnter];

	self.emitter = [CCParticleFlower node];
	[background addChild: emitter z:10];
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleFlower";
}
@end

#pragma mark -

@implementation DemoBigFlower
-(void) onEnter
{
	[super onEnter];
	self.emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:50];
	[background addChild: emitter z:10];
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	// duration
	emitter.duration = kCCParticleDurationInfinity;
	
	// Gravity Mode: gravity
	emitter.gravity = CGPointZero;

	// Set "Gravity" mode (default one)
	emitter.emitterMode = kCCParticleModeGravity;
	
	// Gravity Mode: speed of particles
	emitter.speed = 160;
	emitter.speedVar = 20;
		
	// Gravity Mode: radial
	emitter.radialAccel = -120;
	emitter.radialAccelVar = 0;
	
	// Gravity Mode: tagential
	emitter.tangentialAccel = 30;
	emitter.tangentialAccelVar = 0;
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 360;
		
	// emitter position
	emitter.position = ccp(160,240);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 4;
	emitter.lifeVar = 1;
	
	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 80.0f;
	emitter.startSizeVar = 40.0f;
	emitter.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	// additive
	emitter.blendAdditive = YES;
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Big Particles";
}
@end

#pragma mark -

@implementation DemoRotFlower
-(void) onEnter
{
	[super onEnter];
	self.emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:300];
	[background addChild: emitter z:10];
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars2-grayscale.png"];
	
	// duration
	emitter.duration = kCCParticleDurationInfinity;
	
	// Set "Gravity" mode (default one)
	emitter.emitterMode = kCCParticleModeGravity;

	// Gravity mode: gravity
	emitter.gravity = CGPointZero;
	
	// Gravity mode: speed of particles
	emitter.speed = 160;
	emitter.speedVar = 20;
	
	// Gravity mode: radial
	emitter.radialAccel = -120;
	emitter.radialAccelVar = 0;
	
	// Gravity mode: tagential
	emitter.tangentialAccel = 30;
	emitter.tangentialAccelVar = 0;
	
	// emitter position
	emitter.position = ccp(160,240);
	emitter.posVar = CGPointZero;
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 360;
		
	// life of particles
	emitter.life = 3;
	emitter.lifeVar = 1;

	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 2000;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;

	// size, in pixels
	emitter.startSize = 30.0f;
	emitter.startSizeVar = 00.0f;
	emitter.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;

	// additive
	emitter.blendAdditive = NO;
	
	[self setEmitterPosition];
	
}
-(NSString *) title
{
	return @"Spinning Particles";
}
@end

#pragma mark -

@implementation DemoMeteor
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleMeteor node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleMeteor";
}
@end

#pragma mark -

@implementation DemoSpiral
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSpiral node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleSpiral";
}
@end

#pragma mark -

@implementation DemoExplosion
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleExplosion node];
	[background addChild: emitter z:10];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	emitter.autoRemoveOnFinish = YES;
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleExplosion";
}
@end

#pragma mark -

@implementation DemoSmoke
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSmoke node];
	[background addChild: emitter z:10];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, 100);
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"ParticleSmoke";
}
@end

#pragma mark -

@implementation DemoSnow
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleSnow node];
	[background addChild: emitter z:10];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, p.y-110);
	emitter.life = 3;
	emitter.lifeVar = 1;
	
	// gravity
	emitter.gravity = ccp(0,-10);
		
	// speed of particles
	emitter.speed = 130;
	emitter.speedVar = 30;
	
	
	ccColor4F startColor = emitter.startColor;
	startColor.r = 0.9f;
	startColor.g = 0.9f;
	startColor.b = 0.9f;
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = emitter.startColorVar;
	startColorVar.b = 0.1f;
	emitter.startColorVar = startColorVar;
	
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"snow.png"];
	
	[self setEmitterPosition];

}
-(NSString *) title
{
	return @"ParticleSnow";
}
@end

#pragma mark -

@implementation DemoRain
-(void) onEnter
{
	[super onEnter];
	self.emitter = [CCParticleRain node];
	[background addChild: emitter z:10];
	
	CGPoint p = emitter.position;
	emitter.position = ccp( p.x, p.y-100);
	emitter.life = 4;
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.pvr"];
	
	[self setEmitterPosition];

}
-(NSString *) title
{
	return @"ParticleRain";
}
@end

#pragma mark -

@implementation DemoModernArt
-(void) onEnter
{
	[super onEnter];
	self.emitter = [[CCParticleSystemPoint alloc] initWithTotalParticles:1000];
	[background addChild: emitter z:10];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	// duration
	emitter.duration = kCCParticleDurationInfinity;
	
	// Gravity mode
	emitter.emitterMode = kCCParticleModeGravity;
	
	// Gravity mode: gravity
	emitter.gravity = ccp(0,0);
		
	// Gravity mode: radial
	emitter.radialAccel = 70;
	emitter.radialAccelVar = 10;
	
	// Gravity mode: tagential
	emitter.tangentialAccel = 80;
	emitter.tangentialAccelVar = 0;
	
	// Gravity mode: speed of particles
	emitter.speed = 50;
	emitter.speedVar = 10;
	
	// angle
	emitter.angle = 0;
	emitter.angleVar = 360;
	
	// emitter position
	emitter.position = ccp( s.width/2, s.height/2);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 2.0f;
	emitter.lifeVar = 0.3f;
	
	// emits per frame
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 1.0f;
	emitter.startSizeVar = 1.0f;
	emitter.endSize = 32.0f;
	emitter.endSizeVar = 8.0f;
	
	// texture
//	emitter.texture = [[TextureCache sharedTextureCache] addImage:@"fire-grayscale.png"];
	
	// additive
	emitter.blendAdditive = NO;
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Varying size";
}
@end

#pragma mark -

@implementation DemoRing
-(void) onEnter
{
	[super onEnter];
	self.emitter = [[CCParticleFlower alloc] initWithTotalParticles:500];
	[background addChild: emitter z:10];

	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	emitter.lifeVar = 0;
	emitter.life = 10;
	emitter.speed = 100;
	emitter.speedVar = 0;
	emitter.emissionRate = 10000;
	
	[self setEmitterPosition];
}
-(NSString *) title
{
	return @"Ring Demo";
}
@end

#pragma mark -

@implementation ParallaxParticle
-(void) onEnter
{
	[super onEnter];

	[[background parent] removeChild:background cleanup:YES];
	background = nil;

	CCParallaxNode *p = [[CCParallaxNode alloc] init];
	[self addChild:p z:5];

	CCSprite *p1 = [CCSprite spriteWithFile:@"background3.png"];
	background = p1;
	
	CCSprite *p2 = [CCSprite spriteWithFile:@"background3.png"];

	[p addChild:p1 z:1 parallaxRatio:ccp(0.5f,1) positionOffset:ccp(0,250)];
	[p addChild:p2 z:2 parallaxRatio:ccp(1.5f,1) positionOffset:ccp(0,50)];

	
	self.emitter = [[CCParticleFlower alloc] initWithTotalParticles:500];
	[p1 addChild:emitter z:10];
	[emitter setPosition:ccp(250,200)];
	
	id par = [[CCParticleSun alloc] initWithTotalParticles:250];
	[p2 addChild:par z:10];
	[par release];
	
	
	id move = [CCMoveBy actionWithDuration:4 position:ccp(300,0)];
	id move_back = [move reverse];
	id seq = [CCSequence actions: move, move_back, nil];
	[p runAction:[CCRepeatForever actionWithAction:seq]];	
}

-(NSString *) title
{
	return @"Parallax + Particles";
}
@end

#pragma mark -

@implementation ParticleDesigner1
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/SpookyPeas.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Spooky Peas";
}
@end

#pragma mark -

@implementation ParticleDesigner2
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/SpinningPeas.plist"];
	[self addChild: emitter z:10];
	
	// custom spinning
	self.emitter.startSpin = 0;
	self.emitter.startSpin = 360;
	self.emitter.endSpin = 720;
	self.emitter.endSpinVar = 360;	
}

-(NSString *) title
{
	return @"PD: Spinning Peas";
}
@end


#pragma mark -

@implementation ParticleDesigner3
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/LavaFlow.plist"];
	[self addChild: emitter z:10];

}

-(NSString *) title
{
	return @"PD: Lava Flow";
}
@end

#pragma mark -

@implementation ParticleDesigner4
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/ExplodingRing.plist"];
	[self addChild: emitter z:10];

	[self removeChild:background cleanup:YES];
	background = nil;
}

-(NSString *) title
{
	return @"PD: Exploding Ring";
}
@end

#pragma mark -

@implementation ParticleDesigner5
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Comet.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Comet";
}
@end

#pragma mark -

@implementation ParticleDesigner6
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;

	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BurstPipe.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Burst Pipe";
}
@end

#pragma mark -

@implementation ParticleDesigner7
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/BoilingFoam.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Boiling Foam";
}
@end

#pragma mark -

@implementation ParticleDesigner8
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Flower.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Flower";
}

-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}

@end

#pragma mark -

@implementation ParticleDesigner9
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Spiral.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Blur Spiral";
}

-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}

@end

#pragma mark -

@implementation ParticleDesigner10
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/Galaxy.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Galaxy";
}
-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}
@end

#pragma mark -

@implementation ParticleDesigner11
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [CCParticleSystemQuad particleWithFile:@"Particles/debian.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"PD: Debian";
}
-(NSString*) subtitle
{
	return @"Testing radial & tangential accel";
}
@end



#pragma mark -


@implementation RadiusMode1
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];
	[self addChild: emitter z:10];

	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	// duration
	emitter.duration = kCCParticleDurationInfinity;

	// radius mode
	emitter.emitterMode = kCCParticleModeRadius;
	
	// radius mode: start and end radius in pixels
	emitter.startRadius = 0;
	emitter.startRadiusVar = 0;
	emitter.endRadius = 160;
	emitter.endRadiusVar = 0;
	
	// radius mode: degrees per second
	emitter.rotatePerSecond = 180;
	emitter.rotatePerSecondVar = 0;
	
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 0;
		
	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter.position = ccp( size.width/2, size.height/2);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 5;
	emitter.lifeVar = 0;
	
	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 32;
	emitter.startSizeVar = 0;
	emitter.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	// additive
	emitter.blendAdditive = NO;
}


-(NSString *) title
{
	return @"Radius Mode: Spiral";
}
@end

#pragma mark -

@implementation RadiusMode2
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:200];
	[self addChild: emitter z:10];
	
	emitter.texture = [[CCTextureCache sharedTextureCache] addImage: @"stars-grayscale.png"];
	
	// duration
	emitter.duration = kCCParticleDurationInfinity;
	
	// radius mode
	emitter.emitterMode = kCCParticleModeRadius;
	
	// radius mode: 100 pixels from center
	emitter.startRadius = 100;
	emitter.startRadiusVar = 0;
	emitter.endRadius = kCCParticleStartRadiusEqualToEndRadius;
	emitter.endRadiusVar = 0;	// not used when start == end
	
	// radius mode: degrees per second
	// 45 * 4 seconds of life = 180 degrees
	emitter.rotatePerSecond = 45;
	emitter.rotatePerSecondVar = 0;
	
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 0;
	
	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter.position = ccp( size.width/2, size.height/2);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 4;
	emitter.lifeVar = 0;
	
	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 32;
	emitter.startSizeVar = 0;
	emitter.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;
	
	// additive
	emitter.blendAdditive = NO;
	
}

-(NSString *) title
{
	return @"Radius Mode: Semi Circle";
}
@end

#pragma mark -

@implementation Issue704
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	self.emitter = [[CCParticleSystemQuad alloc] initWithTotalParticles:100];
	[self addChild: emitter z:10];
	emitter.duration = kCCParticleDurationInfinity;
	
	// radius mode
	emitter.emitterMode = kCCParticleModeRadius;
	
	// radius mode: 50 pixels from center
	emitter.startRadius = 50;
	emitter.startRadiusVar = 0;
	emitter.endRadius = kCCParticleStartRadiusEqualToEndRadius;
	emitter.endRadiusVar = 0;	// not used when start == end
	
	// radius mode: degrees per second
	// 45 * 4 seconds of life = 180 degrees
	emitter.rotatePerSecond = 0;
	emitter.rotatePerSecondVar = 0;
	
	
	// angle
	emitter.angle = 90;
	emitter.angleVar = 0;
	
	// emitter position
	CGSize size = [[CCDirector sharedDirector] winSize];
	emitter.position = ccp( size.width/2, size.height/2);
	emitter.posVar = CGPointZero;
	
	// life of particles
	emitter.life = 5;
	emitter.lifeVar = 0;
	
	// spin of particles
	emitter.startSpin = 0;
	emitter.startSpinVar = 0;
	emitter.endSpin = 0;
	emitter.endSpinVar = 0;
	
	// color of particles
	ccColor4F startColor = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColor = startColor;
	
	ccColor4F startColorVar = {0.5f, 0.5f, 0.5f, 1.0f};
	emitter.startColorVar = startColorVar;
	
	ccColor4F endColor = {0.1f, 0.1f, 0.1f, 0.2f};
	emitter.endColor = endColor;
	
	ccColor4F endColorVar = {0.1f, 0.1f, 0.1f, 0.2f};	
	emitter.endColorVar = endColorVar;
	
	// size, in pixels
	emitter.startSize = 16;
	emitter.startSizeVar = 0;
	emitter.endSize = kCCParticleStartSizeEqualToEndSize;
	
	// emits per second
	emitter.emissionRate = emitter.totalParticles/emitter.life;

	// additive
	emitter.blendAdditive = NO;
		
	id rot = [CCRotateBy actionWithDuration:16 angle:360];
	[emitter runAction: [CCRepeatForever actionWithAction:rot] ];
	
}

-(NSString *) title
{
	return @"Issue 704. Free + Rot";
}

-(NSString*) subtitle
{
	return @"Emitted particles should not rotate";
}
@end

#pragma mark -

@implementation Issue872
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	emitter = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/Upsidedown.plist"];
	[self addChild: emitter z:10];
}

-(NSString *) title
{
	return @"Issue 872. UpsideDown";
}

-(NSString*) subtitle
{
	return @"Particles should NOT be Upside Down. M should appear, not W.";
}
@end

#pragma mark -

@implementation Issue870
-(void) onEnter
{
	[super onEnter];
	
	[self setColor:ccBLACK];
	[self removeChild:background cleanup:YES];
	background = nil;
	
	CCParticleSystemQuad *system = [[CCParticleSystemQuad alloc] initWithFile:@"Particles/SpinningPeas.plist"];
	
	[system setTexture: [[CCTextureCache sharedTextureCache] addImage:@"particles.png"] withRect:CGRectMake(0,0,32,32)];
	[self addChild: system z:10];
	
	emitter = system;
	
	index = 0;
	
	[self schedule:@selector(updateQuads:) interval:2];
}

-(void) updateQuads:(ccTime)dt
{
	index = (index + 1) % 4;
	CGRect rect = CGRectMake(index*32, 0,32,32);
	
	CCParticleSystemQuad *system = (CCParticleSystemQuad*) emitter;
	[system setTexture:[emitter texture] withRect:rect];
}

-(NSString *) title
{
	return @"Issue 870. SubRect";
}

-(NSString*) subtitle
{
	return @"Every 2 seconds the particle should change";
}
@end



#pragma mark -
#pragma mark App Delegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	

	CCScene *scene = [CCScene node];
	[scene addChild: [nextAction() node]];
	
	[director runWithScene: scene];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	[[CCDirector sharedDirector] startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{	
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
