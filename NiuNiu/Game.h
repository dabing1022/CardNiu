#ifndef __GAME_H
#define __GAME_H
#define LOG_FUN_DID CCLOG(@"%s-->%@", __FILE__, NSStringFromSelector(_cmd))

/*--------------------LOGIN_SERVER通讯命令------------------------------------*/
//用户通过GC验证后登录
#define CMD_LOGIN 1001





/*--------------------CARD_SERVER通讯命令--------------------------------------*/
#define CMD_ENTER_CARD_PLAYING      2001//进入牌局场景
#define CMD_ENTER_DESK              2002//被分配进入牌桌
#define CMD_OTHER_PLAYER_IN         2003//其他玩家进入牌桌
#define CMD_VIEW_PROFILE            2004//点击玩家头像查看具体信息
#define CMD_GRAB_Z                  2005//抢庄+发牌
#define CMD_GRAB_RESULT             2006//发送抢庄结果
#define CMD_START_BET               2007//开始下注（贤家收到，庄家不会收到)
#define CMD_OTHER_PLAYER_BET_RESULT 2008//其他玩家下注结果
#define CMD_START_READING_CARDS     2009//进入看牌阶段，接收5张牌具体数据
#define CMD_START_SHOW_CARDS        2010//玩家确定显示亮牌



#define CMD_INFO  9998//服务器给客户端发送的提示
#define CMD_ERROR 9999//出错
#define INFO_WAITING_ASSIGN @"info001"//玩家切换到牌局场景后等待分配

/*--------------------FAMILY_SERVER通讯命令------------------------------------*/





#endif