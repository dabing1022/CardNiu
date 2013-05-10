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
#import "UserCard.h"
#import "ReadingCardsLayer.h"
#import "CardsHelper.h"
#import "CardPlayingHandler.h"
#import "PopUpTipView.h"


@implementation CardPlayingScene
@synthesize swipeLeftGestureRecognizer=_swipeLeftGestureRecognizer;
@synthesize swipeRightGestureRecognizer=_swipeRightGestureRecognizer;
@synthesize popUpTipView=_popUpTipView;
@synthesize betRatioMenu=_betRatioMenu;

static NSArray *_avatarPosArr;
static NSArray *_cardPosArr;
static NSArray *_betBoxesPosArr;//下注前的位置
static NSArray *_betBoxesFlyToPosArr;//下注后飘向的显示位置

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
        
        _allUserCardsArr = [[NSMutableArray alloc]initWithCapacity:TOTAL_CARD_NUM];
        _betResultDic = [[NSMutableDictionary alloc]initWithCapacity:MAX_PLAYERS_NUM];
        _avatarDic = [[NSMutableDictionary alloc]initWithCapacity:MAX_PLAYERS_NUM];
        _playerResultNiuSymbolDic = [[NSMutableDictionary alloc]initWithCapacity:MAX_PLAYERS_NUM];
        _playerWinLoseCoinTBDic = [[NSMutableDictionary alloc]initWithCapacity:MAX_PLAYERS_NUM];
                
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"牌局" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
        label.opacity = 125;
		[self addChild: label];
        label.tag = 5;
        
        [self drawGrabZ];
        [self drawCountDownLabelTTF];
        [self drawChangeTableMenu];
#ifdef DEBUG_CONSOLE
        [self drawDebugConsole];
#endif
        
        _avatarPosArr = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:AVARTAR_POS_ID0],
                                                  [NSValue valueWithCGPoint:AVARTAR_POS_ID1],
                                                  [NSValue valueWithCGPoint:AVARTAR_POS_ID2],
                                                  [NSValue valueWithCGPoint:AVARTAR_POS_ID3],
                                                  [NSValue valueWithCGPoint:AVARTAR_POS_ID4],
                                                  [NSValue valueWithCGPoint:AVARTAR_POS_ID5], nil];
        [_avatarPosArr retain];
        
        _cardPosArr = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CARD_POS_ID2],
                                                [NSValue valueWithCGPoint:CARD_POS_ID3],
                                                [NSValue valueWithCGPoint:CARD_POS_ID4],
                                                [NSValue valueWithCGPoint:CARD_POS_ID5],
                                                [NSValue valueWithCGPoint:CARD_POS_ID0],
                                                [NSValue valueWithCGPoint:CARD_POS_ID1], nil];
        [_cardPosArr retain];
        
        _betBoxesPosArr = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:BET_BOX_POS_ID0],
                                                    [NSValue valueWithCGPoint:BET_BOX_POS_ID1],
                                                    [NSValue valueWithCGPoint:BET_BOX_POS_ID2],
                                                    [NSValue valueWithCGPoint:BET_BOX_POS_ID3], nil];
        [_betBoxesPosArr retain];
        
        _betBoxesFlyToPosArr = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:BET_BOX_FLYTO_POS_ID0],
                                                         [NSValue valueWithCGPoint:BET_BOX_FLYTO_POS_ID1],
                                                         [NSValue valueWithCGPoint:BET_BOX_FLYTO_POS_ID2],
                                                         [NSValue valueWithCGPoint:BET_BOX_FLYTO_POS_ID3],
                                                         [NSValue valueWithCGPoint:BET_BOX_FLYTO_POS_ID4],
                                                         [NSValue valueWithCGPoint:BET_BOX_FLYTO_POS_ID5], nil];
        [_betBoxesFlyToPosArr retain];

        
        //清空玩家本人上把的牌数据
        [self clearPlayerData];
        
        //添加观察者-亮牌
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finalShowCards:) name:@"startShowCardsResult" object:nil];
        
        _playerInfoBox = nil;
        self.popUpTipView = nil;
        
        _isThinkingBet = NO;
        _isClosing5cards = NO;
        _isOpening5cards = NO;
        _isReading5cards = NO;
    }
    LOG_FUN_DID;
    return self;
}

#pragma mark - drawStuff
- (void)drawCountDownLabelTTF
{
    _countDownLabelTTF = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:24];
    CGSize size = [[CCDirector sharedDirector]winSize];
    [_countDownLabelTTF setPosition:CGPointMake(size.width/2, size.height/2)];
    [self addChild:_countDownLabelTTF z:kTagCountDownLabelTTF tag:kTagCountDownLabelTTF];
    [_countDownLabelTTF setVisible:NO];
}

- (void)drawGrabZ
{
    _menuItemGrabZ = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"grabZ.png"]
                                            selectedSprite:[CCSprite spriteWithSpriteFrameName:@"grabZ.png"]
                                                     block:^(id sender){
                                                         [self sendServerWithGrab:YES];
                                                     }];
    _menuItemNotGrabZ = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"notGrabZ.png"]
                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"notGrabZ.png"]
                                                        block:^(id sender){
                                                            [self sendServerWithGrab:NO];
                                                        }];

    _menuGrabZ = [CCMenu menuWithItems:_menuItemGrabZ,_menuItemNotGrabZ, nil];
    [_menuGrabZ alignItemsHorizontallyWithPadding:20];
    [self addChild:_menuGrabZ z:kTagMenuGrab tag:kTagMenuGrab];
    _menuGrabZ.position = ccp(252, 92);
    [_menuGrabZ setVisible:NO];
}

