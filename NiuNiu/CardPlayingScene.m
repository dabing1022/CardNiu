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
#import "GCDAsyncSocketHelper.h"
#import "Game.h"
#import "GameData.h"
#import "User.h"
#import "AvatarInfoBox.h"
#import "ProfilePanel.h"

@implementation CardPlayingScene
@synthesize swipeLeftGestureRecognizer=_swipeLeftGestureRecognizer;
@synthesize swipeRightGestureRecognizer=_swipeRightGestureRecognizer;
static NSArray *_posArr;

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
	CardPlayingScene *layer = [CardPlayingScene node];
    [scene addChild: layer];
    layer.tag = kTagCardPlayingScene;
	return scene;
}

-(id)init
{
    if( (self=[super init]) ) {
        if(![[GCDAsyncSocketHelper sharedHelper]cardSocket])
            [[GCDAsyncSocketHelper sharedHelper]connectCardServer];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:[[GameData sharedGameData] player].userID forKey:@"userID"];
        NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_ENTER_CARD_PLAYING contentDic:dic];
        [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_ENTER_CARD_PLAYING socketType:CARD_SOCKET];
        [[GCDAsyncSocketHelper sharedHelper]readDataWithTimeout:-1 tag:0 socketType:CARD_SOCKET];
        
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"牌局" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
        label.opacity = 125;
		[self addChild: label];
        label.tag = 5;
        
        _posArr = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:POS_ID0],
                                            [NSValue valueWithCGPoint:POS_ID1],
                                            [NSValue valueWithCGPoint:POS_ID2],
                                            [NSValue valueWithCGPoint:POS_ID3],
                                            [NSValue valueWithCGPoint:POS_ID4],
                                            [NSValue valueWithCGPoint:POS_ID5], nil];
        [_posArr retain];
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

- (void)switchSceneToPawnShop:(id)sender
{
    [self closeCurtainWithSel:@selector(switchPawnShopScene:)];
}

- (void)switchPawnShopScene:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[PawnShopScene scene]];
}

#pragma mark - CurtainTransitionDelegateFun
- (void)closeCurtainWithSel:(SEL)sel
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    CCSprite *transitionUpSpr = [CCSprite spriteWithFile:@"transitionUp.png"];
    [self addChild:transitionUpSpr z:kTagCurtain tag:kTagCurtain];
    transitionUpSpr.position = ccp(size.width /2 , size.height + transitionUpSpr.contentSize.height / 2);
    
    CCSprite *transitionDownSpr = [CCSprite spriteWithFile:@"transitionDown.png"];
    [self addChild:transitionDownSpr z:kTagCurtain tag:kTagCurtain];
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
    [self addChild:transitionUpSpr z:kTagCurtain tag:kTagCurtain];
    transitionUpSpr.position = ccp(size.width /2 , size.height - transitionUpSpr.contentSize.height / 2);
    
    CCSprite *transitionDownSpr = [CCSprite spriteWithFile:@"transitionDown.png"];
    [self addChild:transitionDownSpr z:kTagCurtain tag:kTagCurtain];
    transitionDownSpr.position = ccp(size.width / 2, 0 + transitionDownSpr.contentSize.height / 2);
    
    id moveDown = [CCMoveTo actionWithDuration:0.5 position:ccp(size.width / 2, 0 - transitionUpSpr.contentSize.height / 2)];
    id moveUp = [CCMoveTo actionWithDuration:0.5 position:ccp(size.width / 2, size.height + transitionUpSpr.contentSize.height / 2)];
    
    [transitionUpSpr runAction:moveUp];
    [transitionDownSpr runAction:moveDown];
}

- (void)onEnter
{
    if([[GCDAsyncSocketHelper sharedHelper]cardSocket].isDisconnected)
    {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCSprite *transitionUpSpr = [CCSprite spriteWithFile:@"transitionUp.png"];
        [self addChild:transitionUpSpr];
        transitionUpSpr.position = ccp(size.width /2 , size.height - transitionUpSpr.contentSize.height / 2);
        
        CCSprite *transitionDownSpr = [CCSprite spriteWithFile:@"transitionDown.png"];
        [self addChild:transitionDownSpr];
        transitionDownSpr.position = ccp(size.width / 2, 0 + transitionDownSpr.contentSize.height / 2);
        CCLOG(@"showPic");
    }else{
        [self openCurtain];
        CCLOG(@"openCurtain");
    }
    self.swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(switchSceneToPawnShop:)];
    self.swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeLeftGestureRecognizer];
    
    self.swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchSceneToFamilyProperty:)];
    self.swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeRightGestureRecognizer];
    
    [super onEnter];
    LOG_FUN_DID;
}

- (void)onExit
{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeftGestureRecognizer];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRightGestureRecognizer];
    [_activityIndicatorView stopAnimating];
    [_activityIndicatorView removeFromSuperview];
    
    [super onExit];
    LOG_FUN_DID;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d", (int) buttonIndex);
    if (buttonIndex == 1) { // OK pushed
        CCLOG(@"sldfjalsfjlasfadsj");
    } else {
        
    }
}

#pragma mark - SOCKET数据更新UI
//等待分配进桌
- (void)waitingAssign
{
    AvatarInfoBox *playerBox = [AvatarInfoBox infoBoxWithUserData:[[GameData sharedGameData]player]];
    [self addChild:playerBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
    [playerBox setPosition:POS_ID2];
    _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[[CCDirector sharedDirector] view] addSubview:_activityIndicatorView];
    CGSize size = [[CCDirector sharedDirector] winSize];
    _activityIndicatorView.center = ccp(size.width/2, size.height/2);
    [_activityIndicatorView startAnimating];
    CCLOG(@"------>正在分配玩家，请稍后...");
}

//分配进桌
- (void)assignInDesk
{
    CCLOG(@"------>分配进桌");
    [_activityIndicatorView stopAnimating];
    NSArray *allPlayers = [[[GameData sharedGameData]userDic]allValues];
    CCLOG(@"allplayers length:%d", [allPlayers count]);
    for(User *user in allPlayers)
    {
        if(user.userID == [[GameData sharedGameData]player].userID) continue;
        AvatarInfoBox *playerBox = [AvatarInfoBox infoBoxWithUserData:user];
        [self addChild:playerBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
        [playerBox setPosition:[[_posArr objectAtIndex:user.posID]CGPointValue]];
        CCLOG(@"1111%f, %f", [[_posArr objectAtIndex:user.posID]CGPointValue].x, [[_posArr objectAtIndex:user.posID]CGPointValue].y);
    }
}

//有其他玩家进入
- (void)otherPlayerIn:(User *)user
{
    CCLOG(@"------>有其他玩家进入");
    AvatarInfoBox *playerBox = [AvatarInfoBox infoBoxWithUserData:user];
    [self addChild:playerBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
    [playerBox setPosition:[[_posArr objectAtIndex:user.posID]CGPointValue]];
    
}

- (void)viewProfile:(User *)user
{
    CCLOG(@"CardPlayingScnene--->viewProfile");
    ProfilePanel *profilePanel = [ProfilePanel profileWithUser:user];
    [self addChild:profilePanel];
}


#pragma mark - dealloc
- (void) dealloc
{
    [_posArr release];
	[_swipeLeftGestureRecognizer release];
    _swipeLeftGestureRecognizer = nil;
    [_swipeRightGestureRecognizer release];
    _swipeRightGestureRecognizer = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
    
	[super dealloc];
}


@end
