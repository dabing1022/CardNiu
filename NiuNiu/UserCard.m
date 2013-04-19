//
//  UserCard.m
//  NiuNiu
//  玩家的牌
//  Created by childhood on 13-4-15.
//
//

#import "UserCard.h"

@implementation UserCard
@synthesize isFront=_isFront,isPopup=_isPopup;

#pragma mark - init
- (id)initWithCardData:(CardData)cardData
{
    if((self=[super init]))
    {
        [self setFrontFace:cardData];
    }
    return self;
}

+ (id)cardWithCardData:(CardData)cardData
{
    return [[[self alloc]initWithCardData:cardData]autorelease];
}

- (id)initWithBack
{
    if((self=[super init]))
    {
        [self setBackFace];
    }
    return self;
}

+ (id)cardWithBack
{
    return [[[self alloc]initWithBack]autorelease];
}

- (void)setFrontFace:(CardData)cardData
{
    int type = cardData.type;
    int value = cardData.value;
    
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:[NSString stringWithFormat:@"Card%d_%d.png",type,value]]];
    _isFront = YES;
}

- (void)setBackFace
{
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"CardBack.png"]];
    _isFront = NO;
}

#pragma mark - popUp and pullDown
- (void)popUpWithHeight:(int)height
{
    if(self.isPopup)    return;
    [self setPosition:CGPointMake(self.position.x, self.position.y+height)];
}

- (void)pullDownWithHeight:(int)height
{
    if(self.isPopup)
        [self setPosition:CGPointMake(self.position.x, self.position.y-height)];
}

- (void)dealloc
{
    [super dealloc];
}

@end
