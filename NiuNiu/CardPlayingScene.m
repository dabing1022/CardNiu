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
#import "BetBox.h"

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
        _allBetBoxesArr = [[NSMutableArray alloc]initWithCapacity:4];
                
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

    }
    LOG_FUN_DID;
    return self;
}

#pragma mark - drawStuff
- (void)drawCountDownLabelTTF
{
    _countDownLabelTTF = [CCLabelTTF labelWithString:@"00" fontName:@"Arial" fontSize:24];
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

- (void)sendServerWithGrab:(BOOL)choice
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:choice] forKey:@"grab"];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_GRAB_RESULT contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper]writeData:data withTimeout:-1 tag:0 socketType:CARD_SOCKET];
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
    
    //接收来自BetBox选择下注的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAllBetBoxesExcept:) name:@"didChooseRatio" object:nil];
  
    [super onEnter];
    LOG_FUN_DID;
}

- (void)onExit
{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeftGestureRecognizer];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRightGestureRecognizer];
    [_activityIndicatorView stopAnimating];
    [_activityIndicatorView removeFromSuperview];
    
    //移除来自BetBox选择下注的通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
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
        //抢庄倒计时
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
            [self sendServerWithGrab:NO];
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
}

//开始下注
- (void)startBet:(NSArray *)betArr
{
    //停止抢庄倒计时
    [self unscheduleAllSelectors];

    for(int i = 0;i < 4;i++)
    {
        NSDictionary *aBetBoxInfoDic = (NSDictionary *)[betArr objectAtIndex:i];
        BetBox *betBox = [BetBox betBoxWithRatio:[[aBetBoxInfoDic objectForKey:@"ratio"]intValue]
                                          status:[[aBetBoxInfoDic objectForKey:@"status"]boolValue]];
        [self addChild:betBox z:kTagBetBoxes tag:kTagBetBoxes];
        [betBox setPosition:[[_betBoxesPosArr objectAtIndex:i] CGPointValue]];
        [_allBetBoxesArr addObject:betBox];
    }
    [self countDownBeginWith:kCDTimeBet];
}

- (void)removeAllBetBoxesExcept:(NSNotification *)notification
{
    BetBox *betBoxHitted = (BetBox *)[notification.userInfo objectForKey:@"betBox"];
    for(BetBox *betBox in _allBetBoxesArr)
    {
        if(betBox == betBoxHitted) continue;
        [self removeChild:betBox cleanup:YES];
        [_allBetBoxesArr removeObject:betBox];
    }
    
    id moveTo = [CCMoveTo actionWithDuration:0.5 position:[[_betBoxesFlyToPosArr objectAtIndex:2]CGPointValue]];
    id easeIn = [CCEaseIn actionWithAction:moveTo rate:2];
    [betBoxHitted runAction:easeIn];
}


#pragma mark - dealloc
- (void) dealloc
{
    [_allUserCardsArr release];
    [_allBetBoxesArr release];
    
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