- (void)drawChangeTableMenu
{
    _changeTableItemTTF = [CCMenuItemFont itemWithString:@"changeTable" block:^(id sender){
        CCLOG(@"玩家请求换桌");
        [self sendServerWithChangeTableMsg];
    }];
    
    _changeTableMenu = [CCMenu menuWithItems:_changeTableItemTTF, nil];
    [self addChild:_changeTableMenu z:kTagChangeTable tag:kTagChangeTable];
    [_changeTableMenu setPosition:CGPointMake(200, 150)];
    [_changeTableMenu setVisible:NO];
}

- (void)drawPlayersAvatarInfoBox
{
    NSMutableDictionary *userDic = [[GameData sharedGameData]userDic];
    for(NSString *key in userDic){
        User *user = [userDic objectForKey:key];
        if([user.userID isEqualToString:[[GameData sharedGameData]player].userID]) continue;
        AvatarInfoBox *playerBox = [AvatarInfoBox infoBoxWithUserData:user];
        [self addChild:playerBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
        [playerBox setPosition:[[_avatarPosArr objectAtIndex:user.posID]CGPointValue]];
        [_avatarDic setObject:playerBox forKey:user.userID];
    }
}

- (void)drawDebugConsole
{
    debugConsole = [CCLabelTTF labelWithString:@"debugConsole" fontName:@"Arial" fontSize:12];
    [self addChild:debugConsole];
    [debugConsole setPosition:ccp(200, 200)];
    [debugConsole setHorizontalAlignment:kCCTextAlignmentLeft];
}

#pragma mark - UISwipeGesture switch-scenes
- (void)switchSceneToFamilyProperty:(id)sender
{
    [self sendServerWithLeaveOutMsg];
    [self closeCurtainWithSel:@selector(switchFamilyPropertyScene:)];
}

- (void)switchFamilyPropertyScene:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[FamilyPropertyScene scene]];
}

