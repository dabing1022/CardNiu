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
#import "GameData.h"
#import "User.h"
#import "GCDAsyncSocketHelper.h"
#import "CCScrollView.h"

@implementation FamilyPropertyScene
@synthesize swipeLeftGestureRecognizer=_swipeLeftGestureRecognizer;
@synthesize swipeRightGestureRecognizer=_swipeRightGestureRecognizer;

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
	FamilyPropertyScene *layer = [FamilyPropertyScene node];	
    [scene addChild: layer];
    layer.tag = kTagFamilyPropertyScene;
	return scene;
}

-(id)init
{
    if( (self=[super init]) ) {
        [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"sketchSpriteSheet.plist"];
//        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sketchSpriteSheet.pvr.ccz"];
//        [self addChild:spriteSheet];
        
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"家产" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
		[self addChild: label];
        
        /*---------familyPropertyToggle---------*/
        _familyPropertyMenuItemNomal = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"familyPropertyItemNomal.png"] selectedSprite:nil];
        
        _familyPropertyMenuItemSelected = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"familyPropertyItemSelected.png"] selectedSprite:nil];
        
        _familyPropertyItemToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(navigateToFamilyProperty:) items:_familyPropertyMenuItemNomal,_familyPropertyMenuItemSelected, nil];
        [_familyPropertyItemToggle setSelectedIndex:1];
        
        /*---------cardToggle-------------------*/
        _cardMenuItemNomal = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"cardItemNomal.png"] selectedSprite:nil];
        
        _cardMenuItemSelected = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"cardItemSelected.png"] selectedSprite:nil];
        
        _cardItemToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(navigateToCard:) items:_cardMenuItemNomal,_cardMenuItemSelected, nil];
        [_cardItemToggle setPosition:CGPointMake(100, 0)];
        
        
        /*---------stateToggle-----------------*/
        _stateMenuItemNomal = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"stateItemNomal.png"] selectedSprite:nil];
        
        _stateMenuItemSelected = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"stateItemSelected.png"] selectedSprite:nil];
        
        _stateItemToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(navigateToState:) items:_stateMenuItemNomal,_stateMenuItemSelected, nil];
        [_stateItemToggle setPosition:CGPointMake(200, 0)];
        
        /*---------navigateMenu----------------*/
        _navigateMenu = [CCMenu menuWithItems:_familyPropertyItemToggle,_cardItemToggle,_stateItemToggle, nil];
        [self addChild:_navigateMenu];
        [_navigateMenu setPosition:CGPointMake(100, 400)];
        
        _familyPropertyLayer = [[CCLayer alloc]init];
        _cardLayer = [[CCLayer alloc]init];
        _stateLayer = [[CCLayer alloc]init];
        
        CCSprite *bar1 = [CCSprite spriteWithSpriteFrameName:@"familyPropertyBarBg.png"];
        [bar1 setPosition:CGPointMake(size.width/2,size.height/2)];
        CCSprite *bar2 = [CCSprite spriteWithSpriteFrameName:@"familyPropertyBarBg.png"];
        [bar2 setPosition:CGPointMake(size.width/2,size.height/2 - 50)];
        CCSprite *bar3 = [CCSprite spriteWithSpriteFrameName:@"familyPropertyBarBg.png"];
        [bar3 setPosition:CGPointMake(size.width/2,size.height/2 - 100)];
        CCSprite *bar4 = [CCSprite spriteWithSpriteFrameName:@"familyPropertyBarBg.png"];
        [bar4 setPosition:CGPointMake(size.width/2,size.height/2 - 150)];
        [_familyPropertyLayer addChild:bar1];
        [_familyPropertyLayer addChild:bar2];
        [_familyPropertyLayer addChild:bar3];
        [_familyPropertyLayer addChild:bar4];
        
        CCLabelTTF *cardLabel = [CCLabelTTF labelWithString:@"cardLayerContent" fontName:@"Marker Felt" fontSize:20];
		cardLabel.position =  ccp( size.width /2 , size.height/2 );
		[_cardLayer addChild: cardLabel];
        
        CCLabelTTF *stateLabel = [CCLabelTTF labelWithString:@"stateContent" fontName:@"Marker Felt" fontSize:20];
		stateLabel.position =  ccp( size.width /2 , size.height/2 );
		[_stateLayer addChild: stateLabel];
        
        _multiplexLayer = [CCLayerMultiplex layerWithLayers:_familyPropertyLayer,_cardLayer,_stateLayer, nil];
        [_multiplexLayer switchTo:0];
        
        CCScrollView *familyScrollView = [CCScrollView viewWithViewSize:size container:_multiplexLayer];
        [familyScrollView setDirection:CCScrollViewDirectionVertical];
        [self addChild:familyScrollView];
        [familyScrollView setPosition:CGPointMake(0, 100)];
        [familyScrollView setContentOffset:CGPointMake(0, 0)];
        [familyScrollView setContentSize:CGSizeMake(size.width, 100)];
        
        _flipSpriteTest = [CCSprite spriteWithSpriteFrameName:@"Card1_1.png"];
        _flipSpriteTest2 = [CCSprite spriteWithSpriteFrameName:@"CardBack.png"];
        
        [self addChild:_flipSpriteTest];
        [self addChild:_flipSpriteTest2];
        [_flipSpriteTest setPosition:ccp(size.width/2,size.height/2)];
        [_flipSpriteTest2 setPosition:ccp(size.width/2,size.height/2)];
    }
    LOG_FUN_DID;
    return self;
}

