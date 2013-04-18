//
//  AvatarInfoBox.h
//  NiuNiu
//  CardPlayingScene中玩家头像信息盒子
//  Created by childhood on 13-4-18.
//
//

#import "cocos2d.h"
#import "User.h"

enum{
    kTagAvatarSpr,
    kTagCoinTB
};

@interface AvatarInfoBox : CCSprite
{
    //头像
    CCSprite *_avatarSpr;
    //铜币
    CCLabelTTF *_coinTB;
}

+ (id)infoBoxWithUserData:(User *)user;
- (id)initInfoBoxWithUserData:(User *)user;

@end