- (void)switchSceneToPawnShop:(id)sender
{
    [self sendServerWithLeaveOutMsg];
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
    [self removePopUpTipView];
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

#pragma mark - onEnter onExit
- (void)onEnter
{
    [self showPopTipViewWithTipType:kTipType_CONNECT_CARD_SERVER];
    
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
    [self removePopUpTipView];
    
    //移除观察者
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"startShowCardsResult" object:nil];
    
    [self unscheduleAllSelectors];
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
    if(!_playerInfoBox){
        _playerInfoBox = [AvatarInfoBox infoBoxWithUserData:[[GameData sharedGameData]player]];
        [self addChild:_playerInfoBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
        [_playerInfoBox setPosition:AVARTAR_POS_ID2];
        [_avatarDic setObject:_playerInfoBox forKey:[[GameData sharedGameData]player].userID];        
    }

    [self showPopTipViewWithTipType:kTipType_WAIT_FOR_ASSIGN_IN_DESK];
    
    CCLOG(@"------>正在分配玩家，请稍后...");
    [debugConsole setString:@"正在分配玩家，请稍候"];
    //10s发送一次心跳包
    [self schedule:@selector(sendHeartBeat:) interval:7];
}

//当用户金币不足或者掉线重连上把结束的时候被强制换桌
- (void)forcedChangeTable
{
    CCLOG(@"被强制换桌");
    [self showPopTipViewWithTipType:kTipType_WAIT_FOR_ASSIGN_IN_DESK];
    [self removeOtherPlayerAvatarInfoBoxExceptMe];
    [self clearForRestart];
}

- (void)removeOtherPlayerAvatarInfoBoxExceptMe
{
    for(NSString *key in [[GameData sharedGameData]userDic]){
        if([key isEqualToString:[[[GameData sharedGameData]player]userID]])
            continue;
        [self removeChild:[_avatarDic objectForKey:key] cleanup:YES];
        [_avatarDic removeObjectForKey:key];
    }
}

//分配进桌
- (void)assignInDesk
{
    CCLOG(@"------>分配进桌");
    [self removePopUpTipView];
    [_changeTableMenu setVisible:YES];
    
    User *playerSelf = [[GameData sharedGameData]player];
    if(playerSelf.canGrabZ && playerSelf.canBet){
        //能叫庄也能下注，则进来的阶段为抢庄阶段
        CCLOG(@"玩家进来时刻为：抢庄阶段进入");
        [self initEnterViewWithState:kEnterState_GRABZ];
    }else if(!playerSelf.canGrabZ && playerSelf.canBet){
        //不能叫庄但能下注，则进来的阶段为庄家已经确定后下注前进入
        CCLOG(@"玩家进来时刻为：庄家已经确定后下注前进入");
        [self initEnterViewWithState:kEnterState_HASNOT_BET];
    }else if(!playerSelf.canGrabZ && !playerSelf.canBet){
        //不能叫庄也不能下注，则进来的阶段为下注后进入
        CCLOG(@"玩家进来时刻为：下注后进入");
        [self initEnterViewWithState:kEnterState_WATCHER];
    }
    [debugConsole setString:@"分配进桌"];
}

- (void)initEnterViewWithState:(int)state
{
    switch (state) {
        case kEnterState_GRABZ:{
            [self drawPlayersAvatarInfoBox];
            if([[[[GameData sharedGameData]userDic]allKeys]count] > 2)
                [self grabZ:nil];
            break;
        }
        case kEnterState_HASNOT_BET:{
            [self drawPlayersAvatarInfoBox];
            [self grabResult:[[GameData sharedGameData] zUserID]];
            [self playSendCardsAnimation:NO];
            [self showPlayersBetRatio];
            break;
        }
        case kEnterState_WATCHER:{
            [self drawPlayersAvatarInfoBox];
            [self grabResult:[[GameData sharedGameData] zUserID]];
            [self showPlayersBetRatio];
            [self playSendCardsAnimation:NO];
            [self showPlayersFinalCards];
            break;
        }
        default:
            CCLOG(@"进入阶段数据错误");
            break;
    }
}

//显示已经下注的玩家的注
- (void)showPlayersBetRatio
{
    NSMutableDictionary *userDic = [[GameData sharedGameData]userDic];
    for(NSString *key in userDic){
        User *user = [userDic objectForKey:key];
        if(user.betRatio > 0){
            NSNumber *ratio = [NSNumber numberWithInt:user.betRatio];
            NSString *userID = user.userID;
            NSDictionary *betDic = [NSDictionary dictionaryWithObjectsAndKeys:ratio,@"ratio",userID,@"userID", nil];
            [self showPlayerBetResult:betDic];
        }
    }
}

//显示未亮牌和亮的牌
- (void)showPlayersFinalCards
{  
    NSMutableDictionary *userDic = [[GameData sharedGameData]userDic];
    for(NSString *key in userDic){
        User *user = [userDic objectForKey:key];
        if(user.showCardsDataArr){
            [self showResultNiuWithType:user.cardType cardsDataSendToServer:user.showCardsDataArr user:user];
        }
    }
}

//有其他玩家进入
- (void)otherPlayerIn:(User *)user
{
    CCLOG(@"------>有其他玩家进入");
    CCLOG(@"------>进入的玩家的userID为：%@", user.userID);
    AvatarInfoBox *playerBox = [AvatarInfoBox infoBoxWithUserData:user];
    [self addChild:playerBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
    [playerBox setPosition:[[_avatarPosArr objectAtIndex:user.posID]CGPointValue]];
    [_avatarDic setObject:playerBox forKey:user.userID];
    [debugConsole setString:@"有其他玩家进入"];
}

- (void)otherPlayerOut:(User *)user
{
    CCLOG(@"------>有其他玩家离开");
    CCLOG(@"------>离开的玩家的userID为：%@", user.userID);
    //清除玩家头像信息
    AvatarInfoBox *playerBox = [_avatarDic objectForKey:user.userID];
    [self removeChild:playerBox cleanup:YES];
    [_avatarDic removeObjectForKey:user.userID];
    CCLOG(@"清除离开玩家头像完毕");
    
    //清除玩家下注信息(如果有的话)
    CCSprite *betBox = [_betResultDic objectForKey:user.userID];
    if(betBox){
        [self removeChild:betBox cleanup:YES];
        [_betResultDic removeObjectForKey:user.userID];
    }
    
    //清除玩家摊的牌和牌型结果(如果有的话)
    if([[user.user5cards objectAtIndex:0]isFront]){
        for(UserCard *card in user.user5cards){
            [self removeChild:card cleanup:YES];
        }
        [user.user5cards removeAllObjects];
        
        //牌型结果
        CCSprite *resultNiu = [_playerResultNiuSymbolDic objectForKey:user.userID];
        [self removeChild:resultNiu cleanup:YES];
        [_playerResultNiuSymbolDic removeObjectForKey:user.userID];
    }
    
    //清除winLose金币(如果有的话)
    CCLabelTTF *winLoseCoinTB = [_playerWinLoseCoinTBDic objectForKey:user.userID];
    if(winLoseCoinTB){
        [self removeChild:winLoseCoinTB cleanup:YES];
        [_playerWinLoseCoinTBDic removeObjectForKey:user.userID];
    }

    //只剩玩家自己
    if([[[GameData sharedGameData]userDic]count] == 1){
        [self clearForRestart];
        [self allowLeavingOut];
    }
}

//查看玩家具体信息
- (void)viewProfile:(User *)user
{
    CCLOG(@"CardPlayingScnene--->viewProfile");
    ProfilePanel *profilePanel = [ProfilePanel profileWithUser:user];
    [self addChild:profilePanel];
}

//抢庄和发牌
- (void)grabZ:(NSString *)zUserID
{
    [self clearForRestart];
    //NSString为nil或者@""的时候length为0
    if([zUserID length] == 0){//没有庄家
        CCLOG(@"没有庄家，进行抢庄");
        [_menuGrabZ setVisible:YES];
        [self countDownBeginWith:kCDTimeGrabZ];
    }else{//庄家已经存在
        CCLOG(@"庄家已经存在，不用抢庄");
    }
    [self playSendCardsAnimation:YES];
    [debugConsole setString:@"grabz"];
}


#pragma mark - CountDown
- (void)countDownBeginWith:(int)countDownTime
{
    _timeLeft = countDownTime;
    [_countDownLabelTTF setVisible:YES];
    [_countDownLabelTTF setString:@""];
    [self unschedule:@selector(countDownWithGrabZType:)];
    [self unschedule:@selector(countDownWithBetType:)];
    [self unschedule:@selector(countDownWithReadCardsType:)];
    switch (countDownTime) {
        case kCDTimeGrabZ:
            [self schedule:@selector(countDownWithGrabZType:) interval:1.0];
            break;
        case kCDTimeBet:
            [self schedule:@selector(countDownWithBetType:) interval:1.0];
            break;
        case kCDTimeReadCards:
            [self schedule:@selector(countDownWithReadCardsType:) interval:1.0];
            break;
        case kCDTimeStop:
            break;
        default:
            NSAssert(NO, @"无效倒计时类型");
            break;
    }
    _countDownType = countDownTime;
}

- (void)countDownWithGrabZType:(ccTime)dt
{
    [_countDownLabelTTF setString:[NSString stringWithFormat:@"0%d",_timeLeft]];
    CCLOG(@"Time left %d", _timeLeft);
    _timeLeft --;
    if(_timeLeft < 0){
        [_countDownLabelTTF setVisible:NO];
        [self unschedule:@selector(countDownWithGrabZType:)];
        CCLOG(@"GrabZ TIME UP!");
        if(_menuGrabZ.visible){
            [_menuGrabZ setVisible:NO];
            [self fobiddenLeavingOut];
        }
    }
}

- (void)countDownWithBetType:(ccTime)dt
{
    [_countDownLabelTTF setString:[NSString stringWithFormat:@"0%d",_timeLeft]];
    CCLOG(@"Time left %d", _timeLeft);
    _timeLeft --;
    if(_timeLeft < 0){
        [_countDownLabelTTF setVisible:NO];
        [self unschedule:@selector(countDownWithBetType:)];
        [self removeBetRatioMenu];
        CCLOG(@"Bet TIME UP!");
    }
}

- (void)countDownWithReadCardsType:(ccTime)dt
{
    [_countDownLabelTTF setString:[NSString stringWithFormat:@"%d",_timeLeft]];
    CCLOG(@"Time left %d", _timeLeft);
    _timeLeft --;
    if(_timeLeft < 0){
        [_countDownLabelTTF setVisible:NO];
        [self unschedule:@selector(countDownWithReadCardsType:)];
        CCLOG(@"ReadCards TIME UP!");
        [self removeReadingCardLayer];
    }
}

//播放发牌动画
- (void)playSendCardsAnimation:(BOOL)animate
{
    CGSize size = [[CCDirector sharedDirector]winSize];
    if(animate){
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        for (int i = 0; i < TOTAL_CARD_NUM; i++) {
            UserCard *card = [UserCard cardWithBack];
            [self addChild:card];
            [card setPosition:CGPointMake([card boundingBox].size.width/2, size.height-[card boundingBox].size.height/2)];
            [_allUserCardsArr addObject:card];
        }
        [self sendCardsWithAnimation];
        [pool release];
    }else{
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        [self drawAllPlayersBackCards];
        [pool release];
    }
    
    NSMutableDictionary *userDic = [[GameData sharedGameData]userDic];
    for(NSString *key in userDic){
        User *user = [userDic objectForKey:key];
        int i = (user.posID + 6 - 2) % 6;
        for(; i < TOTAL_CARD_NUM; i += 6){
            UserCard *userCard = [_allUserCardsArr objectAtIndex:i];
            [user.user5cards addObject:userCard];
        }
    }
}

- (void)drawAllPlayersBackCards
{
    for (int i = 0; i < TOTAL_CARD_NUM; i++) {
        UserCard *card = [UserCard cardWithBack];
        [self addChild:card];
        int index = i % MAX_PLAYERS_NUM;
        int turn = i / MAX_PLAYERS_NUM;
        CGPoint firstCardPos = [[_cardPosArr objectAtIndex:index]CGPointValue];
        CGPoint targetCardPos = CGPointMake(firstCardPos.x+turn*CARD_SPACE0, firstCardPos.y);
        [card setPosition:targetCardPos];
        [_allUserCardsArr addObject:card];
    }
}

- (void)sendCardsWithAnimation
{
    for(int i = 0; i < TOTAL_CARD_NUM; i++)
    {
        UserCard *card = (UserCard *)[_allUserCardsArr objectAtIndex:i];
        int index = i % MAX_PLAYERS_NUM;
        int turn = i / MAX_PLAYERS_NUM;
        CGPoint firstCardPos = [[_cardPosArr objectAtIndex:index]CGPointValue];
        CGPoint targetCardPos = CGPointMake(firstCardPos.x+turn*CARD_SPACE0, firstCardPos.y);
        id delayAction = [CCDelayTime actionWithDuration:0.2*i];
        
        CGFloat duration = ccpDistance(card.position, targetCardPos) / CARD_SPEED;
        id flyToCardArea = [CCMoveTo actionWithDuration:duration position:targetCardPos];
        [card runAction:[CCSequence actions:delayAction,flyToCardArea,nil]];
    }
}

//抢庄结果
- (void)grabResult:(NSString *)zUserID
{
    _zSymbol = [CCSprite spriteWithSpriteFrameName:@"ZSymbol.png"];
    [self addChild:_zSymbol z:kTagZSymbol tag:kTagZSymbol];
    CGSize size = [[CCDirector sharedDirector]winSize];
    [_zSymbol setPosition:CGPointMake(size.width/2, size.height/2)];
    
    User *zUser = [[[GameData sharedGameData]userDic]objectForKey:zUserID];
    CGPoint targetPos = [[_avatarPosArr objectAtIndex:zUser.posID]CGPointValue];
    id flyTo = [CCMoveTo actionWithDuration:0.5 position:targetPos];
    [_zSymbol runAction:flyTo];
    
    [_menuGrabZ setVisible:NO];
    [self countDownBeginWith:kCDTimeBet];
}

//开始下注
- (void)startBet:(NSArray *)betArr
{
    [_menuGrabZ setVisible:NO];
    if(_isThinkingBet)  return;
    for(int i = 0;i < 4;i++)
    {
        NSDictionary *aBetBoxInfoDic = (NSDictionary *)[betArr objectAtIndex:i];
        int ratio = [[aBetBoxInfoDic objectForKey:@"ratio"]intValue];
        BOOL state = [[aBetBoxInfoDic objectForKey:@"status"]boolValue];
        CCSprite *nomal = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"betRatioNomal%d.png",ratio]];
        CCSprite *disabled = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"betRatioDisabled%d.png",ratio]];
        if(i == 0){
            _betRatioItem1 = [CCMenuItemImage itemWithNormalSprite:nomal selectedSprite:nil disabledSprite:disabled
                                                             block:^(id sender){
                                                                 [self sendServerWithBetRatio:ratio];
                                                             }];
            state?(_betRatioItem1.isEnabled=YES):(_betRatioItem1.isEnabled=NO);
            [_betRatioItem1 setPosition:[[_betBoxesPosArr objectAtIndex:i] CGPointValue]];
        }else if(i == 1){
            _betRatioItem2 = [CCMenuItemImage itemWithNormalSprite:nomal selectedSprite:nil disabledSprite:disabled
                                                             block:^(id sender){
                                                                 [self sendServerWithBetRatio:ratio];
                                                             }];
            state?(_betRatioItem2.isEnabled=YES):(_betRatioItem2.isEnabled=NO);
            [_betRatioItem2 setPosition:[[_betBoxesPosArr objectAtIndex:i] CGPointValue]];
        }else if(i == 2){
            _betRatioItem3 = [CCMenuItemImage itemWithNormalSprite:nomal selectedSprite:nil disabledSprite:disabled
                                                             block:^(id sender){
                                                                 [self sendServerWithBetRatio:ratio];
                                                             }];
            state?(_betRatioItem3.isEnabled=YES):(_betRatioItem3.isEnabled=NO);
            [_betRatioItem3 setPosition:[[_betBoxesPosArr objectAtIndex:i] CGPointValue]];
        }else if(i == 3){
            _betRatioItem4 = [CCMenuItemImage itemWithNormalSprite:nomal selectedSprite:nil disabledSprite:disabled
                                                             block:^(id sender){
                                                                 [self sendServerWithBetRatio:ratio];
                                                             }];
            state?(_betRatioItem4.isEnabled=YES):(_betRatioItem4.isEnabled=NO);
            [_betRatioItem4 setPosition:[[_betBoxesPosArr objectAtIndex:i] CGPointValue]];
        }
    }
    self.betRatioMenu = [CCMenu menuWithItems:_betRatioItem1,_betRatioItem2,_betRatioItem3,_betRatioItem4, nil];
    [_betRatioMenu setPosition:CGPointZero];
    [_betRatioMenu setScale:0.8];
    [self addChild:_betRatioMenu z:kTagBetRatioMenu tag:kTagBetRatioMenu];
    
    _isThinkingBet = YES;
    [debugConsole setString:@"startBet"];
}

