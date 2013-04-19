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
    kTagCurtain,
    kTagMenuGrab
};

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

//牌间距
#define CARD_SPACE0 3
#define CARD_SPACE1 5

//牌的总张数
#define TOTAL_CARD_NUM 30
//最多玩家数
#define MAX_PLAYERS_NUM 6

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
    NSMutableArray *_allUserCards;
}

@property(nonatomic, retain) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property(nonatomic, retain) UISwipeGestureRecognizer *swipeRightGestureRecognizer;
+(CCScene *) scene;


@end
