//
//  ReadingCardsLayer.m
//  NiuNiu
//
//  Created by childhood on 13-4-22.
//
//

#import "ReadingCardsLayer.h"
#import "UserCard.h"

@implementation ReadingCardsLayer


+ (id)layerWithCardsArray:(NSArray *)cardsArray
{
    return [[[self alloc]initWithCardsArray:cardsArray]autorelease];
}

- (id)initWithCardsArray:(NSArray *)cardsArray
{
    if((self=[super initWithColor:ccc4(0, 0, 0, 128)]))
    {
        _cardsDataArray = cardsArray;
        [_cardsDataArray retain];
        
        _userCardsArray = [NSMutableArray arrayWithCapacity:5];
        
        [self drawUserCards];
    }
    return self;
}

//绘制下方的5张牌
- (void)drawUserCards
{
    UserCard *card;
    for(int i = 0;i < 5;i++)
    {
        NSDictionary *singleCardData = (NSDictionary *)[_cardsDataArray objectAtIndex:i];
        CardData cardData;
        cardData.type = [[singleCardData objectForKey:@"color"]intValue];
        cardData.value = [[singleCardData objectForKey:@"value"]intValue];
        if(i != 4){//前4张牌显示正面
            card = [UserCard cardWithCardData:cardData];
        }else{//第5张牌显示背面
            card = [UserCard cardWithBack];
        }
        [self addChild:card];
        CGPoint pos = CGPointMake(FIRST_CARD_BELOW_POS.x + CARDS_SPACING * i, FIRST_CARD_BELOW_POS.y);
        [card setPosition:pos];
        [_userCardsArray addObject:card];
    }
    [self schedule:@selector(flyToUpper:)];
}

//底下的5张牌飞向上部
- (void)flyToUpper:(ccTime)dt
{
    [self unschedule:@selector(flyToUpper:)];
    for(int i = 0;i < 5;i++)
    {
        UserCard *card = (UserCard *)[_userCardsArray objectAtIndex:i];
        CGPoint targetPos = CGPointMake(FIRST_CARD_UP_POS.x + CARDS_SPACING * i, FIRST_CARD_UP_POS.y);
        id flyTo = [CCMoveTo actionWithDuration:0.4 position:targetPos];
        id easeIn = [CCEaseIn actionWithAction:flyTo rate:2];
        id delay = [CCDelayTime actionWithDuration:1];
        id func = [CCCallFunc actionWithTarget:self selector:@selector(fifthCardScaleToCenter:)];
        CCSequence *actions = [CCSequence actions:easeIn, delay, func, nil];
        [card runAction:actions];
    }
}

- (void)fifthCardScaleToCenter:(id)sender
{
    UserCard *fifthCard = (UserCard *)[_userCardsArray objectAtIndex:4];
    CGSize size = [[CCDirector sharedDirector]winSize];
    id moveTo = [CCMoveTo actionWithDuration:1 position:CGPointMake(size.width/2, size.height/2)];
    id scale = [CCScaleTo actionWithDuration:1 scale:3];
    id spawn = [CCSpawn actions:moveTo, scale, nil];
    [fifthCard runAction:spawn];
}

- (void)dealloc
{
    [_cardsDataArray release];
    [super dealloc];
}
@end