- (void)sendServerWithGrab:(BOOL)choice
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:choice] forKey:@"grab"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_GRAB_RESULT contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:0 socketType:CARD_SOCKET];
    [_menuGrabZ setVisible:NO];
    [self fobiddenLeavingOut];
}

- (void)sendServerWithBetRatio:(int)ratio
{
    [self fobiddenLeavingOut];
    [self removeBetRatioMenu];
    
    CCSprite *betBox = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"betRatioNomal%d.png",ratio]];
    [self addChild:betBox z:kTagBetRatioMenu];
    CGPoint targetPos = [[_betBoxesFlyToPosArr objectAtIndex:2]CGPointValue];
    CCLOG(@"tagetPos :%f, %f", targetPos.x, targetPos.y);
    [betBox setPosition:targetPos];
    [_betResultDic setObject:betBox forKey:[[[GameData sharedGameData]player]userID]];
    
    NSDictionary *betChoice = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:ratio] forKey:@"ratio"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_START_BET contentDic:betChoice];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_START_BET socketType:CARD_SOCKET];
}

- (void)sendServerWithChangeTableMsg
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[[GameData sharedGameData] player].userID forKey:@"userID"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_CHANGE_TABLE contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_CHANGE_TABLE socketType:CARD_SOCKET];
}

