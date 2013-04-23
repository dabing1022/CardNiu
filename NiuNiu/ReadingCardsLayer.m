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

@implementation ReadingCardsLayer


+ (id)layerWithCardsArray:(NSArray *)cardsArray
{
    return [[[self alloc]initWithCardsArray:cardsArray]autorelease];
}

- (id)initWithCardsArray:(NSArray *)cardsArray
{
    if((self=[super initWithColor:ccc4(0, 0, 0, 128)]))
    {
        _state = kState_TheFifthCard;
        size = [[CCDirector sharedDirector]winSize];
        
        _cardsDataArray = cardsArray;
        [_cardsDataArray retain];
        
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
    _resultNiu = [CCSprite spriteWithSpriteFrameName:resName];
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
                                                       }];
}

//绘制下方的5张牌
- (void)drawUserCards
{
    UserCard *card;
    for(int i = 0;i < 5;i++)
    {
        NSDictionary *singleCardData = (NSDictionary *)[_cardsDataArray objectAtIndex:i];
        CardData cardData = [[CardsHelper sharedHelper]getCardDataFromCardDic:singleCardData];
        if(i != 4){//前4张牌显示正面
            card = [UserCard cardWithCardData:cardData];
        }else{//第5张牌显示背面
            card = [UserCard cardWithBack];
            _fifthCard = card;
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
}

- (void)openTheFifthCard
{
    NSDictionary *singleCardData = (NSDictionary *)[_cardsDataArray objectAtIndex:4];
    CardData cardData = [[CardsHelper sharedHelper]getCardDataFromCardDic:singleCardData];
    [_fifthCard setFrontFace:cardData];
    
    [self fifthCardScaleToUpLine];
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
            _state = kState_CalCard;
        }
        
    }else if(_state == kState_CalCard){
        for(UserCard *card in _userCardsArray){
            if([self containsTouchLocation:touch node:card]){
                [card handlePopAndDown];
            }
        }
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
    [super dealloc];
}
@end
