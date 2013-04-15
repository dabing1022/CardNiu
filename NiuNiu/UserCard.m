//
//  UserCard.m
//  NiuNiu
//  玩家的牌
//  Created by childhood on 13-4-15.
//
//

#import "UserCard.h"

@implementation UserCard
@synthesize isFront=_isFront,texture=_texture,isPopup=_isPopup;

#pragma mark - init
- (id)initWithCardData:(CardData)cardData
{
    if((self=[super init]))
    {
        int type = cardData.type;
        int value = cardData.value;
        
        _texture = [[CCTextureCache sharedTextureCache] addPVRImage:[NSString stringWithFormat:@"Card%d_%d.png",type,value]];
        [self setTexture:_texture];
        _isFront = YES;
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
        _texture = [[CCTextureCache sharedTextureCache] addPVRImage:@"CardBack.png"];
        [self setTexture:_texture];
        _isFront = NO;
    }
    return self;
}

+ (id)cardWithBack
{
    return [[[self alloc]initWithBack]autorelease];
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
    [_texture release];
    _texture = nil;
    [super dealloc];
}

@end
