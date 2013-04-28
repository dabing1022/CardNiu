//
//  CardPlayingScene.h
//  NiuNiu 牌局
//
//  Created by childhood on 13-4-7.
//
//

#import "cocos2d.h"
#import "CurtainTransitionDelegate.h"

enum{
    kTagCardPlayingScene,
    kTagAvatarInfoBox,
    kTagMenuGrab,
    kTagZSymbol,
    kTagBetRatioMenu,
    kTagAllCards,
    kTagChangeTable,
    kTagResultNiuSymbol,
    kTagReadingCardsLayer,
    kTagCountDownLabelTTF,
    kTagCurtain
};

//倒计时时间长度
typedef enum
{
    kCDTimeGrabZ=8,
    kCDTimeBet=5,
    kCDTimeReadCards=25,
    kCDTimeStop=0
}countDownTime;

typedef enum
{
    kEnterState_NOMAL,//能叫庄也能下注，则进来的阶段为抢庄阶段Tag1
    kEnterState_HASNOT_BET,//不能叫庄但能下注，则进来的阶段为庄家已经确定后下注前进入
    kEnterState_WATCHER//不能叫庄也不能下注，则进来的阶段为下注后进入,即为观察者
}ENTER_STATE;


//头像坐标位置
#define AVARTAR_POS_ID0 CGPointMake(55, 370)
#define AVARTAR_POS_ID1 CGPointMake(55, 220)
#define AVARTAR_POS_ID2 CGPointMake(55, 86)
#define AVARTAR_POS_ID3 CGPointMake(264, 170)
#define AVARTAR_POS_ID4 CGPointMake(55, 310)
#define AVARTAR_POS_ID5 CGPointMake(170, 432)

//首张牌坐标位置
#define CARD_POS_ID0 CGPointMake(52, 306)
#define CARD_POS_ID1 CGPointMake(48, 155)
#define CARD_POS_ID2 CGPointMake(111, 35)
#define CARD_POS_ID3 CGPointMake(257, 105)
#define CARD_POS_ID4 CGPointMake(256, 244)
#define CARD_POS_ID5 CGPointMake(160, 368)

//下注前注币数据盒子坐标位置(玩家本人)
#define BET_BOX_POS_ID0 CGPointMake(122, 84)
#define BET_BOX_POS_ID1 CGPointMake(182, 84)
#define BET_BOX_POS_ID2 CGPointMake(242, 84)
#define BET_BOX_POS_ID3 CGPointMake(302, 84)

//下注后注币数据盒子飞向玩家最后的坐标位置(6个玩家)
#define BET_BOX_FLYTO_POS_ID0 CGPointMake(55, 370)
#define BET_BOX_FLYTO_POS_ID1 CGPointMake(55, 220)
#define BET_BOX_FLYTO_POS_ID2 CGPointMake(55, 86)
#define BET_BOX_FLYTO_POS_ID3 CGPointMake(264, 170)
#define BET_BOX_FLYTO_POS_ID4 CGPointMake(55, 310)
#define BET_BOX_FLYTO_POS_ID5 CGPointMake(170, 432)


//牌间距
#define CARD_SPACE0 3
#define CARD_SPACE1 5
#define CARD_SPACE2 20

//牌的总张数
#define TOTAL_CARD_NUM 30
//最多玩家数
#define MAX_PLAYERS_NUM 6
//卡牌飞行速度
#define CARD_SPEED 600

@class ProfilePanel;
@interface CardPlayingScene : CCLayer <UIGestureRecognizerDelegate,CurtainTransitionDelegate,UIAlertViewDelegate>
{
    //加入手势滑动切换场景
    UISwipeGestureRecognizer *_swipeLeftGestureRecognizer;
    UISwipeGestureRecognizer *_swipeRightGestureRecognizer;
    UIActivityIndicatorView *_activityIndicatorView;
    
    CCMenuItemImage *_menuItemGrabZ;
    CCMenuItemImage *_menuItemNotGrabZ;
    CCMenu *_menuGrabZ;
    
    CCMenuItemImage *_betRatioItem1;
    CCMenuItemImage *_betRatioItem2;
    CCMenuItemImage *_betRatioItem3;
    CCMenuItemImage *_betRatioItem4;
    CCMenu *_betRatioMenu;
    
    NSMutableArray *_allUserCardsArr;//所有玩家背面牌
    NSMutableArray *_allUserCardsArr2;//所有玩家正面牌
    NSMutableArray *_playerCardsArr;//玩家本人的5张卡牌
    NSMutableArray *_playerWinLoseCoinTBArr;//所有玩家输赢铜币显示
    NSMutableDictionary *_betResultDic;//玩家下注结果显示字典表，键为userID
    NSMutableDictionary *_avatarDic;//玩家头像字典表，键为userID
    NSMutableDictionary *_playerResultNiuSymbolDic;//所有玩家牌型结果显示,键为userID
    
    CCSprite *_zSymbol;
    CCSprite *_countDown;
    //COUNT DOWN

    int _timeLeft;
    int _countDownType;
    CCLabelTTF *_countDownLabelTTF;
    
    
    CCLayer *_readingCardsLayer;
    
    CCMenuItemFont *_changeTableItemTTF;
    CCMenu *_changeTableMenu;
}

@property(nonatomic, retain) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
+(CCScene *) scene;


@end
