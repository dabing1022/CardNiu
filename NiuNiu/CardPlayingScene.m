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


@implementation CardPlayingScene
@synthesize swipeLeftGestureRecognizer=_swipeLeftGestureRecognizer;
@synthesize swipeRightGestureRecognizer=_swipeRightGestureRecognizer;

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
        _playerCardsArr = [[NSMutableArray alloc]initWithCapacity:5];
                
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"牌局" fontName:@"Marker Felt" fontSize:64];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position =  ccp( size.width /2 , size.height/2 );
        label.opacity = 125;
		[self addChild: label];
        label.tag = 5;
        
        [self drawGrabZ];
        [self drawCountDownLabelTTF];
        
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
        [[[[GameData sharedGameData]player]cardsDataArr]removeAllObjects];
        [[[[GameData sharedGameData]player]selectedCardsDataArr]removeAllObjects];
        [[[[GameData sharedGameData]player]sendToServerArr]removeAllObjects];
        
        //添加观察者-亮牌
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finalShowCards:) name:@"startShowCardsResult" object:nil];
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

#pragma mark - onEnter onExit
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
    
    //移除观察者
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"startShowCardsResult" object:nil];
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
    [playerBox setPosition:AVARTAR_POS_ID2];
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
        [playerBox setPosition:[[_avatarPosArr objectAtIndex:user.posID]CGPointValue]];
    }
}

//有其他玩家进入
- (void)otherPlayerIn:(User *)user
{
    CCLOG(@"------>有其他玩家进入");
    AvatarInfoBox *playerBox = [AvatarInfoBox infoBoxWithUserData:user];
    [self addChild:playerBox z:kTagAvatarInfoBox tag:kTagAvatarInfoBox];
    [playerBox setPosition:[[_avatarPosArr objectAtIndex:user.posID]CGPointValue]];
    
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
    //NSString为nil或者@""的时候length为0
    if([zUserID length] == 0){//没有庄家
        CCLOG(@"没有庄家，进行抢庄");
        [_menuGrabZ setVisible:YES];
        [self playSendCardsAnimation];
        [self countDownBeginWith:kCDTimeGrabZ];
    }else{//庄家已经存在
        CCLOG(@"庄家已经存在，不用抢庄");
    }
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
        default:
            NSAssert(NO, @"无效倒计时类型");
            break;
    }
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
        if([self getChildByTag:kTagReadingCardsLayer]){
            CCLOG(@"CardPlayingScene removeChildByTag");
            [self removeChildByTag:kTagReadingCardsLayer cleanup:YES];
            [self showResultNiuWithType:NIU_0 cardsDataSendToServer:[[[GameData sharedGameData]player]cardsDataArr] point:CARD_POS_ID2];
        }
    }
}

#pragma mark - sendCards
//播放发牌动画
- (void)playSendCardsAnimation
{
    CGSize size = [[CCDirector sharedDirector]winSize];
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    for (int i = 0; i < TOTAL_CARD_NUM; i++) {
        UserCard *card = [UserCard cardWithBack];
        [self addChild:card];
        [card setPosition:CGPointMake([card boundingBox].size.width/2, size.height-[card boundingBox].size.height/2)];
        [_allUserCardsArr addObject:card];
    }
    [self sendCards];
    [pool release];
}

- (void)sendCards
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
    
    [self countDownBeginWith:kCDTimeBet];
}

//开始下注
- (void)startBet:(NSArray *)betArr
{
    //停止抢庄倒计时
    [self unscheduleAllSelectors];

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
    _betRatioMenu = [CCMenu menuWithItems:_betRatioItem1,_betRatioItem2,_betRatioItem3,_betRatioItem4, nil];
    [_betRatioMenu setPosition:CGPointZero];
    [_betRatioMenu setScale:0.8];
    [self addChild:_betRatioMenu z:kTagBetRatioMenu tag:kTagBetRatioMenu];
}

- (void)sendServerWithGrab:(BOOL)choice
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:choice] forKey:@"grab"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_GRAB_RESULT contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:0 socketType:CARD_SOCKET];
    [_menuGrabZ setVisible:NO];
}

