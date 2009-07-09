/* CocosDenshion Audio Manager
 *
 * Copyright (C) 2009 Steve Oldmeadow
 *
 * For independent entities this program is free software; you can redistribute
 * it and/or modify it under the terms of the 'cocos2d for iPhone' license with
 * the additional proviso that 'cocos2D for iPhone' must be credited in a manner
 * that can be be observed by end users, for example, in the credits or during
 * start up. Failure to include such notice is deemed to be acceptance of a 
 * non independent license (see below).
 *
 * For the purpose of this software non independent entities are defined as 
 * those where the annual revenue of the entity employing, partnering, or 
 * affiliated in any way with the Licensee is greater than $250,000 USD annually.
 *
 * Non independent entities may license this software or a derivation of it
 * by a donation of $500 USD per application to the cocos2d for iPhone project. 
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 */

#import "CocosDenshion.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
	kAudioManagerFxOnly,					//Other apps will be able to play audio
	kAudioManagerFxPlusMusic,				//Only this app will play audio
	kAudioManagerFxPlusMusicIfNoOtherAudio	//If another app is playing audio at start up then allow it to continue and don't play music
} tAudioManagerMode;

typedef enum {
	kAMStateUninitialised, //Audio manager has not been initialised - do not use
	kAMStateInitialising,  //Audio manager is in the process of initialising - do not use
	kAMStateInitialised	   //Audio manager is initialised - safe to use
} tAudioManagerState;

typedef enum {
	kAMRBDoNothing,			    //Audio manager will not do anything on resign or becoming active
	kAMRBStopPlay,    			//Background music is stopped on resign and resumed on become active
	kAMRBStop					//Background music is stopped on resign but not resumed - maybe because you want to do this from within your game
} tAudioManagerResignBehavior;


@interface CDAsynchInitialiser : NSOperation {}	
@end

@interface CDAudioManager : NSObject <AVAudioPlayerDelegate> {
	CDSoundEngine		*soundEngine;
	AVAudioPlayer		*backgroundMusic;
	NSString			*lastBackgroundMusicFilePath;
	UInt32				_audioSessionCategory;
	BOOL				_audioWasPlayingAtStartup;
	tAudioManagerMode	_mode;
	SEL backgroundMusicCompletionSelector;
	id backgroundMusicCompletionListener;
	BOOL willPlayBackgroundMusic;
	BOOL _mute;
	BOOL _muteStoppedMusic;
	
	//For handling resign/become active
	BOOL _isObservingAppEvents;
	BOOL _systemPausedMusic;
	tAudioManagerResignBehavior _resignBehavior;
	NSTimeInterval _bookmark;
	
	
}

@property (readonly) CDSoundEngine *soundEngine;
@property (readonly) AVAudioPlayer *backgroundMusic;
@property (readonly) BOOL willPlayBackgroundMusic;
@property (readwrite) BOOL mute; 


+ (CDAudioManager *) sharedManager;
+ (tAudioManagerState) sharedManagerState;
+ (void) configure: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
+ (void) initAsynchronously: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;

- (id) init: (tAudioManagerMode) mode channelGroupDefinitions:(int[]) channelGroupDefinitions channelGroupTotal:(int) channelGroupTotal;
-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop;
-(void) preloadBackgroundMusic:(NSString*) filePath;
-(void) stopBackgroundMusic;
-(void) stopBackgroundMusic:(BOOL) release;
-(void) pauseBackgroundMusic;
-(void) rewindBackgroundMusic;
-(void) resumeBackgroundMusic;
-(BOOL) isBackgroundMusicPlaying;
-(void) setBackgroundMusicCompletionListener:(id) listener selector:(SEL) selector;
-(void) audioSessionInterrupted;
-(void) audioSessionResumed;
-(void) setResignBehavior:(tAudioManagerResignBehavior) resignBehavior autoHandle:(BOOL) autoHandle;

@end
