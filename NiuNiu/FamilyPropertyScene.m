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
#import "Game.h"

@implementation FamilyPropertyScene
@synthesize swipeLeftGestureRecognizer=_swipeLeftGestureRecognizer;
@synthesize swipeRightGestureRecognizer=_swipeRightGestureRecognizer;

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
                                                                      [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[PawnShopScene scene]]];                                                                  }];
        backImg.position = ccp(backImg.contentSize.width / 2, size.height / 2 - backImg.contentSize.height / 2);
        CCLOG(@"backImg.contentSize / 2:%f", backImg.contentSize.width / 2);
        CCLOG(@"backImg.postion-x:%f, y:%f", backImg.position.x,backImg.position.y);
        backImg.scaleX = -1;
        
        CCMenuItemImage *preImg = [CCMenuItemImage itemWithNormalImage:@"back.png"
                                                         selectedImage:@"back.png"
                                                                 block:^(id sender) {
                                                                     [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[CardPlayingScene scene]]];
                                                                 }];
        preImg.position = ccp(size.width - backImg.contentSize.width / 2, size.height /2 - backImg.contentSize.height / 2);
        CCMenu *navigateMenu = [CCMenu menuWithItems:backImg,preImg, nil];
        [navigateMenu setPosition:CGPointZero];
        [self addChild:navigateMenu];
    }
    LOG_FUN_DID;
    return self;
}

#pragma mark - UISwipeGesture switch-scenes
- (void)switchSceneToPawnShop:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionScene transitionWithDuration:2
                                                                                  scene:[PawnShopScene scene]]];
}

- (void)switchSceneToCardPlay:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionScene transitionWithDuration:2
                                                                                  scene:[CardPlayingScene scene]]];
}

- (void)onEnter
{
    self.swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(switchSceneToPawnShop:)];
    self.swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchSceneToCardPlay:)];
    self.swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeRightGestureRecognizer];
     
    [super onEnter];
    LOG_FUN_DID;
}

- (void)onEnterTransitionDidFinish
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCSprite *transitionUpSpr = [CCSprite spriteWithFile:@"transitionUp.png"];
    [self addChild:transitionUpSpr];
    transitionUpSpr.position = ccp(size.width /2 , size.height - transitionUpSpr.contentSize.height / 2);
    
    CCSprite *transitionDownSpr = [CCSprite spriteWithFile:@"transitionDown.png"];
    [self addChild:transitionDownSpr];
    transitionDownSpr.position = ccp(size.width / 2, 0 + transitionDownSpr.contentSize.height / 2);
    
    id moveDown = [CCMoveTo actionWithDuration:0.5 position:ccp(size.width / 2, 0 - transitionUpSpr.contentSize.height / 2)];
    id moveUp = [CCMoveTo actionWithDuration:0.5 position:ccp(size.width / 2, size.height + transitionUpSpr.contentSize.height / 2)];
    
    [transitionUpSpr runAction:moveUp];
    [transitionDownSpr runAction:moveDown];
    [super onEnterTransitionDidFinish];
    LOG_FUN_DID;
}

- (void)onExitTransitionDidStart
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCSprite *transitionUpSpr = [CCSprite spriteWithFile:@"transitionUp.png"];
    [self addChild:transitionUpSpr];
    transitionUpSpr.position = ccp(size.width /2 , size.height + transitionUpSpr.contentSize.height / 2);
    
    CCSprite *transitionDownSpr = [CCSprite spriteWithFile:@"transitionDown.png"];
    [self addChild:transitionDownSpr];
    transitionDownSpr.position = ccp(size.width / 2, 0 - transitionDownSpr.contentSize.height / 2);
    
    id moveDown = [CCMoveTo actionWithDuration:0.5 position:ccp(size.width / 2, size.height - transitionUpSpr.contentSize.height / 2)];
    id moveUp = [CCMoveTo actionWithDuration:0.5 position:ccp(size.width / 2, 0 + transitionUpSpr.contentSize.height / 2)];
    
    [transitionUpSpr runAction:moveDown];
    [transitionDownSpr runAction:moveUp];
    [super onExitTransitionDidStart];
    LOG_FUN_DID;
}

- (void)onExit
{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeftGestureRecognizer];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRightGestureRecognizer];
    [super onExit];
    LOG_FUN_DID;
}

- (void) dealloc
{
	[_swipeLeftGestureRecognizer release];
    _swipeLeftGestureRecognizer = nil;
    [_swipeRightGestureRecognizer release];
    _swipeRightGestureRecognizer = nil;

	[super dealloc];
    LOG_FUN_DID;
}


@end
