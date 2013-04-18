#ifndef __GAME_H
#define __GAME_H
#define LOG_FUN_DID CCLOG(@"%s-->%@", __FILE__, NSStringFromSelector(_cmd))

/*--------------------LOGIN_SERVER通讯命令------------------------------------*/
//用户通过GC验证后登录
#define CMD_LOGIN 1001





/*--------------------CARD_SERVER通讯命令--------------------------------------*/
#define CMD_ENTER_CARD_PLAYING 2001//进入牌局场景
#define CMD_ENTER_DESK         2002//被分配进入牌桌
#define CMD_OTHER_PLAYER_IN    2003//其他玩家进入牌桌
#define CMD_VIEW_PROFILE       2004//点击玩家头像查看具体信息



#define CMD_INFO  9998//服务器给客户端发送的提示
#define CMD_ERROR 9999//出错
#define INFO_WAITING_ASSIGN @"info001"//玩家切换到牌局场景后等待分配

/*--------------------FAMILY_SERVER通讯命令------------------------------------*/





#endif