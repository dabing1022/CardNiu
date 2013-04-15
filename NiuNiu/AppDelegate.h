//
//  AppDelegate.h
//  NiuNiu
//
//  Created by childhood on 13-4-7.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "GCDAsyncSocketHelper.h"

BOOL isGameCenterAvailable();

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
    GCDAsyncSocketHelper *socketHelper;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;


@property (readwrite, retain) NSString *currentPlayerID;
@property (readwrite, getter = isGameCenterAuthenticationComplete) BOOL gameCenterAuthenticationComplete;

@end
