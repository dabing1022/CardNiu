//
//  UserCard.m
//  NiuNiu
//  玩家的牌
//  Created by childhood on 13-4-15.
//
//

#import "UserCard.h"

@implementation CardData
@synthesize color,value;
@end


@implementation UserCard
@synthesize isFront=_isFront,isPopup=_isPopup;

#pragma mark - init
- (id)initWithCardData:(CardData *)cardData
{
    if((self=[super init]))
    {
        self.cardData = cardData;
        [self setFrontFace:cardData];
    }
    return self;
}

+ (id)cardWithCardData:(CardData *)cardData
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

- (void)setFrontFace:(CardData *)cardData
{
    self.cardData = cardData;
    
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:[NSString stringWithFormat:@"Card%d_%d.png",_cardData.color, _cardData.value]]];
    _isFront = YES;
}

- (void)setBackFace
{
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"CardBack.png"]];
    _isFront = NO;
}

#pragma mark - popUp and pullDown
- (void)popUp
{
    if(self.isPopup)    return;
    id popUp = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(self.position.x, self.position.y + CARD_POP_DOWN_HEIGHT)];
    [self runAction:popUp];
    self.isPopup = YES;
}

- (void)pullDown
{
    if(!(self.isPopup))return;
    id pullDown = [CCMoveTo actionWithDuration:0.1 position:CGPointMake(self.position.x, self.position.y - CARD_POP_DOWN_HEIGHT)];
    [self runAction:pullDown];
    self.isPopup = NO;
}

- (void)handlePopAndDown
{
    if(self.isPopup){
        [self pullDown];
    }else{
        [self popUp];
    }
}

#pragma mark - TouchDelegate
- (BOOL)containsTouchLocation:(UITouch *)touch
{
    return CGRectContainsPoint([self rect], [self convertTouchToNodeSpaceAR:touch]);
}

- (CGRect)rect
{
    CGSize size = self.contentSize;
    CGRect rect = CGRectMake(-size.width/2, -size.height/2, size.width, size.height);
    return rect;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(![self containsTouchLocation:touch] || _isFront)
        return NO;
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}


- (void)dealloc
{
    [_cardData release];
    [super dealloc];
}

@end
