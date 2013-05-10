//
//  AvatarInfoBox.h
//  NiuNiu
//  CardPlayingScene中玩家头像信息盒子
//  Created by childhood on 13-4-18.
//
//

#import "cocos2d.h"
#import "User.h"
#import "Game.h"

enum{
    kTagAvatarSpr,
    kTagCoinTB,
    kTagOffline
};

@interface AvatarInfoBox : CCSprite<CCTargetedTouchDelegate>
{
    //头像
    CCSprite *_avatarSpr;
    //铜币
    CCLabelTTF *_coinTB;
    User *_user;
    
    //掉线相关
    CCSprite *_offlineSpr;
    BOOL _offline;
}

+ (id)infoBoxWithUserData:(User *)user;
- (id)initInfoBoxWithUserData:(User *)user;
- (void)updateCoinTB:(int)coinTB;
- (void)showOfflineStatus:(BOOL)show;
@end