- (void)sendServerWithBetRatio:(int)ratio
{
    [_betRatioMenu removeFromParentAndCleanup:YES];
    
    CCSprite *betBox = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"betRatioNomal%d.png",ratio]];
    [self addChild:betBox z:kTagBetRatioMenu];
    CGPoint targetPos = [[_betBoxesFlyToPosArr objectAtIndex:2]CGPointValue];
    CCLOG(@"tagetPos :%f, %f", targetPos.x, targetPos.y);
    [betBox setPosition:targetPos];
    
    NSDictionary *betChoice = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:ratio] forKey:@"ratio"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_START_BET contentDic:betChoice];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:CMD_START_BET socketType:CARD_SOCKET];
}

//处理其他玩家下注结果
- (void)showPlayerBetResult:(NSDictionary *)betResult
{
    [_betRatioMenu removeFromParentAndCleanup:YES];
    
    int ratio = [[betResult objectForKey:@"ratio"]intValue];
    NSString *userID = [betResult objectForKey:@"userID"];
    CCSprite *betBox = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"betRatioNomal%d.png",ratio]];
    [self addChild:betBox z:kTagBetRatioMenu];
    
    User *user = [[[GameData sharedGameData]userDic]objectForKey:userID];
    CGPoint targetPos = [[_betBoxesFlyToPosArr objectAtIndex:user.posID]CGPointValue];
    CCLOG(@"tagetPos :%f, %f", targetPos.x, targetPos.y);
    [betBox setPosition:targetPos];
    
    [_betResultDic setObject:betBox forKey:userID];
}

//进入看牌阶段
- (void)startReadingCards:(NSArray *)cardArray
{
    CCLOG(@"startReadingCards");
    [self countDownBeginWith:kCDTimeReadCards];
    
    for(int i = 0; i < [_allUserCardsArr count]; i++){
        if(i % MAX_PLAYERS_NUM == 0){//将第0、6、12、18、24张牌放入_playerCardsArr数组
            [_playerCardsArr addObject:[_allUserCardsArr objectAtIndex:i]];
        }
    }
     
    [self closeThenOpenCards:cardArray];
    
}

//进入看牌阶段后，先收拢牌然后展开牌的动画效果
//收拢的时候5张牌为背面牌，展开的时候前4张为正面牌，第5张牌为背面牌，需要玩家去点击
- (void)closeThenOpenCards:(NSArray *)cardArray
{
    CCLOG(@"closeThenOpenCards");
    CGPoint closePos = [[_cardPosArr objectAtIndex:0]CGPointValue];
    //收拢牌
    for(UserCard *card in _playerCardsArr){
        id moveToClosePos = [CCMoveTo actionWithDuration:0.5 position:closePos];
        id easeOut = [CCEaseInOut  actionWithAction:moveToClosePos rate:2];
        [card runAction:easeOut];
    }
    //打开牌
    [self scheduleOnce:@selector(open5cards) delay:0.8];
}

- (void)open5cards
{
    [self unschedule:@selector(open5cards)];
    NSMutableArray *cardDataArr = [[GameData sharedGameData]player].cardsDataArr;
    CGPoint openPos = [[_cardPosArr objectAtIndex:0]CGPointValue];
    for(int i = 0; i < 5; i++)
    {
        UserCard *card = (UserCard *)[_playerCardsArr objectAtIndex:i];
        CardData *cardData = [cardDataArr objectAtIndex:i];
        id moveToOpenPos = [CCMoveTo actionWithDuration:0.5 position:CGPointMake(openPos.x + i * 50, openPos.y)];
        id easeOut = [CCEaseOut actionWithAction:moveToOpenPos rate:2];
        if(i != 4){
            [card setFrontFace:cardData];
        }
        [card runAction:easeOut];
    }
    
    [self scheduleOnce:@selector(addReadingCardsLayer) delay:3];
}

