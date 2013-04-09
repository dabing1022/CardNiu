//
//  FamilyPropertyScene.m
//  NiuNiu 家产
//
//  Created by childhood on 13-4-7.
//
//

#import "FamilyPropertyScene.h"
#import "PawnShopScene.h"
#import "CardPlayingScene.h"

@implementation FamilyPropertyScene

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
	FamilyPropertyScene *layer = [FamilyPropertyScene node];	
    [scene addChild: layer];
	return scene;
}

-(id)init
{
    if( (self=[super init]) ) {
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"家产" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
		[self addChild: label];
        
        CCMenuItemImage *backImg = [CCMenuItemImage itemWithNormalImage:@"back.png"
                                                          selectedImage:@"back.png"
                                                                  block:^(id sender){
                                                                      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[PawnShopScene scene] withColor:ccWHITE]];                                                                  }];
        backImg.position = ccp(backImg.contentSize.width / 2, size.height / 2 - backImg.contentSize.height / 2);
        CCLOG(@"backImg.contentSize / 2:%f", backImg.contentSize.width / 2);
        CCLOG(@"backImg.postion-x:%f, y:%f", backImg.position.x,backImg.position.y);
        backImg.scaleX = -1;
        
        CCMenuItemImage *preImg = [CCMenuItemImage itemWithNormalImage:@"back.png"
                                                         selectedImage:@"back.png"
                                                                 block:^(id sender) {
                                                                     [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[CardPlayingScene scene] withColor:ccWHITE]];
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
