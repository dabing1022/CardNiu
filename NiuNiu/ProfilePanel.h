//
//  ProfileScene.h
//  NiuNiu
//  牌局场景中的玩家头像点击后的具体介绍
//  Created by childhood on 13-4-18.
//
//

#import "cocos2d.h"
@class User;
@interface ProfilePanel : CCSprite<CCTargetedTouchDelegate>
{
    User *_user;
}

+ (id)profileWithUser:(User *)user;

@end
