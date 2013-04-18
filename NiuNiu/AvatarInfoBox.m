//
//  AvatarInfoBox.m
//  NiuNiu
//  CardPlayingScene中玩家头像信息盒子
//  Created by childhood on 13-4-18.
//
//

#import "AvatarInfoBox.h"

@implementation AvatarInfoBox


#pragma mark - init
+ (CCSprite *)infoBoxWithUserData:(User *)user
{
    return [[[self alloc]initInfoBoxWithUserData:user]autorelease];
}
- (id)initInfoBoxWithUserData:(User *)user
{
    if((self = [super init]))
    {
        _avatarSpr = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"avatar%@.png",user.avatarID]];
        [self addChild:_avatarSpr z:0 tag:kTagAvatarSpr];
        _coinTB = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",user.coinTB] fontName:@"Arial" fontSize:24];
        _coinTB.position = ccp(80, 8);
        [self addChild:_coinTB z:1 tag:kTagCoinTB];
    }
    return self;
}
@end