//读牌层
- (void)addReadingCardsLayer
{
    [self unschedule:@selector(addReadingCardsLayer)];
    [self removePlayerCards];
    
    _readingCardsLayer = [ReadingCardsLayer layerWithCardsArray:[[GameData sharedGameData]player].cardsDataArr];
    [self addChild:_readingCardsLayer z:kTagReadingCardsLayer tag:kTagReadingCardsLayer];    
}

- (void)removePlayerCards
{
    for(int i = 0; i < 5; i++){
        UserCard *card = (UserCard *)[_playerCardsArr objectAtIndex:i];
        [self removeChild:card cleanup:YES];
    }
    [_playerCardsArr removeAllObjects];
    CCLOG(@"_playerCardsArr length:%d",[_playerCardsArr count]);
}

//玩家自己亮牌
- (void)finalShowCards:(NSNotification *)note
{
    CCLOG(@"finalShowCards");
    int type = [[[GameData sharedGameData]player]cardType];
    NSMutableArray *sendToServerArray = [[[GameData sharedGameData]player]sendToServerArr];
    [self showResultNiuWithType:type cardsDataSendToServer:sendToServerArray point:CARD_POS_ID2];
}

- (void)showResultNiuWithDic:(NSDictionary *)dic
{
    NSString *userID = [dic objectForKey:@"userID"];
    int posID = [[[[GameData sharedGameData]userDic]objectForKey:userID] posID];
    CGPoint firstCardPos = [[_cardPosArr objectAtIndex:((posID+6-2)%6)]CGPointValue];
    
    int type = [[dic objectForKey:@"cardSize"]intValue];
    
    NSArray *cardDataDicArr = [dic objectForKey:@"cards"];
    NSMutableArray *cardsDataArray = [CardPlayingHandler cardDataDicArr2cardsDataArr:cardDataDicArr];
    [self showResultNiuWithType:type cardsDataSendToServer:cardsDataArray point:firstCardPos];
}

- (void)showResultNiuWithType:(int)type cardsDataSendToServer:(NSMutableArray *)sendToServerArray point:(CGPoint)point
{
    CGPoint cardPos;
    switch (type) {
        case NIU_0:
        case WU_HUA:{
            for(int i = 0; i < 5; i++){
                cardPos = CGPointMake(point.x + CARD_SPACE2 * i, point.y);
                UserCard *card = [UserCard cardWithCardData:[sendToServerArray objectAtIndex:i]];
                [card setPosition:cardPos];
                [self addChild:card z:kTagAllCards tag:kTagAllCards];
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
                    cardPos = CGPointMake(point.x + CARD_SPACE2 * i, point.y);
                else
                    cardPos = CGPointMake(point.x + CARD_SPACE2 * i + CARD_SPACE2, point.y);
                UserCard *card = [UserCard cardWithCardData:[sendToServerArray objectAtIndex:i]];
                [card setPosition:cardPos];
                [self addChild:card z:kTagAllCards tag:kTagAllCards];
            }
            break;
        }
        case ZHA_DAN:{
            for(int i = 0; i < 5; i++){
                if(i == 4)
                    cardPos = CGPointMake(point.x + CARD_SPACE2 * i + CARD_SPACE2, point.y);
                else
                    cardPos = CGPointMake(point.x + CARD_SPACE2 * i, point.y);
                UserCard *card = [UserCard cardWithCardData:[sendToServerArray objectAtIndex:i]];
                [card setPosition:cardPos];
                [self addChild:card z:kTagAllCards tag:kTagAllCards];
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
    [resultNiu setPosition:CGPointMake(point.x + CARD_SPACE2, point.y + CARD_SPACE2 * 2)];
}

#pragma mark - dealloc
- (void) dealloc
{
    [_allUserCardsArr release];
    
    [_avatarPosArr release];
    [_cardPosArr release];
    [_betBoxesPosArr release];
    [_betBoxesFlyToPosArr release];
    
	[_swipeLeftGestureRecognizer release];
    _swipeLeftGestureRecognizer = nil;
    [_swipeRightGestureRecognizer release];
    _swipeRightGestureRecognizer = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
    
	[super dealloc];
}


@end
