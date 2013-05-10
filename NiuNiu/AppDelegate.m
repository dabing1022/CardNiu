//
//  AppDelegate.m
//  NiuNiu
//
//  Created by childhood on 13-4-7.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "Game.h"
#import "IP_AddressHelper.h"
#import "GameData.h"
#import "User.h"
#import "CardPlayingScene.h"
#import "PopUpTipView.h"

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;
@synthesize currentPlayerID, gameCenterAuthenticationComplete;

#pragma mark -
#pragma mark Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
    /*---------------------------game center------------------------------*/
    self.gameCenterAuthenticationComplete = NO;
    
    if (!isGameCenterAPIAvailable()) {
        // Game Center is not available.
        self.gameCenterAuthenticationComplete = NO;
        CCLOG(@"GameCenter is not available!");
    } else {
        CCLOG(@"GameCenter is available");
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            // If there is an error, do not assume local player is not authenticated.
            if (localPlayer.isAuthenticated) {
                CCLOG(@"localPlayer isAuthenticated");
                // Enable Game Center Functionality
                self.gameCenterAuthenticationComplete = YES;
                CCLOG(@"PlayerID-->%@", localPlayer.playerID);
                CCLOG(@"PlayerAlias--->%@", localPlayer.alias);//玩家的别名
                if (! self.currentPlayerID || ! [self.currentPlayerID isEqualToString:localPlayer.playerID]) {
                    // Current playerID has changed. Create/Load a game state around the new user.
                    self.currentPlayerID = localPlayer.playerID;
                    CCLOG(@"PlayerID new-->%@", self.currentPlayerID);
                    CCLOG(@"PlayerAlias--->%@", localPlayer.alias);//玩家的别名
                    // Load game instance for new current player, if none exists create a new.
                }
                
                //init socketHelper
                socketHelper = [GCDAsyncSocketHelper sharedHelper];
                if(![[socketHelper loginSocket]isConnected])
                    [socketHelper connectLoginServer];
                //获取本机IP地址
                NSString *ipAddress = [IP_AddressHelper getIPAddress];
                CCLOG(@"IP: %@", ipAddress);
                //NSDictionary *dic = [NSDictionary dictionaryWithObject:self.currentPlayerID forKey:@"playerId"];
                NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.currentPlayerID,localPlayer.alias,ipAddress,nil]
                                                                forKeys:[NSArray arrayWithObjects:@"centerID", @"centerName",@"ip",nil]];
                [socketHelper writeData:[socketHelper wrapPacketWithCmd:CMD_LOGIN contentDic:dic] withTimeout:-1 tag:CMD_LOGIN socketType:LOGIN_SOCKET];
                [socketHelper readDataWithTimeout:-1 tag:0 socketType:LOGIN_SOCKET];
                
            } else {
                // No user is logged into Game Center, run without Game Center support or user interface.
                self.gameCenterAuthenticationComplete = NO;
                CCLOG(@"localPlayer is not authenticated");
            }
        }];
    }
    /*----------------------------------------------------------------------------*/


	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:YES];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]]; 

	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];

    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"didInitPlayer"];
//    BOOL didInit = [[NSUserDefaults standardUserDefaults] boolForKey:@"didInitPlayer"];
//    CCLOG(@"didInit %d", didInit);

    BOOL didInit2 = [[NSUserDefaults standardUserDefaults] boolForKey:@"didInitPlayer"];
    if(didInit2)
    {
        CCLOG(@"did init");
    }else
    {
        CCLOG(@"first init");
    }

	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
// 牛牛卡牌契约：自动旋转方向为Portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
    CCLOG(@"程式暂停");
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
    CCLOG(@"程式激活");
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
    CCLOG(@"<%@>", NSStringFromSelector(_cmd));
    
    CCNode *currentScene = [[[CCDirector sharedDirector]runningScene] getChildByTag:0];
    if([currentScene isKindOfClass:[CardPlayingScene class]] && [[[GCDAsyncSocketHelper sharedHelper]cardSocket]isDisconnected]
       && [currentScene respondsToSelector:@selector(showPopTipViewWithTipType:)]){
        [(CardPlayingScene *)currentScene showPopTipViewWithTipType:kTipType_RECONNECT_CARD_SERVER];
    }
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
    CCLOG(@"程式进入后台");
    if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
    /*
     Invalidate Game Center GKAuthentication and save game state, so the game doesn't start until the GKAuthentication
     Completion Handler is run. This prevents a new user from using the old users game state.
     */
    self.gameCenterAuthenticationComplete = NO;   
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    CCLOG(@"程式进入前台");
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    CCLOG(@"程式意外终止");
	CC_DIRECTOR_END();
}

#pragma mark -
#pragma mark Memory Managerment
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

#pragma mark -
#pragma mark GameCenterSupport
BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void) dealloc
{
    [currentPlayerID release];
	[window_ release];
	[navController_ release];
    [socketHelper release];
	[super dealloc];
}
@end