- (void)sendServerWithLeaveOutMsg
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[[GameData sharedGameData] player].userID forKey:@"userID"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_QUIT_CARD_GAME contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_QUIT_CARD_GAME socketType:CARD_SOCKET];
    [[GCDAsyncSocketHelper sharedHelper]disconnectCardServer];
}

- (void)sendServerWithHeartBeat
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[[GameData sharedGameData] player].userID forKey:@"userID"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_HEART_BEAT contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_HEART_BEAT socketType:CARD_SOCKET];    
}

- (void)sendHeartBeat:(ccTime)dt
{
    [self sendServerWithHeartBeat];
}

//处理其他玩家下注结果
- (void)showPlayerBetResult:(NSDictionary *)betResult
{
    int ratio = [[betResult objectForKey:@"ratio"]intValue];
    NSString *userID = [betResult objectForKey:@"userID"];
    //用于home键游戏进入后台再次唤醒
    if([userID isEqualToString:[[[GameData sharedGameData]player]userID]]){
        if([self getChildByTag:kTagBetRatioMenu])
            [self removeBetRatioMenu];
    }
    CCSprite *betBox = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"betRatioNomal%d.png",ratio]];
    [self addChild:betBox z:kTagBetRatioMenu];
    
    User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
    CGPoint targetPos = [[_betBoxesFlyToPosArr objectAtIndex:user.posID]CGPointValue];
    [betBox setPosition:targetPos];
    
    [_betResultDic setObject:betBox forKey:userID];
    [debugConsole setString:[NSString stringWithFormat:@"显示玩家下注结果 userID:%@, ratio:%d", userID, ratio]];
}

