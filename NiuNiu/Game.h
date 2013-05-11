#ifndef __GAME_H
#define __GAME_H
#define LOG_FUN_DID CCLOG(@"%s-->%@", __FILE__, NSStringFromSelector(_cmd))

/*--------------------LOGIN_SERVER通讯命令------------------------------------*/
//用户通过GC验证后登录
#define CMD_HEART_BEAT              1000//心跳包
#define CMD_LOGIN                   1001//玩家登录





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
#define CMD_FINAL_RESULT            2011//本轮玩家输赢情况
#define CMD_UPDATE_USERS_INFO       2012//更新玩家信息(包括铜币等信息)
#define CMD_CHANGE_TABLE            2013//向服务器请求换桌
#define CMD_OTHER_PLAYER_OUT        2014//其他玩家离开桌子
#define CMD_QUIT_CARD_GAME          2015//退出牌局游戏
#define CMD_OTHER_PLAYER_OFFLINE    2016//玩家离线
#define CMD_OTHER_PLAYER_ONLINE     2017//玩家恢复在线
#define CMD_RECONNECT_CARD_SERVER   2018//断线重连牌局服务器
#define CMD_NEXT_ROUND_Z            2019//下一把庄家


#define CMD_INFO                    9998//服务器给客户端发送的提示
#define CMD_ERROR                   9999//出错
#define INFO_WAITING_ASSIGN         @"info001"//玩家切换到牌局场景后等待分配
#define INFO_FORCED_CHANGE_TABLE    @"info002"//玩家金币不足，被系统重新分配桌子

/*--------------------FAMILY_SERVER通讯命令------------------------------------*/





#endif