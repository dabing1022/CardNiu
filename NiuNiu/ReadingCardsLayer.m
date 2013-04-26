//
//  ReadingCardsLayer.m
//  NiuNiu
// 
//  Created by childhood on 13-4-22.
//
//

#import "ReadingCardsLayer.h"
#import "UserCard.h"
#import "CardsHelper.h"
#import "GameData.h"
#import "User.h"
#import "Game.h"
#import "GCDAsyncSocketHelper.h"

@implementation ReadingCardsLayer


+ (id)layerWithCardsArray:(NSMutableArray *)cardsArray
{
    return [[[self alloc]initWithCardsArray:cardsArray]autorelease];
}

- (id)initWithCardsArray:(NSMutableArray *)cardsArray
{
    if((self=[super initWithColor:ccc4(0, 0, 0, 128)]))
    {
        _state = kState_TheFifthCard;
        size = [[CCDirector sharedDirector]winSize];
        
        _cardsDataArray = [cardsArray retain];
        
        _userCardsArray = [NSMutableArray arrayWithCapacity:5];
        [_userCardsArray retain];
        
        [self drawUserCards];
        [self drawResultNiu:0];
        [self drawConfirmMenu];
    }
    return self;
}

//绘制显示牌型结果
- (void)drawResultNiu:(int)result
{
    NSString *resName = [[[CardsHelper sharedHelper]cardResultForResource]objectAtIndex:result];
    _resultNiu = [[CCSprite spriteWithSpriteFrameName:resName]retain];
    [self addChild:_resultNiu];
    [_resultNiu setPosition:ccp(size.width / 2, size.height / 2 + 30)];
    [_resultNiu setVisible:NO];
}

- (void)showResultNiu:(int)result
{
    [_resultNiu setVisible:YES];
    NSString *resName = [[[CardsHelper sharedHelper]cardResultForResource]objectAtIndex:result];
    [_resultNiu setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:resName]];
    //播放音效
}

//绘制确认按钮
- (void)drawConfirmMenu
{
    _confirmMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"confirmNomal.png"]
                                              selectedSprite:[CCSprite spriteWithSpriteFrameName:@"confirmSelected.png"]
                                                       block:^(id sender){
                                                           CCLOG(@"确认牌型选择");
                                                           [self sendUserDecision];
                                                       }];
    [_confirmMenuItem setPosition:CGPointMake(size.width / 2, 100)];
    _confirmMenu = [CCMenu menuWithItems:_confirmMenuItem, nil];
    [_confirmMenu setPosition:CGPointZero];
    [self addChild:_confirmMenu];
    [_confirmMenu setVisible:NO];
}

- (void)sendUserDecision
{
    NSNumber *manualLength = [NSNumber numberWithInt:[[[[GameData sharedGameData]player]selectedCardsDataArr]count]];
    NSMutableArray *sendToServer;
    if(!_isZhaDanOrWuHua && [manualLength intValue] == 0){//分析不是炸弹或者五花牛，并且玩家没有手动选择牌
        sendToServer = _cardsDataArray;
        [[[GameData sharedGameData]player]setCardType:NIU_0];
        [[[GameData sharedGameData]player] setSendToServerArr:sendToServer];
    }else{
        sendToServer = [[[GameData sharedGameData]player]sendToServerArr];
    }
    
    
    NSMutableArray *cardsArray = [[[NSMutableArray alloc]init]autorelease];
    for(int i = 0; i < [sendToServer count]; i++){
        CardData *cardData = [sendToServer objectAtIndex:i];
        NSMutableDictionary *singleCardDataDic = [[[NSMutableDictionary alloc]init]autorelease];
        [singleCardDataDic setObject:[NSNumber numberWithInt:cardData.color] forKey:@"color"];
        [singleCardDataDic setObject:[NSNumber numberWithInt:cardData.value] forKey:@"value"];
        [cardsArray addObject:singleCardDataDic];
    }    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:manualLength,cardsArray,nil]
                                                    forKeys:[NSArray arrayWithObjects:@"manualLength",@"cards",nil]];
    NSData *data = [[GCDAsyncSocketHelper sharedHelper]wrapPacketWithCmd:CMD_START_SHOW_CARDS contentDic:dic];
    [[GCDAsyncSocketHelper sharedHelper] writeData:data withTimeout:-1 tag:CMD_START_SHOW_CARDS socketType:CARD_SOCKET];
    
    [self removeFromParentAndCleanup:YES];
    
    //通知CardPlayingScene开始亮牌
    [[NSNotificationCenter defaultCenter]postNotificationName:@"startShowCardsResult" object:nil];
}