//进入看牌阶段
- (void)startReadingCards:(NSArray *)cardArray
{
    CCLOG(@"startReadingCards");
    if(_isClosing5cards || _isOpening5cards || _isReading5cards)    return;
    [self countDownBeginWith:kCDTimeReadCards];
     
    _isClosing5cards = YES;
    [self closeThenOpenCards:cardArray];
    [debugConsole setString:[NSString stringWithFormat:@"开始看牌"]];
}

//进入看牌阶段后，先收拢牌然后展开牌的动画效果
//收拢的时候5张牌为背面牌，展开的时候前4张为正面牌，第5张牌为背面牌，需要玩家去点击
- (void)closeThenOpenCards:(NSArray *)cardArray
{
    CCLOG(@"closeThenOpenCards");
    CGPoint closePos = [[_cardPosArr objectAtIndex:0]CGPointValue];
    //收拢牌
    NSMutableArray *playerCardsArr = [[[GameData sharedGameData]player]user5cards];
    for(UserCard *card in playerCardsArr){
        id moveToClosePos = [CCMoveTo actionWithDuration:0.5 position:closePos];
        id easeOut = [CCEaseInOut  actionWithAction:moveToClosePos rate:2];
        [card runAction:easeOut];
    }
    //打开牌
    [self scheduleOnce:@selector(open5cards) delay:0.8];
    _isClosing5cards = NO;
}

- (void)open5cards
{
    [self unschedule:@selector(open5cards)];
    _isOpening5cards = YES;
    NSMutableArray *cardDataArr = [[GameData sharedGameData]player].cardsDataArr;
    CGPoint openPos = [[_cardPosArr objectAtIndex:0]CGPointValue];
    NSMutableArray *playerCardsArr = [[[GameData sharedGameData]player]user5cards];
    for(int i = 0; i < 5; i++)
    {
        UserCard *card = (UserCard *)[playerCardsArr objectAtIndex:i];
        CardData *cardData = [cardDataArr objectAtIndex:i];
        id moveToOpenPos = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(openPos.x + i * 50, openPos.y)];
        id easeOut = [CCEaseOut actionWithAction:moveToOpenPos rate:2];
        if(i != 4){
            [card setFrontFace:cardData];
        }
        [card runAction:easeOut];
    }
    
    [self scheduleOnce:@selector(addReadingCardsLayer) delay:1];
    _isOpening5cards = NO;
}

//读牌层
- (void)addReadingCardsLayer
{
    [self unschedule:@selector(addReadingCardsLayer)];
    [self hidePlayerCards:YES];
    _isReading5cards = YES;
    
    _readingCardsLayer = [ReadingCardsLayer layerWithCardsArray:[[GameData sharedGameData]player].cardsDataArr];
    [self addChild:_readingCardsLayer z:kTagReadingCardsLayer tag:kTagReadingCardsLayer];    
}

- (void)hidePlayerCards:(BOOL)hide
{
    NSMutableArray *playerCardsArr = [[[GameData sharedGameData]player]user5cards];
    for(UserCard *card in playerCardsArr){
        [card setVisible:!hide];
    }
}

//玩家自己亮牌
- (void)finalShowCards:(NSNotification *)note
{
    CCLOG(@"finalShowCards");
    int type = [[[GameData sharedGameData]player]cardType];
    NSMutableArray *sendToServerArray = [[[GameData sharedGameData]player]sendToServerArr];
    [self showResultNiuWithType:type cardsDataSendToServer:sendToServerArray user:[[GameData sharedGameData]player]];
}

- (void)showResultNiuWithDic:(NSDictionary *)dic
{
    NSString *userID = [dic objectForKey:@"userID"];
    if([userID isEqualToString:[[[GameData sharedGameData]player]userID]])     return;
    User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
    
    int type = [[dic objectForKey:@"cardSize"]intValue];
    
    NSArray *cardDataDicArr = [dic objectForKey:@"cards"];
    NSMutableArray *cardsDataArray = [CardPlayingHandler cardDataDicArr2cardsDataArr:cardDataDicArr];
    [self showResultNiuWithType:type cardsDataSendToServer:cardsDataArray user:user];
    [debugConsole setString:@"显示玩家牌结果"];
}

