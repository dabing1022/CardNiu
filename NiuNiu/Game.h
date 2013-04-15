#ifndef __GAME_H
#define __GAME_H
#define LOG_FUN_DID CCLOG(@"%s-->%@", __FILE__, NSStringFromSelector(_cmd))

/*--------------------LOGIN_SERVER通讯命令------------------------------------*/
//用户通过GC验证后登录
#define CMD_LOGIN 1001





/*--------------------CARD_SERVER通讯命令--------------------------------------*/
//进入牌桌游戏
#define ENTER_CARD_PLAYING 2001

/*--------------------FAMILY_SERVER通讯命令------------------------------------*/
#endif