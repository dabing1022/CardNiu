//
//  CardPlayingScene.m
//  NiuNiu 牌局
//
//  Created by childhood on 13-4-7.
//
//

#import "CardPlayingScene.h"
#import "FamilyPropertyScene.h"
#import "PawnShopScene.h"

@implementation CardPlayingScene

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
	CardPlayingScene *layer = [CardPlayingScene node];
    [scene addChild: layer];
	return scene;
}

-(id)init
{
    if( (self=[super init]) ) {
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"牌局" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
		[self addChild: label];
        
        CCMenuItemImage *backImg = [CCMenuItemImage itemWithNormalImage:@"back.png"
                                                          selectedImage:@"back.png"
                                                                  block:^(id sender){
                                                                      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[FamilyPropertyScene scene] withColor:ccWHITE]];                                                                  }];
        backImg.position = ccp(backImg.contentSize.width / 2, size.height / 2 - backImg.contentSize.height / 2);
        CCLOG(@"backImg.contentSize / 2:%f", backImg.contentSize.width / 2);
        CCLOG(@"backImg.postion-x:%f, y:%f", backImg.position.x,backImg.position.y);
        backImg.scaleX = -1;
        
        CCMenuItemImage *preImg = [CCMenuItemImage itemWithNormalImage:@"back.png"
                                                         selectedImage:@"back.png"
                                                                 block:^(id sender){
                                                                     [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[PawnShopScene scene] withColor:ccWHITE]];
                                                                 }];
        preImg.position = ccp(size.width - backImg.contentSize.width / 2, size.height /2 - backImg.contentSize.height / 2);
        CCMenu *navigateMenu = [CCMenu menuWithItems:backImg,preImg, nil];
        [navigateMenu setPosition:CGPointZero];
        [self addChild:navigateMenu];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
}

- (void)onExit
{
    [super onExit];
}

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


@end
