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
        
        CCLabelTTF *familyPropertyLabel = [CCLabelTTF labelWithString:@"familyPropertyContent" fontName:@"Marker Felt" fontSize:20];
		familyPropertyLabel.position =  ccp( size.width /2 , size.height/2 );
		[_familyPropertyLayer addChild: familyPropertyLabel];
        
        CCLabelTTF *cardLabel = [CCLabelTTF labelWithString:@"cardLayerContent" fontName:@"Marker Felt" fontSize:20];
		cardLabel.position =  ccp( size.width /2 , size.height/2 );
		[_cardLayer addChild: cardLabel];
        
        CCLabelTTF *stateLabel = [CCLabelTTF labelWithString:@"stateContent" fontName:@"Marker Felt" fontSize:20];
		stateLabel.position =  ccp( size.width /2 , size.height/2 );
		[_stateLayer addChild: stateLabel];
        
        _multiplexLayer = [CCLayerMultiplex layerWithLayers:_familyPropertyLayer,_cardLayer,_stateLayer, nil];
//        [self addChild:_multiplexLayer];
        [_multiplexLayer switchTo:0];
        
        CGSize size2 = CGSizeMake(0, 150);
        CCScrollView *familyScrollView = [CCScrollView viewWithViewSize:size container:_multiplexLayer];
        [familyScrollView setDirection:CCScrollViewDirectionVertical];
        [self addChild:familyScrollView];
//        [familyScrollView setPosition:CGPointMake(50, 150)];
    }
    LOG_FUN_DID;
    return self;
}

#pragma mark - navigate
- (void)navigateToFamilyProperty:(id)sender
{
    CCLOG(@"navigateToFamilyProperty");
    CCMenuItemToggle *menuItemToggle = (CCMenuItemToggle *)sender;
    if(menuItemToggle.selectedItem == _familyPropertyMenuItemSelected){
        [_cardItemToggle setSelectedIndex:0];
        [_stateItemToggle setSelectedIndex:0];
        [_multiplexLayer switchTo:0];
    }else{
         CCLOG(@"00");
    }
}

- (void)navigateToCard:(id)sender
{
    CCLOG(@"navigateToCard");
    CCMenuItemToggle *menuItemToggle = (CCMenuItemToggle *)sender;
    if(menuItemToggle.selectedItem == _cardMenuItemSelected){
        [_familyPropertyItemToggle setSelectedIndex:0];
        [_stateItemToggle setSelectedIndex:0];
        [_multiplexLayer switchTo:1];
    }else{
        CCLOG(@"00");
    }
}

- (void)navigateToState:(id)sender
{
    CCLOG(@"navigateToState");
    CCMenuItemToggle *menuItemToggle = (CCMenuItemToggle *)sender;
    if(menuItemToggle.selectedItem == _stateMenuItemSelected){
        [_familyPropertyItemToggle setSelectedIndex:0];
        [_cardItemToggle setSelectedIndex:0];
        [_multiplexLayer switchTo:2];
    }else{
        CCLOG(@"00");
    }
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