- (void)showResultNiuWithType:(int)type cardsDataSendToServer:(NSMutableArray *)sendToServerArray user:(User *)user
{
    if(sendToServerArray == nil)    return;
    CGPoint firstCardPos = [[_cardPosArr objectAtIndex:((user.posID+6-2)%6)]CGPointValue];
    NSMutableArray *user5cards = user.user5cards;
    CCLOG(@"user5cards count:%d", [user5cards count]);
    if([user.userID isEqualToString:[[[GameData sharedGameData]player]userID]]){
        [self hidePlayerCards:NO];
    }
    CGPoint cardPos;
    switch (type) {
        case NIU_0:
        case WU_HUA:{
            for(int i = 0; i < 5; i++){
                cardPos = CGPointMake(firstCardPos.x + CARD_SPACE2 * i, firstCardPos.y);
                UserCard *card = [user5cards objectAtIndex:i];
                [card setPosition:cardPos];
                [card setFrontFace:[sendToServerArray objectAtIndex:i]];
            }
            break;
        }
        case NIU_1:
        case NIU_2:
        case NIU_3:
        case NIU_4:
        case NIU_5:
        case NIU_6:
        case NIU_7:
        case NIU_8:
        case NIU_9:
        case NIU_NIU:{
            for(int i = 0; i < 5; i++){
                if(i < 3)
                    cardPos = CGPointMake(firstCardPos.x + CARD_SPACE2 * i, firstCardPos.y);
                else
                    cardPos = CGPointMake(firstCardPos.x + CARD_SPACE2 * i + CARD_SPACE2, firstCardPos.y);
                UserCard *card = [user5cards objectAtIndex:i];
                [card setPosition:cardPos];
                [card setFrontFace:[sendToServerArray objectAtIndex:i]];
            }
            break;
        }
        case ZHA_DAN:{
            for(int i = 0; i < 5; i++){
                if(i == 4)
                    cardPos = CGPointMake(firstCardPos.x + CARD_SPACE2 * i + CARD_SPACE2, firstCardPos.y);
                else
                    cardPos = CGPointMake(firstCardPos.x + CARD_SPACE2 * i, firstCardPos.y);
                UserCard *card = [user5cards objectAtIndex:i];
                [card setPosition:cardPos];
                [card setFrontFace:[sendToServerArray objectAtIndex:i]];
            }
            break;
        }
        default:
            CCLOG(@"牌型数据错误!");
            break;
    }
    
    NSString *resName = [[[CardsHelper sharedHelper]cardResultForResource]objectAtIndex:type];
    CCSprite *resultNiu = [CCSprite spriteWithSpriteFrameName:resName];
    [self addChild:resultNiu z:kTagResultNiuSymbol tag:kTagResultNiuSymbol];
    [resultNiu setPosition:CGPointMake(firstCardPos.x + CARD_SPACE2, firstCardPos.y + CARD_SPACE2 * 2)];
    [_playerResultNiuSymbolDic setObject:resultNiu forKey:user.userID];
}

//显示最后所有玩家的输赢情况
- (void)showFinalWinLoseResult
{
    //停止倒计时
    [self countDownBeginWith:kCDTimeStop];
    //此时可以换桌、划屏离场
    [self allowLeavingOut];
    
    //用于home键游戏进入后台再次唤醒
    [self removeReadingCardLayer];
    
    NSMutableDictionary *userDic = [[GameData sharedGameData]userDic];
    NSString *tb;
    for(NSString *key in userDic){
        User *user = [userDic objectForKey:key];
        int winCoinTB = [user winCoinTB];
        if(winCoinTB > 0)
            tb = [NSString stringWithFormat:@"+%d",winCoinTB];
        else
            tb = [NSString stringWithFormat:@"%d", winCoinTB];
        CCLabelTTF *winLoseCoinTB = [CCLabelTTF labelWithString:tb fontName:@"Arial" fontSize:20];
        [self addChild:winLoseCoinTB z:kTagResultNiuSymbol tag:kTagResultNiuSymbol];
        [winLoseCoinTB setPosition:[[_avatarPosArr objectAtIndex:user.posID] CGPointValue]];
        [_playerWinLoseCoinTBDic setObject:winLoseCoinTB forKey:user.userID];
    }
    
    //如果玩家本人是庄家，此时不允许换桌或者离开
    if([[[[GameData sharedGameData]player]userID] isEqualToString:[[GameData sharedGameData]zUserID]]){
        [self fobiddenLeavingOut];
    }
}

//更新所有玩家的金币UI信息
- (void)updatePlayersCoin
{
    CCLOG(@"CardPlayingScene updatePlayersCoin");
    for(NSString *key in [[GameData sharedGameData]userDic]){
        User *user = [[[GameData sharedGameData]userDic]objectForKey:key];
        AvatarInfoBox *avatarInfoBox = [_avatarDic objectForKey:key];
        [avatarInfoBox updateCoinTB:user.coinTB];
    }
}

//有玩家掉线
- (void)otherPlayerOffline:(User *)user
{
    AvatarInfoBox *avatarInfoBox = [_avatarDic objectForKey:user.userID];
    [avatarInfoBox showOfflineStatus:YES];
}

//掉线玩家恢复在线
- (void)otherPlayerOnline:(User *)user
{
    AvatarInfoBox *avatarInfoBox = [_avatarDic objectForKey:user.userID];
    [avatarInfoBox showOfflineStatus:NO];
}

- (void)showPopTipViewWithTipType:(int)type
{
    self.popUpTipView = [PopUpTipView viewWithType:type];
    [self addChild:self.popUpTipView z:kTagPopUpView tag:kTagPopUpView];
}

- (void)removePopUpTipView
{
    if([self getChildByTag:kTagPopUpView])
        [self removeChildByTag:kTagPopUpView cleanup:YES];
}