#pragma mark - navigate
- (void)navigateToFamilyProperty:(id)sender
{
    CCLOG(@"navigateToFamilyProperty");
    CCMenuItemToggle *menuItemToggle = (CCMenuItemToggle *)sender;
    [menuItemToggle setIsEnabled:NO];
    [menuItemToggle setSelectedIndex:1];
    [_cardItemToggle setSelectedIndex:0];
    [_cardItemToggle setIsEnabled:YES];
    [_stateItemToggle setSelectedIndex:0];
    [_stateItemToggle setIsEnabled:YES];
    [_multiplexLayer switchTo:0];
}

- (void)navigateToCard:(id)sender
{
    CCLOG(@"navigateToCard");
    CCMenuItemToggle *menuItemToggle = (CCMenuItemToggle *)sender;
    [menuItemToggle setIsEnabled:NO];
    [menuItemToggle setSelectedIndex:1];
    [_familyPropertyItemToggle setSelectedIndex:0];
    [_familyPropertyItemToggle setIsEnabled:YES];
    [_stateItemToggle setSelectedIndex:0];
    [_stateItemToggle setIsEnabled:YES];
    [_multiplexLayer switchTo:1];
        
    float d = 0.25f;
    id a = [CCOrbitCamera actionWithDuration:d/2 radius:1 deltaRadius:0 angleZ:270 deltaAngleZ:90 angleX:0 deltaAngleX:0];
    id b = [CCOrbitCamera actionWithDuration:d/2 radius:1 deltaRadius:0 angleZ:0 deltaAngleZ:90 angleX:0 deltaAngleX:0];
    [_flipSpriteTest runAction:a];
    [_flipSpriteTest2 runAction:b];
}

- (void)navigateToState:(id)sender
{
    CCLOG(@"navigateToState");
    CCMenuItemToggle *menuItemToggle = (CCMenuItemToggle *)sender;
    [menuItemToggle setIsEnabled:NO];
    [menuItemToggle setSelectedIndex:1];
    [_familyPropertyItemToggle setSelectedIndex:0];
    [_familyPropertyItemToggle setIsEnabled:YES];
    [_cardItemToggle setSelectedIndex:0];
    [_cardItemToggle setIsEnabled:YES];
    [_multiplexLayer switchTo:2];
}

#pragma mark - UISwipeGesture switch-scenes
- (void)switchSceneToPawnShop:(id)sender
{
    [self closeCurtainWithSel:@selector(switchPawnShopScene:)];
}

- (void)switchPawnShopScene:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[PawnShopScene scene]];
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
                                                                                action:@selector(switchSceneToCardPlaying:)];
    self.swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchSceneToPawnShop:)];
    self.swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeRightGestureRecognizer];
    
    [super onEnter];
    LOG_FUN_DID;
}

- (void)onExit
{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeftGestureRecognizer];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRightGestureRecognizer];
    [super onExit];
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
