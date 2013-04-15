//
//  RoleDiscriptionLayer.h
//  NiuNiu
//  角色生成的介绍
//  Created by childhood on 13-4-12.
//
//
#import "cocos2d.h"
#import "CCLayer.h"

@interface RoleDiscriptionLayer : CCLayerColor
{
    int _roleId;
}

@property(nonatomic, assign)int roleId;
+ (id) initWithRoleId:(int)roleId;
- (id) initWithRoleId:(int)roleId;

@end