//绘制下方的5张牌
- (void)drawUserCards
{
    UserCard *card;
    for(int i = 0;i < 5;i++)
    {
        CardData *cardData = [_cardsDataArray objectAtIndex:i];
        if(i != 4){//前4张牌显示正面
            card = [UserCard cardWithCardData:cardData];
        }else{//第5张牌显示背面
            card = [UserCard cardWithBack];
            _fifthCard = [card retain];
        }
        [self addChild:card];
        CGPoint pos = CGPointMake(FIRST_CARD_BELOW_POS.x + CARDS_SPACING * i, FIRST_CARD_BELOW_POS.y);
        [card setPosition:pos];
        [_userCardsArray addObject:card];
    }
    [self flyToUpper];
}

//底下的5张牌飞向上部
- (void)flyToUpper
{
    for(int i = 0;i < 5;i++)
    {
        UserCard *card = (UserCard *)[_userCardsArray objectAtIndex:i];
        NSAssert([card isKindOfClass:[UserCard class]], @"card wrong");
        CGPoint targetPos = CGPointMake(FIRST_CARD_UP_POS.x + CARDS_SPACING * i, FIRST_CARD_UP_POS.y);
        id flyTo = [CCMoveTo actionWithDuration:0.4 position:targetPos];
        id scale = [CCScaleTo actionWithDuration:0.4 scale:2];
        id spawn = [CCSpawn actions:flyTo, scale, nil];
        id easeIn = [CCEaseIn actionWithAction:spawn rate:2];
        [card runAction:easeIn];
    }

    [self scheduleOnce:@selector(fifthCardScaleToCenter) delay:1];
}

- (void)fifthCardScaleToCenter
{
    [self unschedule:@selector(fifthCardScaleToCenter)];
    id moveTo = [CCMoveTo actionWithDuration:0.4 position:CGPointMake(size.width/2, size.height/2)];
    id scale = [CCScaleTo actionWithDuration:0.4 scale:5];
    id spawn = [CCSpawn actions:moveTo, scale, nil];
    id easeOut = [CCEaseOut actionWithAction:spawn rate:3];
    [_fifthCard runAction:easeOut];
}

- (void)fifthCardScaleToUpLine
{
    CGPoint pos = CGPointMake(FIRST_CARD_UP_POS.x + CARDS_SPACING * 4, FIRST_CARD_UP_POS.y);
    id moveTo = [CCMoveTo actionWithDuration:0.4 position:pos];
    id scale = [CCScaleTo actionWithDuration:0.4 scale:2];
    id spawn = [CCSpawn actions:moveTo, scale, nil];
    id easeOut = [CCEaseOut actionWithAction:spawn rate:3];
    [_fifthCard runAction:easeOut];
    
    [self scheduleOnce:@selector(allCardsToCenter) delay:0.8];
}

- (void)allCardsToCenter
{
    [self unschedule:@selector(allCardsToCenter)];
    for(UserCard *card in _userCardsArray){
        id moveTo = [CCMoveTo actionWithDuration:0.8 position:CGPointMake(card.position.x, size.height/2)];
        id ease = [CCEaseInOut actionWithAction:moveTo rate:2];
        [card runAction:ease];
    }
    [self scheduleOnce:@selector(analysisWholeCards) delay:1];
}

