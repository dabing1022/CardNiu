//
//  PawnShopScene.m
//  NiuNiu 家产
//
//  Created by childhood on 13-4-7.
//
//

#import "PawnShopScene.h"
#import "FamilyPropertyScene.h"
#import "CardPlayingScene.h"
#import "Game.h"
#import "GCDAsyncSocketHelper.h"

@implementation PawnShopScene
@synthesize swipeLeftGestureRecognizer=_swipeLeftGestureRecognizer;
@synthesize swipeRightGestureRecognizer=_swipeRightGestureRecognizer;

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
	PawnShopScene *layer = [PawnShopScene node];
    [scene addChild: layer];
    layer.tag = kTagPawnShopScene;
	return scene;
}

-(id)init
{
    if( (self=[super init]) ) {  
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"典当行" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
		[self addChild: label];
    }
    LOG_FUN_DID;
    return self;
}

#pragma mark - UISwipeGesture switch-scenes
- (void)switchSceneToFamilyProperty:(id)sender
{
    [self closeCurtainWithSel:@selector(switchFamilyPropertyScene:)];
}

- (void)switchFamilyPropertyScene:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[FamilyPropertyScene scene]];
}

- (void)switchSceneToCardPlaying:(id)sender
{
   [self closeCurtainWithSel:@selector(switchCardPlayingScene:)];
}

- (void)switchCardPlayingScene:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CardPlayingScene scene]];
}

#pragma mark - CurtainTransitionDelegateFun
- (void)closeCurtainWithSel:(SEL)sel
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
    id switchCardPlayingScene = [CCCallFunc actionWithTarget:self selector:sel];
    [transitionUpSpr runAction:moveDown];
    [transitionDownSpr runAction:[CCSequence actions:moveUp,switchCardPlayingScene,nil]];
}

- (void)openCurtain
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
}

- (void)onEnter
{
    [self openCurtain];
    self.swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(switchSceneToFamilyProperty:)];
    self.swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchSceneToCardPlaying:)];
    self.swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeRightGestureRecognizer];
    
    [super onEnter];
    LOG_FUN_DID;
}

#pragma mark - UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d", (int) buttonIndex);
    if (buttonIndex == 1) { // OK pushed
        CCLOG(@"sldfjalsfjlasfadsj");
    } else {
        
    }
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
}


@end