- (void)reconnectCardServer
{
    CCLOG(@"重新连接卡牌服务器，数据界面同步中");
    [self removePopUpTipView];
    [self clearForRestart];
    [self removeOtherPlayerAvatarInfoBoxExceptMe];

    [self drawPlayersAvatarInfoBox];//玩家头像
    [self grabResult:[[GameData sharedGameData] zUserID]];//显示庄
    [self showPlayersBetRatio];//显示注
    
    User *playerSelf = [[GameData sharedGameData]player];
    if([playerSelf showCardsDataArr]){
        if([[[[GameData sharedGameData]player]user5cards]count] == 0)
            [self playSendCardsAnimation:NO];//显示背面牌
        [self showPlayersFinalCards];
    }else{
        if(!playerSelf.canGrabZ && playerSelf.canBet){
            //不能叫庄但能下注，则断线重连进来的阶段为庄家已经确定后下注前进入
            CCLOG(@"玩家断线重连进来时刻为：庄家已经确定后下注前进入");
        }else if(!playerSelf.canGrabZ && !playerSelf.canBet){
            //不能叫庄也不能下注，则断线重连进来的阶段为下注后进入    
            CCLOG(@"玩家断线重连进来时刻为：下注后进入");
            if([[[[GameData sharedGameData]player]user5cards]count] == 0)
                [self playSendCardsAnimation:NO];//显示背面牌
            [self showPlayersFinalCards];
        }
    }    
}

- (void)clearForRestart
{
    CCLOG(@"clearForRestart");
    //清除庄
    if([self getChildByTag:kTagZSymbol])
        [self removeChild:_zSymbol cleanup:YES];
    
    //清除winLose金币
    for(NSString *key in _playerWinLoseCoinTBDic){
        CCLabelTTF *winLoseCoinTB = [_playerWinLoseCoinTBDic objectForKey:key];
        [self removeChild:winLoseCoinTB cleanup:YES];
    }
    [_playerWinLoseCoinTBDic removeAllObjects];
    
    if([_allUserCardsArr count] > 0){
        for(UserCard *card in _allUserCardsArr){
            [self removeChild:card cleanup:YES];
        }
        [_allUserCardsArr removeAllObjects];
    }
    CCLOG(@"111111");
    
    for(NSString *key in [[GameData sharedGameData]userDic]){
        User *user = [[[GameData sharedGameData]userDic]objectForKey:key];
        if([user.user5cards count] > 0)
            [user.user5cards removeAllObjects];
    }
    CCLOG(@"22222");
    for(NSString *key in _playerResultNiuSymbolDic){
        CCSprite *resultNiu = [_playerResultNiuSymbolDic objectForKey:key];
        [self removeChild:resultNiu cleanup:YES];
    }
    [_playerResultNiuSymbolDic removeAllObjects];
    
    for(NSString *key in _betResultDic){
        CCSprite *betBox = [_betResultDic objectForKey:key];
        [self removeChild:betBox cleanup:YES];
    }
    [_betResultDic removeAllObjects];
     
    if([self getChildByTag:kTagReadingCardsLayer])
        [self removeChild:_readingCardsLayer cleanup:YES];
    
    [self clearPlayerData];
}

- (void)clearPlayerData
{
    if([[[[GameData sharedGameData]player]cardsDataArr]count] > 0)
        [[[[GameData sharedGameData]player]cardsDataArr]removeAllObjects];
    if([[[[GameData sharedGameData]player]selectedCardsDataArr]count] > 0)
        [[[[GameData sharedGameData]player]selectedCardsDataArr]removeAllObjects];
    if([[[[GameData sharedGameData]player]sendToServerArr]count] > 0)
        [[[[GameData sharedGameData]player]sendToServerArr]removeAllObjects];
    
    _isThinkingBet = NO;
    _isClosing5cards = NO;
    _isOpening5cards = NO;
    _isReading5cards = NO;
}

//禁止离场
- (void)fobiddenLeavingOut
{
    [_changeTableMenu setVisible:NO];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeftGestureRecognizer];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRightGestureRecognizer];
}

- (void)allowLeavingOut
{
    [_changeTableMenu setVisible:YES];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeLeftGestureRecognizer];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:self.swipeRightGestureRecognizer];
}

#pragma mark - home键进入后台再次唤醒
- (void)removeBetRatioMenu
{
    if([_betRatioMenu parent])
        [_betRatioMenu removeFromParentAndCleanup:YES];
}

- (void)removeReadingCardLayer
{
    if([self getChildByTag:kTagReadingCardsLayer]){
        CCLOG(@"CardPlayingScene removeChildByTag");
        [self removeChildByTag:kTagReadingCardsLayer cleanup:YES];
        [self showResultNiuWithType:NIU_0 cardsDataSendToServer:[[[GameData sharedGameData]player]cardsDataArr] user:[[GameData sharedGameData]player]];
    }
}

#pragma mark - dealloc
- (void) dealloc
{
    [_allUserCardsArr release];
    [_betResultDic release];
    [_avatarDic release];
    [_playerResultNiuSymbolDic release];
    [_playerWinLoseCoinTBDic release];
    
    [_betRatioMenu release];
    
    [_avatarPosArr release];
    [_cardPosArr release];
    [_betBoxesPosArr release];
    [_betBoxesFlyToPosArr release];
    
	[_swipeLeftGestureRecognizer release];
    _swipeLeftGestureRecognizer = nil;
    [_swipeRightGestureRecognizer release];
    _swipeRightGestureRecognizer = nil;
    [_popUpTipView release];
    _popUpTipView = nil;
    
	[super dealloc];
}


@end