//先对5张牌进行分析 
- (void)analysisWholeCards
{
    [self unschedule:@selector(analysisWholeCards)];
    NSDictionary *resultDic = [[CardsHelper sharedHelper]analysisWholeCards:_cardsDataArray];
    NSMutableArray *selectedArr = [[[GameData sharedGameData]player]selectedCardsDataArr];
    int cardType = [[resultDic objectForKey:@"cardType"]intValue];
    NSArray *cardsIndex = [resultDic objectForKey:@"cardsIndex"];
    CCLOG(@"cardType is %d", cardType);
    if(cardType == ZHA_DAN || cardType == WU_HUA){
        [self showResultNiu:cardType];
        _isZhaDanOrWuHua = YES;
        
        for(int i = 0; i < [cardsIndex count]; i ++){
            [selectedArr addObject:[_cardsDataArray objectAtIndex:i]];
        }
        NSMutableArray *sendToServer = [[CardsHelper sharedHelper]sortCardsDataByCardsIndex:cardsIndex cardsDataArray:_cardsDataArray];
        [[[GameData sharedGameData]player]setSendToServerArr:sendToServer];
        [[[GameData sharedGameData]player]setCardType:cardType];
    }else{
        _isZhaDanOrWuHua = NO;
    }
    //进入玩家手动凑牛阶段
    _state = kState_CalCard;
    [_confirmMenu setVisible:YES];
}

- (void)openTheFifthCard
{
    CardData *cardData = [_cardsDataArray objectAtIndex:4];
    [_fifthCard setFrontFace:cardData];
    
    [self fifthCardScaleToUpLine];
}

//点击触摸牌（凑牛操作)
- (void)handleCalCard:(UITouch *)touch
{
    NSMutableArray *selectedArr = [[[GameData sharedGameData]player]selectedCardsDataArr];
    
    for(int i = 0; i < [_userCardsArray count]; i++){
        UserCard *card = [_userCardsArray objectAtIndex:i];
        if([self containsTouchLocation:touch node:card]){
            [card handlePopAndDown];
            if(card.isPopup){
                [selectedArr addObject:card.cardData];
                CCLOG(@"玩家点选了第%d张牌",i+1);
                CCLOG(@"selectedCardsDataArr length %d",[selectedArr count]);
            }else{
                [selectedArr removeObject:card.cardData];
                CCLOG(@"玩家放弃了第%d张牌",i+1);
                CCLOG(@"selectedCardsDataArr length %d",[selectedArr count]);
            }
        }
    }
    
    //分析所选择的牌凑成的牌型
    NSDictionary *resultDic = [[CardsHelper sharedHelper]analysisSelectedCards:selectedArr
                                                             wholeCardsDataArr:_cardsDataArray];
    NSArray *cardsIndex = [resultDic objectForKey:@"cardsIndex"];
    if([selectedArr count] >= 3){
        int cardType = [[resultDic objectForKey:@"cardType"]intValue];
        CCLOG(@"handlerCalCard cardType %d", cardType);
        [self showResultNiu:cardType];
        [[[GameData sharedGameData]player]setCardType:cardType];
    }else{
        [_resultNiu setVisible:NO];
        [[[GameData sharedGameData]player]setCardType:NIU_0];
    }
    
    
    NSMutableArray *senderToServerArray = [[CardsHelper sharedHelper]sortCardsDataByCardsIndex:cardsIndex
                                                                                cardsDataArray:_cardsDataArray];
    
    [[[GameData sharedGameData]player] setSendToServerArr:senderToServerArray];
}



#pragma mark - touch delegate
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"ccTouchBegan");
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"ccTouchEnded");
    if(_state == kState_TheFifthCard){
        if([self containsTouchLocation:touch node:_fifthCard]){
            [self openTheFifthCard];
        }
    }else if(_state == kState_CalCard && !_isZhaDanOrWuHua){
        //进入凑牛阶段并且不是炸弹或者五花牛(因为炸弹和五花牛自动显示牌型结果)
        [self handleCalCard:touch];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCLOG(@"ccTouchCancelled");
}

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:[touch view]];
    return [[CCDirector sharedDirector]convertToGL:touchLocation];
}

- (BOOL)containsTouchLocation:(UITouch *)touch node:(CCNode *)node
{
    return CGRectContainsPoint([node boundingBox], [self locationFromTouch:touch]);
}

#pragma mark - onEnter/onExit
- (void)onEnter
{
    [[[CCDirector sharedDirector]touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [super onEnter];
}

- (void)onExit
{
    [[[CCDirector sharedDirector]touchDispatcher]removeDelegate:self];
    [super onExit];
}


- (void)dealloc
{
    [_cardsDataArray release];
    [_userCardsArray release];
    [_fifthCard release];
    [_resultNiu release];
    [super dealloc];
}
@end
